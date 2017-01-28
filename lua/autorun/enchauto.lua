AddCSLuaFile()
  
  
include("_classcore/init.lua")
  
 
 
Dota = Dota or {}
 
 
if SERVER then
	util.AddNetworkString( "dota_hero_event" )
end
local function nReceive( len, pl )
	local etype = net.ReadInt(32)
	local ent = net.ReadEntity()
	if etype == 1 then //anim
		local sequence = net.ReadInt(32)
		local reset = net.ReadBool()
		local seqstart = net.ReadFloat()
		if CLIENT then 
			ent.dh_seqstart = seqstart
			if ent.dh_seqid != sequence then   
				ent.dh_seqreset = true
			else
				ent.dh_seqreset = reset
			end
			ent.dh_seqid = sequence 
		else
			//ent.dh_seqreset = ent.dh_seqid != sequence
			//ent.dh_seqid = sequence 
			//
			//net.Start("dota_hero_event")
			//net.WriteInt(etype,32)
			//net.WriteEntity(ent)
			//net.WriteInt(sequence,32)
			//net.WriteBool(reset)
			//net.Broadcast()
			//
		end
	elseif etype == 2 then // effect
		if SERVER then
			local effectname = net.ReadString() 
			local target = net.ReadEntity()
			MagicEffect(effectname):Cast(target)
		end
	end
end 

net.Receive( "dota_hero_event", nReceive)
 

  
function Dota.Cast(ply, name)//SERVER
	//if ply has spell....   
	ply.abilities = ply.abilities or {}
	local ab = ply.abilities[name]// or Ability(name)
	if ab then 
		ply.abilities[name] = ab 
		return ab:Cast(ply)
	end
	return false
end 

local CMoveData = FindMetaTable( "CMoveData" )
function CMoveData:RemoveKeys( keys ) 
	local newbuttons = bit.band( self:GetButtons(), bit.bnot( keys ) )
	self:SetButtons( newbuttons )
end

timedrandom = {}
function trand(id,time,rnd)
	local rd = timedrandom[id]
	if rd then
		if rd < CurTime() then
			timedrandom[id] = nil
			return false
		else
			return true
		end
	else
		if rnd then
			timedrandom[id] = CurTime()+time
			return true
		else
			return false
		end
	end
end

function StartEffects( ent , ineffect)
//,position =off 
	if true then return nil end
	local req =   
	"local ent=Entity("..ent:EntIndex()..")\n".. 
	"local ps=ent:CreateParticleEffect(\""..ineffect.."\",  0, {attachtype = PATTACH_ABSORIGIN_FOLLOW} )  \n"..
	"for k=0,20 do \n"..
	"	ps:AddControlPoint(k, ent, PATTACH_ABSORIGIN_FOLLOW, 0,Vector(0,0,0) )\n"..
	"end \n"
	for k,v in pairs(player.GetAll()) do
		v:SendLua(req)
	end
end

game.AddParticles( "particles/units/heroes/hero_luna_pold.pcf" )
function Dota.Mount(ply,mount)
	local hero = mount.dotahero
	if hero == nil then return end
	if ply == mount then return end
	if ply.mount then return end
	local mhero = (ply.dotahero or {}).mounted
	if mhero !=nil then
		MsgN("mounting: ",ply," => ",mount)
		ply.mount = mount
		mount.owner = ply
		mount:SetNWEntity("owner",ply)
		Dota.SetHero(ply,mhero)
		ply:SetMoveType(MOVETYPE_NONE)
		ply:SetParent(mount)
		ply:AddEffects(EF_BONEMERGE)
	end 
end  
    
function Dota.Dismount(ply)
	local mount = ply.mount 
	if mount == nil or mount == NULL then return end
	ply.mount = nil
	mount.owner = nil
	mount:SetNWEntity("owner",nil)
	MsgN("dismounting: ",ply," from ",mount)
	local mhero = (ply.dotahero or {}).dismounted
	Dota.SetHero(ply,mhero)
	ply:SetMoveType(MOVETYPE_WALK)
	ply:SetParent(nil)
	ply:RemoveEffects(EF_BONEMERGE)
