AddCSLuaFile()
  
  
include("_classcore/init.lua")
 
 
   
 
//player_manager.AddValidModel( "enchantress", "models/heroes/enchantress/enchantress.mdl" )


Dota = Dota or {}
Dota.heroes = {}
Dota.spells = {}


 
local heroesf = file.Find( "characters/*.lua", "LUA"  )
for k,v in pairs(heroesf) do 
	AddCSLuaFile("characters/"..v)
	include("characters/"..v)
	//local data = file.Read( v, "LUA" )
	//RunString( data, "DotaHero" )
end

if SERVER then
	util.AddNetworkString( "dota_hero_event" )
end
local function nReceive( len, pl )
	local etype = net.ReadInt(32)
	local ent = net.ReadEntity()
	if etype == 1 then //anim
		local sequence = net.ReadInt(32)
		local reset = net.ReadBool()
		if CLIENT then
			if ent.dh_seqid != sequence then 
				ent.dh_seqreset = true
			else
				ent.dh_seqreset = reset
			end
			ent.dh_seqid = sequence 
		else
			ent.dh_seqreset = ent.dh_seqid != sequence
			ent.dh_seqid = sequence 
			
			net.Start("dota_hero_event")
			net.WriteInt(etype,32)
			net.WriteEntity(ent)
			net.WriteInt(sequence,32)
			net.WriteBool(reset)
			net.Broadcast()
			
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

function Dota.SetHero(ent,hero)
	if hero == nil then 
		Dota.UnInit(ent)
		local eid = ent:oldEntIndex()
		if SERVER then
			for k,v in pairs(player.oldGetAll()) do 
				v:SendLua("Dota.SetHero(oldEntity("..tostring(eid).."))")
			end
		end 
	else
		ent.dotahero = Dota.heroes[hero]
		local eid = ent:oldEntIndex()
		Dota.InitHero(ent)
		if SERVER then
			MsgN("Dota.SetHero(oldEntity("..tostring(eid).."),'"..hero.."')")
			for k,v in pairs(player.oldGetAll()) do 
				v:SendLua("Dota.SetHero(oldEntity("..tostring(eid).."),'"..hero.."')")
			end
		end
	end  
end
function Dota.GetHero(ent) 
	return (ent.dotahero or {}).name
end
 
function SafeCall(obj, func, ...)
	local fl = obj[func]
	if fl != nil then
		return fl(obj,...)
	end
end
      
function Dota.AddCharacter(htab) 
	for k,v in pairs(htab.animations) do
		if isstring(v) then // abc = "anim1"
			v = { a =  {v} }
		else
			if isstring(v[1]) then //abc = {"anim1","anim2"}
				v = { a = v }
			else 
				local nv = { a = v[1]}   
				if v[2] then
					nv["p"] = v[2]
				end 
				if v[3] then
					nv["s"] = v[3]
				end
				if v.loop then
					nv.l = v.loop
				end
				v = nv
			end
		end
		htab.animations[k] = v
	end
	htab.keyhook = {}
	for k,v in pairs(htab.spells) do 
		if v.key then htab.keyhook[v.key] = v[1] end
	end
	//PrintTable(htab.animations) 
	MsgN("Character added: "..htab.name) 
	Dota.heroes[htab.name] = htab
end  
   
function Dota.AddSpell(htab)
	MsgN("Spell added: "..htab.name)  
	Dota.spells[htab.name] = htab 
end
function Dota.InitHero(ent) 
	local hero = ent.dotahero
	SafeCall(ent,"StripWeapons")
	ent:SetModel(hero.model) 
	ent.abilities = {}
	ent.stats = {}
	for k,v in pairs(hero.spells) do
		local name = v[1]
		local ab = Ability(name)
		ab.owner = ent
		ent.abilities[name] = ab 
	end
	Dota.UpdateLevel(ent,1) 
	if hero.speed_walk then
		ent:SetWalkSpeed(hero.speed_walk)
	end
	if hero.speed_run then
		ent:SetRunSpeed(hero.speed_run)
	end
	if ent.dotahero.func_onspawn then ent.dotahero.func_onspawn(ent) end
end
function Dota.UpdateLevel(ent,level)
	local hero = ent.dotahero
	if hero then
		level = level or ent.level or 1
		ent.level = level
		ent.stats = ent.stats or {}
		for k,v in pairs(hero.stats) do
			if k == "attackspeed" then
				ent.stats[k] = v[1]+v[1]*v[2]*level/100
			else
				ent.stats[k] = v[1]+v[2]*level
				if k == "health" then
					ent:SetHealth(ent.stats[k])
				end
			end
		end
		local abr = ent.abilities["l_attack_ranged"]
		if abr then
			abr.cooldownDelay = ent.stats.attackspeed
			MsgN(abr.cooldownDelay)
		end
	end
