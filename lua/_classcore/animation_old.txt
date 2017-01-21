AddCSLuaFile()
function Dota.PlaySequence2(ent, name, overridetime, interruptable)
	if(ent.dotahero==nil or true)then return nil end 
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

ANIM_UNKNOWN       = 0
ANIM_SEQ           = 1
ANIM_SEQ_SPC       = 2
ANIM_LIST_RND      = 3
ANIM_LIST_ORD      = 4
ANIM_EVENT         = 5
ANIM_CONDITION     = 6


function _An(name, loop)  
	return { type = ANIM_SEQ, seq = name, loop = loop or false }  
end 
function _AnSpc(name, rate) return { type = ANIM_SEQ_SPC, seq = name ,rate = rate} end 

function _AnRnd(tab) return {type = ANIM_LIST_RND, list = tab } end 

function _AnOrd(tab) return {type = ANIM_LIST_ORD, list = tab } end 

function _AnEve(efunc) return {type = ANIM_EVENT, func = efunc } end 
function _AnEBG(bn,bv) return {type = ANIM_EVENT, func = function(ent) ent:SetBodygroup(1,1) end } end 

function _AnIf(con,tthen,telse) return {type = ANIM_CONDITION, func = con, sela = tthen, selb = telse } end 
function _AnIfKD(key,tthen,telse) return {type = ANIM_CONDITION, 
	func = function(e) return e:KeyDown(key) end, sela = tthen, selb = telse } end 
function _AnIfKD2(keys,tthen,telse) return {type = ANIM_CONDITION, 
	func = function(e) return UTILS_IsKeysPressed(e,keys) end, sela = tthen, selb = telse } end 


function _AnPlay(ent,tab,isnotroot)
	if tab.type == ANIM_LIST_ORD then
		local id = 1
		local len = #tab.list
		//local duration = 0
		//
		local revt = table.Reverse(tab.list)
		for k,v in pairs(revt) do
			//timer.Simple(duration,function() _AnPlay(ent,v,true) end)
			_AnPlay(ent,v,true)
			//duration = duration + (_AnDur(ent, v) or 0)  
		end
	elseif tab.type == ANIM_LIST_RND then
		if not tab._sel then
			_AnSel(tab)
		end
		_AnPlay(ent,tab._sel,true)
	elseif tab.type == ANIM_SEQ or tab.type == ANIM_SEQ_SPC then
		//Dota.PlaySequence2(ent, name, overridetime, interruptable)
		//Dota.PlaySequence2(ent, tab.seq, tab.loop or false)
		ent._anstack:Push({tab.seq,tab.loop or false})
		//Dota.SetSequence(ent, tab.seq) 
	elseif tab.type == ANIM_EVENT then
		tab.func(ent)
	elseif tab.type == ANIM_CONDITION then
		if tab.func(ent) then
			if tab.sela then _AnPlay(ent,tab.sela,true) end
		else
			if tab.selb then _AnPlay(ent,tab.selb,true) end
		end
	end
	 
	_AnClean(tab)    
end
function _AnDur(ent,tab)
	if tab.type == ANIM_SEQ or tab.type == ANIM_SEQ_SPC then 
		return ent:SequenceDuration( ent:LookupSequence(tab.seq))
	elseif tab.type == ANIM_LIST_RND then 
		_AnSel(ent,tab)
		return _AnDur(tab._sel)
	elseif tab.type == ANIM_LIST_ORD then 
		local duration = 0 
		for k,v in pairs(tab.list) do 
			duration = duration + (_AnDur(ent, v) or 0)  
		end
		return duration
	elseif tab.type == ANIM_LIST_ORD then 
		if tab.func(ent) then
			if tab.sela then return _AnDur(ent,tab.sela) end
		else
			if tab.selb then return _AnDur(ent,tab.selb) end
		end
	end
