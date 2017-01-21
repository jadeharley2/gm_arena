AddCSLuaFile()

local BehaviorGraphMeta = {}

 
function BehaviorGraphMeta:Run() 
	//if self.cooldown < CurTime() then 
		for k,v in pairs(self._cstate._transitions) do 
			if v[2] then
				if v[2](self,self._ent) then   
					self:SetState(v[1]) 
				end
			else
				self.anim_end = 0
				self:SetState(v[1])  
			end 
		end
	//end
end
function BehaviorGraphMeta:NewTransition(s1name,s2name,funccond)
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
function BehaviorGraphMeta:NewState(name,onEnter,onExit)
	self._states[name] = {
		name = name,
		enter = onEnter, //
		exit = onExit,
		_transitions = {}
	}
end
function BehaviorGraphMeta:NewGroup(name,aliasedStates)
	self._groups[name] = {
		name = name,
		states = aliasedStates
	}
end
function BehaviorGraphMeta:SetState(name)  
	local ent = self._ent
	local from = self._cstate
	local to = self._states[name]  
	if self._cstate then
		if self._cstate.exit then
			self._cstate.exit(self,ent,to) 
		end
	end
	if self._cstate then
		from = self._cstate
		//MsgN("changing state: ",from.name," => ",to.name)
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
	     
BehaviorGraphMeta.__index = BehaviorGraphMeta

function BehaviorGraph(ent)
	MsgN("New graph on: "..tostring(ent))
	local t = 
	{
		_ent = ent, 
		_states = {}, 
		_groups = {},
		anim_end = 0,
	} 
	return setmetatable(t,BehaviorGraphMeta)
end 
    