end
function Dota.UnInit(ent)
	if ent.dotahero then
		if ent.dotahero.func_ondespawn then ent.dotahero.func_ondespawn(ent) end
		ent.dotahero = nil
		ent:SetModel("")
	end
end  
function Dota.PlaySequence2(ent, name, overridetime, interruptable)
	if(ent.dotahero==nil)then return nil end 
	local st = ent.dotahero.animations[name]
	interruptable = interruptable or false
	if not st then
	
			MsgN("anim notfound: "..tostring(name))
	end
	if st then
		if ent.dh_animtime != nil and not overridetime and not ent.dh_interruptable then return false end 
		local seqid = table.Random( st.a )
		if st.l != true then
			local len = ent:SequenceDuration( seqid )
			ent.dh_animtime = CurTime() + len 
			Dota.ResetSequence(ent, seqid) 
			ent.dh_currentanim = name
			ent.dh_interruptable = interruptable
			return true 
		else  
		end  
		if ent.dh_currentanim != name or overridetime then
			Dota.SetSequence(ent, seqid) 
			ent.dh_currentanim = name
		end
		return true  
	end 
	return false 
end 

function Dota.PlaySequence(ent, seqid)
	if(ent.dotahero==nil)then return nil end 
	if ent.dh_animtime != nil then return nil end 
	
	Dota.SetSequence(ent, seqid)
	local len = ent:SequenceDuration( seqid )
	ent.dh_animtime = CurTime() + len 
	return true
end
function Dota.UnsetSequence(ent, seqid, newseqid)
	if(ent.dotahero==nil)then return nil end
	if ent.dh_seqid == seqid then
		Dota.SetSequence(ent, newseqid)
	end
end 
function Dota.SetSequence(ent, seqid) 
	if(ent.dotahero==nil)then return nil end
	if isstring(seqid) then
		seqid = ent:LookupSequence(seqid)
	end
	
	if CLIENT then  
		if ent.dh_seqid != seqid then 
			ent.dh_seqreset = true 
			ent.dh_seqid = seqid
			
			net.Start("dota_hero_event")
			net.WriteInt(1,32)
			net.WriteEntity(ent)
			net.WriteInt(seqid,32)
			net.WriteBool(false)
			net.SendToServer()
		end
		
	else 
		ent.dh_seqreset = ent.dh_seqid != seqid 
		ent.dh_seqid = seqid
		
		ent:SetPlaybackRate( 1 )
		net.Start("dota_hero_event")
		net.WriteInt(1,32)
		net.WriteEntity(ent)
		net.WriteInt(seqid,32)
		net.WriteBool(false)
		net.Broadcast()
	end
end
 
function Dota.ResetSequence(ent, seqid)
	if(ent.dotahero==nil)then return nil end 
	if isstring(seqid) then
		seqid = ent:LookupSequence(seqid)
	end
	if CLIENT then 
		ent.dh_seqid = seqid
		ent.dh_seqreset = true 
		
		net.Start("dota_hero_event")
		net.WriteInt(1,32)
		net.WriteEntity(ent)
		net.WriteInt(seqid,32)
		net.WriteBool(true)
		net.SendToServer()
	else  
		ent.dh_seqid = seqid
		ent.dh_seqreset = true 
		
		ent:SetPlaybackRate( 1 )
		net.Start("dota_hero_event")
		net.WriteInt(1,32)     
		net.WriteEntity(ent)
		net.WriteInt(seqid,32)
		net.WriteBool(true)
		net.Broadcast()
	end