end
function _AnSel(tab)
	if tab.type == ANIM_LIST_RND then 
		while (true) do 
			local ss = tab.list[math.random(1, #tab.list)]
			if ss.type == ANIM_SEQ_SPC then
				local max = ss.rate 
				if math.random(1, ss.rate*100)<100 then
					tab._sel = ss 
					break 
				else            
				end
			else                
				tab._sel = ss 
				break
			end
		end 
	end
end
function _AnClean(tab)
	if tab.type == ANIM_LIST_RND then 
		tab._sel = nil
		for k,v in pairs(tab.list) do
			_AnClean(v)
		end
	elseif tab.type == ANIM_LIST_ORD then 
		for k,v in pairs(tab.list) do
			_AnClean(v)
		end
	end
end



function _AnStack(ent)
	local t = {_ent = ent, _list = {}} 
	function t:Call(anim) 
		MsgN(#self._list," - ", anim[1],":",anim[2]) 
		local sid =  ent:LookupSequence(anim[1])
		Dota.SetSequence(self._ent,sid)
		if anim[2] != true then
		timer.Simple(ent:SequenceDuration(sid),
			function() self:Pop(anim) end)
		end
	end
	function t:Clear() 
		self._list = {}
	end
	function t:Push(anim)
		self._list[#self._list+1] = anim 
		if anim then self:Call(anim) end
	end
	function t:Pop(anim)
		local r = self._list[#self._list] 
		if anim then
			if r == anim then
				self._list[#self._list] = nil	
				local an = self:Peek() 
				if an then self:Call(an) end
				return true 
			else
				return false
			end 
		else 
			self._list[#self._list] = nil
			local an = self:Peek()
			if an then self:Call(an) end
			return r
		end
	end
	function t:Peek()
		local r = self._list[#self._list] 
		return r
	end 
	return t
end

function _AnGraph(ent)
	local t = 
	{
		_ent = ent, 
		_states = {}, 
		_groups = {},
		anim_end = 0,
	} 
	function t:Run() 
		//if self.cooldown < CurTime() then
			for k,v in pairs(self._cstate._transitions) do 
				if v[2] then
					if v[2](self,ent) then   
						self:SetState(v[1]) 
					end
				else
					self.anim_end = 0
					self:SetState(v[1])  
				end 
			end
		//end
	end
	function t:NewTransition(s1name,s2name,funccond)
		local a1 = self._groups[s1name] 
		if a1 then
			for k,v in pairs(a1.states) do 
				self:NewTransition(v,s2name,funccond) 
			end
		else 
			local s1 = self._states[s1name] 
			if not s1 then MsgN("Warning state not found: "..s1name) end 
			s1._transitions[#s1._transitions+1] = {s2name,funccond}
		end
	end
	function t:NewState(name,onEnter,onExit)
		self._states[name] = {
			name = name,
			enter = onEnter, //
			exit = onExit,
			_transitions = {}
		}
	end
	function t:NewGroup(name,aliasedStates)
		self._groups[name] = {
			name = name,
			states = aliasedStates
		}
	end
	function t:SetState(name) 
		local from = self._cstate
		local to = self._states[name]  
		if self._cstate then
			if self._cstate.exit then
				self._cstate.exit(self,ent,to) 
			end
		end
		if self._cstate then
			from = self._cstate
			MsgN("changing state: ",from.name," => ",to.name)
		else
			MsgN("starting graph with state: ",to.name)
		end
		self._cstate = to
		if self._cstate.enter then 
			self.anim_end = CurTime() + ( self._cstate.enter(self,ent,from) or 0.5 )
		else
			self.anim_end = CurTime()
		end
	end
	return t
end 
           
local dance  =_AnOrd({
		_AnEBG(1,1),
		_An("dancestart"),
		_An("dance"), 
		})    
local dance2  =_AnOrd({  
		_An("dance"),  
		_An("taunt"), 
		_An("cast_s3"), 
		})  
           
local cast1  =_AnOrd({
		_AnEBG(1,0),
		_AnIfKD(IN_FORWARD,  _An("cast_s1f"),
		_AnIfKD(IN_BACK,  _An("cast_s1b"),
		_AnIfKD(IN_MOVELEFT,  _An("cast_s1l"),
		_AnIfKD(IN_MOVERIGHT,  _An("cast_s1r"),  _An("cast_s1f"))))) 
		})    
local runinjured  = _AnIf(function(ent) return ent:Health() < 100 end,  _An("run"), _An("runinjured") )
local asn = _AnGraph(Entity(1))
Entity(1)._angraph = asn
function random1p() return math.random(1,10000)<100 end 
function random10p() return math.random(1,10000)<1000 end 
function onAnimFin(s) return s.anim_end<CurTime() end 
function playAnimD(ent,anim,reset) 
	local sid =  ent:LookupSequence(anim)   
	if reset then
		Dota.ResetSequence(ent,sid) 
	else
		Dota.SetSequence(ent,sid) 
	end
	
	if interrupt then 
		return 0.5 
	else
		return ent:SequenceDuration(sid)
	end
end
function playAnimRandom(ent,animtbl,reset) 
	return playAnimD(ent,table.Random(animtbl),reset)
end
function UKeyIsDown(e,key) 
	return UTILS_IsKeysPressed(e,key)
end
function UAbIsReady(e,abname) 
	MsgN(abname," = ",e.abilities[abname] and e.abilities[abname]:Ready())
	return e.abilities[abname] and e.abilities[abname]:Ready()
end
function UAbCast(e,abname) 
	return e.abilities[abname] and e.abilities[abname]:Cast(e)
end
function NormAngle(ang)
	ang:Normalize() return ang
end
function USetSpeed(e,sp)
	if sp == 0 then sp = 0.0001 end
	e:SetWalkSpeed(sp)  
	e:SetRunSpeed(sp) 
end
asn:NewState("spawn",function(s,e) USetSpeed(e,0) return playAnimD(e,"idlein") end)

asn:NewState("idle",function(s,e) USetSpeed(e,0) playAnimD(e,"idle") return 0.05 end)
asn:NewState("idlespecial", function(s,e) return playAnimD(e,"idlespecial") end) 
asn:NewState("walk",function(s,e) USetSpeed(e,180) playAnimD(e,"run") return 0.05 end) 
asn:NewState("walkspecial",function(s,e) return playAnimD(e,"runspecial") end) 
asn:NewState("walkinjured",function(s,e) USetSpeed(e,50) playAnimD(e,"runinjured") return 0.05 end) 
asn:NewState("run",function(s,e) USetSpeed(e,280) playAnimD(e,"runfast") return 0.05 end) 
asn:NewState("recall",function(s,e) return playAnimD(e,"recall") end) 
asn:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 

asn:NewState("attack",function(s,e) UAbCast(e,"l_attack_ranged") return  //playAnimD(e,"attack4",true) end) //
	playAnimRandom(e, {"attack1","attack3","attack4"},true) end)

asn:NewState("cast_s1_root",function(s,e) UAbCast(e,"kindred_doa") return 0.1 end)
asn:NewState("cast_s1_f",function(s,e) e:SetVelocity( e:GetForward()*1500+e:GetUp()*100 ) return playAnimD(e,"cast_s1f") end)
asn:NewState("cast_s1_b",function(s,e) e:SetVelocity(-e:GetForward()*1500+e:GetUp()*100 ) return playAnimD(e,"cast_s1b") end)
asn:NewState("cast_s1_r",function(s,e) e:SetVelocity( e:GetRight()*1500+e:GetUp()*100 ) return playAnimD(e,"cast_s1r") end)
asn:NewState("cast_s1_l",function(s,e) e:SetVelocity(-e:GetRight()*1500+e:GetUp()*100 ) return playAnimD(e,"cast_s1l") end)
asn:NewState("cast_s1_b_end",function(s,e) playAnimD(e,"idle") e:SetEyeAngles( NormAngle(e:EyeAngles()+Angle(0,180,0))) return 0.01 end)

asn:NewState("cast_s2",function(s,e) UAbCast(e,"kindred_wolffrenzy") return playAnimD(e,"cast_s2") end)
asn:NewState("cast_s3",function(s,e) UAbCast(e,"kindred_mdread") return playAnimRandom(e,{"cast_s3","cast_s3_2"}) end)
asn:NewState("cast_s4",function(s,e) UAbCast(e,"kindred_respite") return playAnimD(e,"cast_s4") end) 

asn:NewState("social_root",function(s,e) return 0.1 end)
asn:NewState("social_dance",function(s,e) playAnimD(e,"dance") return 0.05 end) 
asn:NewState("social_taunt",function(s,e) return playAnimD(e,"taunt") end) 


asn:NewGroup("g_cast_interruptable",{"cast_s2","cast_s3","cast_s4"})
asn:NewGroup("g_social",{"social_dance","social_taunt"})
asn:NewGroup("g_social_noloop",{"social_taunt"})
asn:NewGroup("g_stand",{"spawn","idle","idlespecial","recall","attack","g_social","g_cast_interruptable"})
asn:NewGroup("g_stand_nosocial",{"idle","idlespecial","recall","attack"})
asn:NewGroup("g_walk",{"walk","walkspecial","walkinjured"})
asn:NewGroup("g_move",{"g_walk","run"})
asn:NewGroup("g_cast_s1",{"cast_s1_f","cast_s1_b","cast_s1_r","cast_s1_l"})
//asn:NewGroup("g_cast_s1",{"cast_s1_f","cast_s1_b_end","cast_s1_r","cast_s1_l"})
asn:NewGroup("g_cast",{"g_cast_s1","cast_s2","cast_s3","cast_s4"})

asn:NewTransition("spawn","idle",onAnimFin)
asn:NewTransition("idle","idlespecial",random1p)
asn:NewTransition("walk","walkspecial",random1p)
asn:NewTransition("idlespecial","idle",onAnimFin)
asn:NewTransition("walkspecial","walk",onAnimFin)
asn:NewTransition("g_stand","walk",function(s,e) return e:KeyDown(IN_FORWARD) end) 
asn:NewTransition("g_walk","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end) 
asn:NewTransition("g_walk","run",function(s,e) return e:KeyDown(IN_SPEED) end)  
asn:NewTransition("run","walk",function(s,e) return !e:KeyDown(IN_SPEED) end)
 
asn:NewTransition("walk","walkinjured",function(s,e) return e:Health()<100 end)
asn:NewTransition("walkinjured","walk",function(s,e) return e:Health()>100 end)
asn:NewTransition("g_stand","recall",function(s,e) return UKeyIsDown(e,KEY_B) end) 
asn:NewTransition("recall","recall_end",onAnimFin)
asn:NewTransition("recall_end","spawn",onAnimFin)

asn:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and UAbIsReady(e,"l_attack_ranged") end) 
//asn:NewTransition("attack","attack",function(s,e) return e:KeyDown(IN_ATTACK) and UAbIsReady(e,"l_attack_ranged") end) 
asn:NewTransition("attack","idle",onAnimFin) 

asn:NewTransition("g_stand","cast_s1_root",function(s,e) return e:KeyDown(IN_JUMP) and UAbIsReady(e,"kindred_doa") end) 
asn:NewTransition("g_move","cast_s1_root",function(s,e) return e:KeyDown(IN_JUMP) and UAbIsReady(e,"kindred_doa") end) 
asn:NewTransition("cast_s1_root","cast_s1_f",function(s,e) return e:KeyDown(IN_FORWARD) end)
asn:NewTransition("cast_s1_root","cast_s1_b",function(s,e) return e:KeyDown(IN_BACK) end)
asn:NewTransition("cast_s1_root","cast_s1_r",function(s,e) return e:KeyDown(IN_MOVERIGHT) end)
asn:NewTransition("cast_s1_root","cast_s1_l",function(s,e) return e:KeyDown(IN_MOVELEFT) end)
asn:NewTransition("cast_s1_root","cast_s1_f",onAnimFin)
//asn:NewTransition("cast_s1_b","cast_s1_b_end",onAnimFin) 

asn:NewTransition("g_stand","cast_s2",function(s,e) return UKeyIsDown(e,KEY_E) and UAbIsReady(e,"kindred_wolffrenzy") end) 
asn:NewTransition("g_stand","cast_s3",function(s,e) return UKeyIsDown(e,KEY_R) and UAbIsReady(e,"kindred_mdread") end) 
asn:NewTransition("g_stand","cast_s4",function(s,e) return UKeyIsDown(e,KEY_F) and UAbIsReady(e,"kindred_respite") end) 


asn:NewTransition("g_cast","idle",onAnimFin) 

asn:NewTransition("g_stand_nosocial","social_root",function(s,e) return UKeyIsDown(e,KEY_LCONTROL) and ( UKeyIsDown(e,KEY_3) or UKeyIsDown(e,KEY_4))  end) 
asn:NewTransition("social_root","social_dance",function(s,e) return UKeyIsDown(e,KEY_3) end) 
asn:NewTransition("social_root","social_taunt",function(s,e) return UKeyIsDown(e,KEY_4) end)  
asn:NewTransition("g_social_noloop","idle",onAnimFin) 
   
   
asn:SetState("spawn")
 
if SERVER then
timer.Create("23480",0.1,0,function()
	asn:Run() 
end) 
end
//    asn:Push({"idle",true})
//timer.Simple(4,function()  
//	_AnPlay(Entity(1),dance2)  
//end)       
      /*                       
timer.Simple(4,function() 
//_AnPlay(Entity(1),runinjured) 
	asn:Push("run") 
end)                       
timer.Simple(5,function()   asn:Push("runinjured") end)       
timer.Simple(6,function()   asn:Push("run") end)           
timer.Simple(7,function()   asn:Pop() end)       
timer.Simple(8,function()   asn:Pop() end)  
*/           
 