end
 


function Util_ParticleEffect(ent, id, effect)
	if SERVER then
		for k,v in pairs(player.GetAll()) do
			v:SendLua("Util_ParticleEffect(Entity("..ent:EntIndex().."),\""..id.."\",\""..effect.."\")")
		end
	else
		local ps=ent:CreateParticleEffect( effect, 0, {attachtype = PATTACH_ABSORIGIN_FOLLOW} )
		ent.peffects = ent.peffects or {}
		ent.peffects[id] = ps
	end
end
function Util_StopEffect(ent,id)
	if SERVER then
		for k,v in pairs(player.GetAll()) do
			v:SendLua("Util_StopEffect(Entity("..ent:EntIndex().."),\""..id.."\")")
		end
	else
		ent.peffects = ent.peffects or {}
		local ps = ent.peffects[id]
		if ps then
			ps:StopEmission( )
			ent.peffects[id] = nil
		end
	end 
end     
       


local function HOOK_PlayerLoadout( ply )  
	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then
		return true 
	end
end
local function HOOK_TranslateActivity( ply, act )
	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then
	//	if(act== ACT_MP_STAND_IDLE) then return 1500 end
		return true 
	end 
end  
local function HOOK_PlayerSetModel( ply )
	if(ply.dotahero!=nil) then
		ply:SetModel( ply.dotahero.model )
	end  
end          
local function HOOK_PlayerSpawn( ply ) 
	if(ply.dotahero!=nil) then
		local de = ply.death_ent
		if de != nil and de != NULL then
			de:Remove() 
			ply.death_ent = nil
		end
		//Dota.PlaySequence2(ply, "spawn",true)      
		return true 
	end      
end             
local lastthink = {}
local function HOOK_PlayerPostThink( ply )
	if(ply.dotahero!=nil) and ply:Alive() then
		local last = lastthink[ply]
		if not last then lastthink[ply] = CurTime() last = CurTime() end
		local cur = CurTime()
		local delta = cur-last   
		if delta>0.5 then
			lastthink[ply] = cur 
			local hp = ply:Health()
			local hpregen = ply.stats.healthregen or 0
			local maxhp =  ply.stats.health or 100
			ply:SetHealth(math.Min( hp+hpregen*delta,maxhp)) 
		end
		if ply._angraph and SERVER then
			ply._angraph:Run()  
		end
	end     
end       
local function HOOK_DoPlayerDeath( ply ) 
	if SERVER and (ply.dotahero!=nil) then 
		local de = ents.Create("prop_dynamic") 
		ply.death_ent = de
		de.dotahero = ply.dotahero 
		de:SetModel(ply:GetModel()) 
		de:SetPos(ply:GetPos())
		de:SetAngles(ply:GetAngles())
		de:ResetSequence(ply:LookupSequence(table.Random(de.dotahero.death_anim or {"death"})))   
		//Dota.PlaySequence2(de, "death") 
		return true 
	end  
end  

local function HOOK_CalcMainActivity( ply, vel ) 
	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then
		local hero = ply.dotahero 
		local result = 1
		 
		local ct = CurTime() 
		local curact = ply.dh_seqid or -1
		local reset = ply.dh_seqreset or false  
		local timestamp = ply.dh_seqts or -1
		local cts = ply:GetCycle()
		if curact != -1 then 
			if reset then  
				ply.dh_seqreset = false   
				ply:SetCycle(ply.dh_seqstart or 0) 
				ply.dh_seqstart = 0
			end   
			result = curact   
		end 
		if true then   
		return 0,result end   
	end  
end 
local function HOOK_UpdateAnimation( ply, vel )
	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then 
		return true
	end