end  
  
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
function Dota.CastOLD(ply, name)//SERVER
	local spell = Dota.spells[name]
	if not spell then return false end
	ply.dh_spellinfo = ply.dh_spellinfo or {} 
	local spellinfo = ply.dh_spellinfo[spell.name]
	if not spellinfo then 
		ply.dh_spellinfo[spell.name] = {} 
		spellinfo = {} 
	end
	local lastcastdelay = spellinfo.lastcast or 0
	
	if lastcastdelay < CurTime() then 
		spellinfo.lastcast = CurTime() + spell.cooldown
		
		local castresult = true
		local trace = ply:GetEyeTrace()
		
		if spell.func_cast then
			castresult = spell.func_cast(spell, ply, trace)
		end 
		if castresult then
			if spell.animation then Dota.PlaySequence2(ply, spell.animation,castresult) end
			if spell.sound then ply:EmitSound( table.Random(spell.sound) ) end
			if spell.func_dispell then
				timer.Simple(spell.duration,function() spell.func_dispell(spell, ply) end)
			end
			//local eyet = ply:GetEyeTrace()
			//if SERVER then
			//	local orent = Entity(0)
			//	orent:StopParticles()
			//	ply:StopParticles()
			//	//if ply.dotahero == Dota.heroes.enchantress then
			//		local off = (eyet.HitPos - orent:GetPos()) 
			//		local off2 = off +Vector(0,0,5000)/50
			//		local effname ="enchantress_natures_attendants_lvl4"
			//		StartEffects(ply,"enchantress_natures_attendants_orig")
			//		StartEffects(ply,"enchantress_natures_attendants_heal")
			//		StartEffects(ply,"enchantress_natures_attendants_heal_aura") 
			//		//StartEffects(ply,"enchantress_natures_attendants_lvl4")  
			//		//local eyet = ply:GetEyeTrace()
			//		if eyet.Entity and eyet.Entity != NULL then
			//			MagicEffect("heal"):Cast(eyet.Entity)
			//		end
			//		if SERVER then
			//			if ply.dotahero.s_cast then ply:EmitSound( ply.dotahero.s_cast ) end
			//		end
            //
			//end 
			return true
		end
	end 
	return false
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
		Dota.PlaySequence2(ply, "spawn",true)      
		return true
	end   
end        
local lastthink = {}
local function HOOK_PlayerPostThink( ply )
	if(ply.dotahero!=nil) then
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
		de:ResetSequence(ply:LookupSequence("death")) 
		//Dota.PlaySequence2(de, "death") 
		 
		return true
	end
end 

local function HOOK_CalcMainActivity( ply, vel )

	if(ply.dotahero!=nil and not ply.dotahero.isplayermodel) then
		local hero = ply.dotahero
		//MsgN( ply:LookupSequence( "run" ))
		//ply:SetSequence(20)
		//ply:SetPlaybackRate( 1)
		//ply.CalcIdeal = -1
		local result = 1
		
		local ct = CurTime()
		local curact = ply.dh_seqid or -1
		local reset = ply.dh_seqreset or false 
		local timestamp = ply.dh_seqts or -1
		local cts = ply:GetCycle()
		if curact != -1 then
			if reset then
				ply.dh_seqreset = false
				ply:SetCycle(0)
			end
			result = curact
			//if timestamp == nil or reset then
			//	//timestamp = ct+ply:SequenceDuration( curact ) 
			//	//ply.dotahero.seqts = timestamp
			//	ply.dotahero.curseqid  = curact 
			//	if reset then ply:SetCycle(0) end
			//		MsgN("START")
			//elseif timestamp > cts then
			//	MsgN(timestamp,"-",cts)
			//	timestamp = nil
			//	ply.dotahero.seqts = -1
			//	curact = -1
			//	ply.dotahero.seqid = curact
			//	ply.dotahero.curseqid  = nil
			//		MsgN("STOP")
			//elseif timestamp <= cts then  
			//	MsgN(timestamp,"-",cts)
			//	ply.dotahero.seqts = cts  
			//	if ply.dotahero.curseqid !=nil then
			//		result =ply.dotahero.curseqid 
			//	end
			//end
			//if reset then
			//	ply.dotahero.seqreset = false
			//end
		end
		if true then  
		return 0,result end
		/*
		local curact = ply.CalcAnim or 0
		local delay = ply.CalcDelay or CurTime()
		local noloop = ply.CalcNoloop or false 
		if delay<=CurTime() then
			if curact == 4 or curact == 3 and ply._anim_attack == 1 then
				ply._anim_attack = 0
			end
			if curact == 8 and ply._anim_cast == 1 then
				ply._anim_cast  = 0
			end
			
			if ( ply:IsOnGround() ) then
				if(vel:Length()>300) then
					curact = hero.a_run
				elseif(vel:Length()>0.1) then
					curact = hero.a_walk
				else 
					if ply._anim_attack == 1 then
						ply:AnimRestartMainSequence()
						curact = table.Random(hero.a_attack or {0})
						delay = CurTime() + ply:SequenceDuration( curact )  
						if hero.s_attack then ply:EmitSound( hero.s_attack ) end
					elseif ply._anim_cast == 1 then
						ply:AnimRestartMainSequence()
						curact = hero.a_cast
						delay = CurTime() + ply:SequenceDuration( curact )
						ply._anim_cast = 0
						if hero.s_cast then ply:EmitSound( hero.s_cast ) end
					elseif math.Rand( 1,10000 ) > 9998 and curact == 1 then
						ply:AnimRestartMainSequence()
						curact = hero.a_idle_special
						delay = CurTime() + ply:SequenceDuration( curact ) 
					else 
						curact = hero.a_idle
					end 
				end
			end 
			ply.CalcAnim = curact
			ply.CalcDelay = delay
		end
		return 0,curact
		*/
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
					MsgN("CAST")
				end
			end
		end
		 
		//if  math.Rand( 1,10000 ) > 9990 then
		//	mv:SetButtons( IN_JUMP)
		//end
		
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
		 
		if mv:KeyDown( IN_FORWARD) and not isCasting then 
			if mv:KeyDown(IN_SPEED) then   
				Dota.PlaySequence2(ply, "run",firstrun)  
			else
				Dota.PlaySequence2(ply, "walk",firstrun)  
			end 
		else  
			Dota.PlaySequence2(ply, "idle")  
		end                      
		if not isInVehicle then
			if mv:KeyDown( IN_DUCK) then
				local kh_d = ply.dotahero.keyhook[IN_DUCK]
				if kh_d then Dota.Cast(ply, kh_d) end
			elseif mv:KeyDown( IN_JUMP) then   
				local kh_d = ply.dotahero.keyhook[IN_JUMP]
				if kh_d then Dota.Cast(ply, kh_d) end
			elseif mv:KeyDown( IN_ATTACK) then 
				local kh_d = ply.dotahero.keyhook[IN_ATTACK]
				if kh_d then Dota.Cast(ply, kh_d)  end 
			elseif mv:KeyDown( IN_ATTACK2) then 
				local kh_d = ply.dotahero.keyhook[IN_ATTACK2]
				if kh_d then Dota.Cast(ply, kh_d)   end
			end 
		end 
		if ply.dh_animtime != nil and ply.dh_animtime < CurTime() then
			Dota.PlaySequence2(ply, "idle")
			ply.dh_animtime = nil
			ply.dh_currentanim = nil
		end 
		mv:RemoveKeys( IN_JUMP  )
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
	for k,v in pairs(player.oldGetAll()) do
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
  



