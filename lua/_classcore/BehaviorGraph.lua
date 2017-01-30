AddCSLuaFile()

local BehaviorGraphMeta = {}

 
function BehaviorGraphMeta:Run() 
	for k,v in pairs(self._cstate.transitions) do  
		if v[2] then
			if v[2](self,self._ent) then   
				return self:SetState(v[1]) 
			end
		else
			self.anim_end = 0
			return self:SetState(v[1])  
		end 
	end
end
function BehaviorGraphMeta:NewTransition(s1name,s2name,funccond)
	local a1 = self.groups[s1name] 
	if a1 then
		for k,v in pairs(a1.states) do 
			self:NewTransition(v,s2name,funccond) 
		end
	else 
		local s1 = self.states[s1name] 
		if not s1 then MsgN("Warning state not found: "..s1name) end 
		s1.transitions[#s1.transitions+1] = {s2name,funccond}
	end
end
function BehaviorGraphMeta:NewState(name,onEnter,onExit)
	self.states[name] = {
		name = name,
		enter = onEnter, //
		exit = onExit,
		transitions = {}
	}
end
function BehaviorGraphMeta:NewGroup(name,aliasedStates)
	self.groups[name] = {
		name = name,
		states = aliasedStates
	}
end
function BehaviorGraphMeta:SetState(name)  
	local ent = self._ent
	local from = self._cstate
	local to = self.states[name] 
	if to then
		if self._cstate then
			if self._cstate.exit then
				self._cstate.exit(self,ent,to) 
			end
		end
		if self._cstate then
			from = self._cstate 
			if self.debug then MsgN("changing state: ",from.name," => ",to.name) end
		else
			if self.debug then MsgN("starting graph with state: ",to.name) end
		end 
		self._cstate = to
		if self._cstate.enter then 
			self.anim_end = CurTime() + ( self._cstate.enter(self,ent,from) or 0.5 )
		else
			self.anim_end = CurTime()
		end
	else
		ErrorNoHalt("Unknown state: "..name)
	end
end
	     
BehaviorGraphMeta.__index = BehaviorGraphMeta

function BehaviorGraph(ent)
	MsgN("New graph on: "..tostring(ent))
	local t = 
	{
		_ent = ent, 
		states = {}, 
		groups = {},
		anim_end = 0,
	} 
	return setmetatable(t,BehaviorGraphMeta)
end 
    