end   
local function HOOK_PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then 
		return true  
	end 
end    
local function HOOK_SetupMove( ply, mv, cmd )
	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then 
		local controller = ply:GetNWEntity("owner")
		if SERVER then  
			local mount = ply.mount
			if mount != nil and mount != NULL then
				local speedmul = 1 if mv:KeyDown(IN_SPEED) then speedmul = 2 end
				 
				if mv:KeyDown( IN_FORWARD) then //mv:KeyDown( IN_FORWARD)
					//MsgN(mv:GetForwardSpeed()*speedmul)
					ply:SetNWFloat("c_speed",mv:GetForwardSpeed()*speedmul)
				else 
					ply:SetNWFloat("c_speed",0)
				end 
				ply:SetNWAngle("c_vang",mv:GetMoveAngles())
				ply:SetNWBool("c2_attack",  mv:KeyDown( IN_ATTACK) )
				ply:SetNWBool("c2_jump",  mv:KeyDown( IN_JUMP) )
			end
			if mv:KeyPressed(IN_USE) then
				Dota.Dismount(ply)
			end 
		end
		if ply.dotahero.move_allow_forward45 and mv:KeyDown( IN_FORWARD) then
			ply:SetPoseParameter("body_yaw", ply:GetVelocity():Dot(-ply:GetRight()))
		else
			ply:SetPoseParameter("body_yaw",0)
			mv:SetSideSpeed( 0 )
		end 
		mv:SetUpSpeed( 0 )
		if false and controller != nil and controller !=NULL then 
			local spd = math.max(0, controller:GetNWFloat("c_speed"))
			mv:SetMaxSpeed( spd )
			mv:SetMaxClientSpeed( spd )
			mv:SetForwardSpeed(spd )
			local ma =controller:GetNWAngle("c_vang") or mv:GetMoveAngles()
			mv:SetMoveAngles(ma)
			//mv:SetAngles( ma )
			if spd>0.01 then ply:SetEyeAngles(ma) end
			if(	ply._anim_attack!=1 and controller:GetNWBool("c2_attack") ) then  
				ply._anim_attack = 1
			end
			if(	ply._anim_cast!=1 and controller:GetNWBool("c2_jump")   ) then  
				ply._anim_cast = 1
				MsgN(controller:GetNWBool("c2_jump"))
			end 
		else 
			local mount = ply.mount
			if mount == nil then
				mv:SetForwardSpeed( math.max(0, mv:GetForwardSpeed()))
				if(	ply._anim_attack!=1 and mv:KeyPressed( IN_ATTACK) ) then  
					ply._anim_attack = 1
				end
				if(	ply._anim_cast!=1 and mv:KeyPressed( IN_JUMP)   ) then  
					ply._anim_cast = 1 
				end
			end
		end
		  
		 
		local isCasting = false //ply.dh_seqid!=ply.dotahero.a_cast 
		local isRunning = mv:KeyDown(IN_SPEED)
		local isInVehicle = ply:InVehicle()
		local isWalking = false
		local isInjured = false
		 
		local prevrun = ply.dh_prevrun or false
		local firstrun = false
		if not prevrun and mv:KeyDown( IN_FORWARD) then
			firstrun = true   
		end  
		ply.dh_prevrun = mv:KeyDown( IN_FORWARD)
		    
		//if mv:KeyDown( IN_FORWARD) and not isCasting then  
		//	if mv:KeyDown(IN_SPEED) then   
		//		Dota.PlaySequence2(ply, "run",firstrun)  
		//	else
		//		Dota.PlaySequence2(ply, "walk",firstrun)   
		//	end 
		//else  
		//	Dota.PlaySequence2(ply, "idle")  
		//end                                
		if not isInVehicle then    
		end  
		if ply.dh_animtime != nil and ply.dh_animtime < CurTime() then
			Dota.PlaySequence2(ply, "idle")
			ply.dh_animtime = nil 
			ply.dh_currentanim = nil 
		end 
		mv:RemoveKeys( IN_JUMP  )
	end  
