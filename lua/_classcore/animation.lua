AddCSLuaFile()

GMARENA = GMARENA or {}
 
function GMARENA.SetSequence(ent, seqid) 
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
 
function GMARENA.ResetSequence(ent, seqid)
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

BGCOND = {}
BGACT = {}
BGUTIL = {}

function BGCOND.RND1P() return math.random(1,10000)<100 end 
function BGCOND.RND10P() return math.random(1,10000)<1000 end 
function BGCOND.ANMFIN(s) return s.anim_end<CurTime() end 
function BGACT.PANIM(ent,anim,reset) 
	local sid =  ent:LookupSequence(anim)   
	if reset then 
		GMARENA.ResetSequence(ent,sid) 
	else
		GMARENA.SetSequence(ent,sid) 
	end 
	if interrupt then 
		return 0.5 
	else
		return ent:SequenceDuration(sid)
	end
end
function BGACT.PANIMRND(ent,animtbl,reset) 
	return BGACT.PANIM(ent,table.Random(animtbl),reset)
end
function BGUTIL.KPRESS(e,key) 
	return UTILS_IsKeysPressed(e,key)
end 
function BGUTIL.ABREADY(e,abname) 
	//MsgN(abname," = ",e.abilities[abname] and e.abilities[abname]:Ready())
	return e.abilities[abname] and e.abilities[abname]:Ready()
end
function BGACT.ABCAST(e,abname) 
	return e.abilities[abname] and e.abilities[abname]:Cast(e)
end 
function BGACT.SETSPD(e,sp)
	if sp == 0 then sp = 0.0001 end
	e:SetWalkSpeed(sp)  
	e:SetRunSpeed(sp) 
end