function Util_ParticleEffect(ent, id, effect)
	if SERVER then
		for k,v in pairs(player.oldGetAll()) do
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
		for k,v in pairs(player.oldGetAll()) do
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
           
hook.Add( "SetupMove", "DOTAHERO",  HOOK_SetupMove)
hook.Add( "PlayerLoadout", "DOTAHERO",HOOK_PlayerLoadout )
hook.Add( "TranslateActivity", "DOTAHERO", HOOK_TranslateActivity)
hook.Add( "PlayerSetModel", "DOTAHERO", HOOK_PlayerSetModel)
hook.Add( "PlayerSpawn", "DOTAHERO", HOOK_PlayerSpawn)
hook.Add( "CalcMainActivity", "DOTAHERO", HOOK_CalcMainActivity)
hook.Add( "UpdateAnimation", "DOTAHERO", HOOK_UpdateAnimation )
hook.Add( "PlayerFootstep", "DOTAHERO", HOOK_PlayerFootstep )
hook.Add( "FindUseEntity", "DOTAHERO", HOOK_FindUseEntity )
hook.Add( "PostPlayerDeath", "DOTAHERO", function() end )
hook.Add( "DoPlayerDeath", "DOTAHERO", HOOK_DoPlayerDeath )
hook.Add( "PlayerPostThink", "DOTAHERO", HOOK_PlayerPostThink )
//hook.Add( "DoAnimationEvent", "DOTAHERO", HOOK_DoAnimationEvent )

    
  

 	///local hero = ent.dotahero
			///if hero!=nil then
			///	if sequence == hero.a_cast then
			///		if hero.s_cast then ent:EmitSound( hero.s_cast ) end
			///	end
			///	local atr = hero.a_attack or {0}
			///	if table.HasValue( atr, sequence) then 
			///		if hero.s_attack then ent:EmitSound( hero.s_attack ) end
			///	end
			///	
			///end
						//end
						////"luna_lucent_beam"
						//local ps = orent:CreateParticleEffect(effname,  0, 
						//{attachtype = PATTACH_ABSORIGIN_FOLLOW} )//,position =off
						/////ps:AddControlPoint(0, orent, PATTACH_WORLDORIGIN, 0,off2 )
						/////ps:AddControlPoint(1, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(2, orent, PATTACH_WORLDORIGIN, 0,off2 )
						/////ps:AddControlPoint(3, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(4, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(5, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(6, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(7, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(8, orent, PATTACH_WORLDORIGIN, 0,off )
						/////ps:AddControlPoint(9, orent, PATTACH_WORLDORIGIN, 0,off )
						//for k=0,20  do
						//	ps:AddControlPoint(k, ent, PATTACH_ABSORIGIN_FOLLOW, 0,Vector(0,0,0) )
						//end
						////ParticleEffect("luna_lucent_beam",eyet.HitPos,Angle(0,0,0))
						