end    
local function HOOK_FindUseEntity(  ply,  defaultEnt )	 
	local pp = ply:GetEyeTrace()
	local ent = pp.Entity
	if ent != nil and ent != NULL and pp.HitNonWorld and ent!=ply then 
		if(ent.dotahero!=nil) and ent.dotahero.ismount then  
			Dota.Mount(ply,ent)
			return ent
		end 
	end 
	    
end      
       
function UTILS_IsKeysPressed(ray,buttonray) 
	if ray.IsPlayer then
		ray = ray.keyspressed or {} 
	end   
	if istable(buttonray) then
		for k,v in pairs(buttonray) do
			if ray[v] != true then return false end
		end   
	elseif isnumber(buttonray) then
		return ray[buttonray] == true  
	end   
	return true  
end           
local function HOOK_PlayerButtonDown(  ply,  button  ) 
	if SERVER and ply.dotahero then
		ply.keyspressed = ply.keyspressed or {}
		ply.keyspressed[button] = true 
		 
		for k,v in pairs(ply.dotahero.keyhook) do
			if isnumber(k) then 
				if UTILS_IsKeysPressed(ply.keyspressed, {k}) then
					Dota.Cast(ply, v) 
				end
			elseif istable(k) then 
				if UTILS_IsKeysPressed(ply.keyspressed, k) then
					Dota.Cast(ply, v)  
				end   
			end  
		end   
		//local kh_d = ply.dotahero.keyhook[button]
		//if kh_d then Dota.Cast(ply, kh_d) end
	end     
end     
local function HOOK_PlayerButtonUp(  ply,  button  )  
	if SERVER and ply.dotahero then
		ply.keyspressed[button] = nil      
	end        
end   
local function HOOK_KeyPress(  ply,  button  )
	if SERVER and ply.dotahero then
		local kh_d = ply.dotahero.inkeyhook[button]
		if kh_d then Dota.Cast(ply, kh_d) end
	end     
end     
hook.Add( "SetupMove", "DOTAHERO",  HOOK_SetupMove)
hook.Add( "PlayerLoadout", "DOTAHERO",HOOK_PlayerLoadout )
hook.Add( "TranslateActivity", "DOTAHERO", HOOK_TranslateActivity)
hook.Add( "PlayerSetModel", "DOTAHERO", HOOK_PlayerSetModel) 
hook.Add( "PlayerSpawn", "DOTAHERO", HOOK_PlayerSpawn)
hook.Add( "CalcMainActivity", "DOTAHERO", HOOK_CalcMainActivity)
hook.Add( "UpdateAnimation", "DOTAHERO", HOOK_UpdateAnimation )
hook.Add( "PlayerFootstep", "DOTAHERO", HOOK_PlayerFootstep )
hook.Add( "FindUseEntity", "DOTAHERO", HOOK_FindUseEntity )
//hook.Add( "PostPlayerDeath", "DOTAHERO", function() end )
hook.Add( "DoPlayerDeath", "DOTAHERO", HOOK_DoPlayerDeath )
hook.Add( "PlayerPostThink", "DOTAHERO", HOOK_PlayerPostThink ) 
hook.Add( "PlayerButtonDown", "DOTAHERO", HOOK_PlayerButtonDown )
hook.Add( "PlayerButtonUp", "DOTAHERO", HOOK_PlayerButtonUp )
hook.Add( "KeyPress", "DOTAHERO", HOOK_KeyPress )
//hook.Add( "DoAnimationEvent", "DOTAHERO", HOOK_DoAnimationEvent )
     
concommand.Add( "arena_setchar", function(ply,cmd,args)
	local e = (Entity or Entity)(tonumber(args[1]))
	if e then  
		character.Set(e,args[2]) 
	end  
end)  
 




 
  




    