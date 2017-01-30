AddCSLuaFile()

character = character or {}
character.List = {}//character.List or 

local CHR = {}
 
function Character(base)
	local m = nil
	local basefound = false
	if base then 
		local b = character.List[base] 
		if b then
			m = table.Copy(b)
			basefound = true
		else
			MsgN( "Character "..base.." not found!\n" )
			return nil
		end
	else
		m = {} 
	end
	setmetatable(m,CHR)
	return m, basefound
end

function character.Add(name,chr)
	chr.keyhook = {}
	chr.inkeyhook = {} 
	for k,v in pairs(chr.spells) do 
		if v.key then chr.keyhook[v.key] = v[1] end
		if v.inkey then chr.inkeyhook[v.inkey] = v[1] end
	end 
	character.List[name] = chr
end

function character.LoadAll()
	local ray = file.Find( "characters/*.lua", "LUA"  )
	for k,v in pairs(ray) do 
		local cname = string.sub( v, 1, #v-4 )
		MsgN("character: "..cname)
		AddCSLuaFile("lua/characters/"..v)
		character.Add(cname, UTILS_AddClass("characters/"..v,Character,"character"))
	end
end
function character.UpdateLevel(ent,level)
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
		end
		if SERVER then
			DoForAll("character.UpdateLevel(Entity("..tostring(ent:EntIndex()).."),"..tostring(level)..")");
		end
	end
end
local function InitCharacter(ent)
	local hero = ent.dotahero
	UTILS_SafeCall(ent,"StripWeapons")
	ent:SetModel(hero.model) 
	if ent.AllowFlashlight then ent:AllowFlashlight( false ) end
	ent.abilities = {} 
	ent.stats = {}
	for k,v in pairs(hero.spells) do 
		local name = v[1]
		local ab = Ability(name)
		table.Merge(ab,v)
		ab.owner = ent
		ab.nextcast = CurTime()+ab.cooldownDelay
		ent.abilities[name] = ab 
	end
	character.UpdateLevel(ent,1) 
	if hero.speed_walk then
		ent:SetWalkSpeed(hero.speed_walk)
	end
	if hero.speed_run then
		ent:SetRunSpeed(hero.speed_run)
	end
	if hero.Behavior then 
		local bg = BehaviorGraph(ent) 
		hero:Behavior(ent,bg)
		ent._angraph = bg 
	end  
	if ent.dh_cskin then
		character.SetSkin(ent,ent.dh_cskin) 
	end
	
	if ent.dotahero.Spawn then ent.dotahero:Spawn(ent) end
	
	
end
local function UnInitCharacter(ent)
	if ent.dotahero then
		if ent.dotahero.Despawn then ent.dotahero:Despawn(ent) end
		ent.dotahero = nil
		ent.basehero = nil
		ent._angraph = nil 
		ent:SetModel("")
		if ent.AllowFlashlight then ent:AllowFlashlight( true ) end
		ent.dh_cskin = nil
	end 
end

function character.Set(ent,name)
	if name then 
		local char  = Character(name)
		//MsgN(char)
		//PrintTable(char)
		if char then 
			UnInitCharacter(ent)
			ent.dotahero = char
			local eid = ent:EntIndex()
			InitCharacter(ent)
			if SERVER then
				MsgN("character.Set(Entity("..tostring(eid).."),'"..name.."')")
				for k,v in pairs(player.GetAll()) do 
					v:SendLua("character.Set(Entity("..tostring(eid).."),'"..name.."')")
				end
			end
		else 
			MsgN("character "..name.." not found")
		end
	else
		UnInitCharacter(ent)
		local eid = ent:EntIndex()
		if SERVER then
			for k,v in pairs(player.GetAll()) do 
				v:SendLua("character.Set(Entity("..tostring(eid).."))")
			end
		end 
	end  
end
function character.Transform(ent,targetname) 
	if ent.dotahero and targetname then 
		if ent.basehero then
			if ent.basehero.name == targetname then
				local ctd = ent.dotahero 
				ent.dotahero = ent.basehero
				ent.basehero = ctd
				local eid = ent:EntIndex()
				InitCharacter(ent)
				if SERVER then
					MsgN("character.Transform(Entity("..tostring(eid).."),'"..targetname.."')")
					for k,v in pairs(player.GetAll()) do 
						v:SendLua("character.Transform(Entity("..tostring(eid).."),'"..targetname.."')")
					end
				end
				return nil 
			end
		else 
			local char  = Character(targetname)
			//MsgN(char)
			//PrintTable(char)
			if char then 
				ent.basehero = ent.dotahero
				ent.dotahero = char
				local eid = ent:EntIndex()
				InitCharacter(ent)
				if SERVER then
					MsgN("character.Transform(Entity("..tostring(eid).."),'"..targetname.."')")
					for k,v in pairs(player.GetAll()) do 
						v:SendLua("character.Transform(Entity("..tostring(eid).."),'"..targetname.."')")
					end
				end
			else 
				MsgN("character "..name.." not found")
			end
		end
		
	end
end

function character.SetSkin(ent,id)
	if ent.dotahero then
		if ent.dotahero.skins then
			local sk  = ent.dotahero.skins[id]
			// { bg = {1,0}, skn = 0},
			if sk then
				if (sk.bg) then ent:SetBodygroup(sk.bg[1],sk.bg[2]) end
				if (sk.skn) then ent:SetSkin(sk.skn) end
				ent.dh_cskin = id
				return true
			end 
		end
	end
	return false
end

CHR.__index = CHR 
 

character.LoadAll()