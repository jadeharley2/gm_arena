AddCSLuaFile()

           
LPEFFECT_SPAWN    = 1 //(id,name)
LPEFFECT_START    = 2 //(id,nodename)
LPEFFECT_STOP     = 3 //(id,nodename)
LPEFFECT_REMOVE   = 4 //(id)
LPEFFECT_SETPOINT = 5 //(id,pid,ent,attid,pos)

LPEFFECT_LIST = LPEFFECT_LIST or {} //current spawned effect list

	       
LuaPEffectList = LuaPEffectList or {}
local ME = {}
   
function StopAllLParticleEffects()
	for k,v in pairs(LPEFFECT_LIST) do
		v:Remove()
	end 
end
function LParticleEffectDispatch(effect,subeffect,timeout,ent,attid,pos)
	 
	local effect = LParticleEffect(effect) 
	if effect._name then
		effect:Spawn()
		if ent then
			effect:SetPoint(1,ent,attid,pos)
		end
		effect:Start(subeffect)
		if timeout then
			if timeout > 0 then
				timer.Simple(timeout,function() effect:Remove() end)
			else
				effect:Remove()
			end 
		end
	end
	
end      
function LParticleEffect(baseeffect)
	local m = nil
	if baseeffect then
		local b = LuaPEffectList[baseeffect] 
		if b then
			m = table.Copy(b)
		else
			MsgN( "Lua particle effect "..baseeffect.." not found!\n" )
			return nil
		end
	else
		m = {} 
	end 
	setmetatable(m,ME)
	return m
end 

function AddLParticleEffect(name,effect)
	effect._name = name
	LuaPEffectList[name] = effect
end
 
function LoadLParticleEffects()
	local ray = file.Find( "lparticles/*.lua", "LUA"  ) 
	for k,v in pairs(ray) do 
		local cname = string.sub( v, 1, #v-4 )
		MsgN("lua particle effect: "..cname)
		AddCSLuaFile("lua/lparticles/"..v)
		AddLParticleEffect(cname, UTILS_AddClass("lparticles/"..v,LParticleEffect,"effect"))
	end
end



//props: 
//_id (if spawned)
//pos
//nodes [ 
//	_emmiter
//	_particles
//	_particleCount
//	pos
//	material
//	
//]
//funcs: 
if SERVER then 
	function ME:Spawn()
		if not self._id then
			local id = #LPEFFECT_LIST+1
			self._id = id
			LPEFFECT_LIST[id] = self
			net.Start( "arena_lpeffect" )
			net.WriteInt(id,32)
			net.WriteInt(LPEFFECT_SPAWN,8)
			net.WriteString(self._name)
			net.Broadcast()
		end
	end
	function ME:Remove()
		local id = self._id
		if id then
			net.Start( "arena_lpeffect" )
			net.WriteInt(id,32)
			net.WriteInt(LPEFFECT_REMOVE,8) 
			net.Broadcast()
			LPEFFECT_LIST[id] = nil
			self._id = nil
		end
	end
	function ME:Restart(nodename) 
		self:Stop(nodename)
		self:Start(nodename) 
	end
	function ME:Start(nodename)  
		local id = self._id
		if not id then
			self:Spawn()
			id = self._id 
		end
		local node = self.nodes[nodename]
		if id and node then
			net.Start( "arena_lpeffect" )
			net.WriteInt(id,32)
			net.WriteInt(LPEFFECT_START,8) 
			net.WriteString(nodename)
			net.Broadcast()
			if node.child then 
				for k,v in pairs(node.child) do
					if v!=nodename then
						self:Start(v) 
						MsgN(v) 
					end
				end
			end
		end 
	end
	function ME:Stop(nodename) 
		local id = self._id
		local node = self.nodes[nodename]
		if id and node then
			net.Start( "arena_lpeffect" )
			net.WriteInt(id,32)
			net.WriteInt(LPEFFECT_STOP,8) 
			net.WriteString(nodename)  
			net.Broadcast()
		end 
	end      
	function ME:SetPoint(id, ent,attachmentid,pos)
		self._cpoints = self._cpoints or {} 
		self._cpoints[id] = {ent,attachmentid,pos}
		local sid = self._id 
		if sid then
			net.Start( "arena_lpeffect" )
			net.WriteInt(sid,32)
			net.WriteInt(LPEFFECT_SETPOINT,8) 
			net.WriteInt(id,32)
			net.WriteEntity(ent)
			net.WriteInt(attachmentid,32) 
			net.WriteVector(pos)
			net.Broadcast()
		end 
	end
end  

if CLIENT then 
	function ME:AddParticle(node) 
		node._particles = node._particles or {}
		node._emitter = node._emitter or ParticleEmitter( node.pos or self.pos or Vector(0,0,0), node.use3D or false )
		local particle = node._emitter:Add(node.material,Vector(0,0,0))//node.material
		node._particles[particle] = particle
		node._particleCount = (node._particleCount or 0) + 1
		//particle:SetStartSize(5)
		//particle:SetStartAlpha(1)  
		particle:SetAirResistance( node.drag or 0 )
		particle:SetVelocity( node.startvel or VectorRand() * 50 )
		particle:SetLifeTime( node.lifetime or 0 )
		particle:SetDieTime( node.dietime or 0.5 ) 
		particle:SetStartAlpha( node.startalpha or 255 )
		particle:SetEndAlpha( node.endalpha or  0 )
		particle:SetStartSize( node.startsize or 3 )  
		particle:SetEndSize( node.endsize or 0 )   
		particle:SetRoll( node.roll or math.Rand( 0, 360 ) )
		particle:SetRollDelta( node.rolldelta or math.Rand( -200, 200 ) )  
		particle:SetGravity( node.gravity or  Vector( 0, 0, 1000 ) )
		
		for k,v in pairs(node.init) do v.func(self,node,particle,v) end
		return particle
	end
	function ME:AddTimedCast(node,delay,repeatcount,func)
		node._timers = node._timers or {}
		local tid = #node._timers+1
		local tsid = "lpe_"..tostring(self._id).."_"..tostring(tid)
		timer.Create(tsid,delay,repeatcount,func)
		node._timers[tid] = tsid
	end
	function ME:AbortTimers(node)
		if node._timers then 
			for k,v in pairs(node._timers) do
				timer.Remove( v )
			end
			node._timers = nil 
		end          
	end
	function ME:GetPoint(id)
		if self._cpoints then
			local cp = self._cpoints[id] 
			if cp[1] and cp[1] != NULL then
				local adata = cp[1]:GetAttachment( cp[2] )
				local p = cp[3]
				if not adata then //entity localpos
					local f = cp[1]:GetForward()
					local r = cp[1]:GetRight()
					local u = cp[1]:GetUp()
					if cp[1]:EntIndex()==0 then
						f = Vector(1,0,0) 
						r = Vector(0,1,0)
						u = Vector(0,0,1)
					end
					return cp[1]:GetPos() + f*p.x+r*p.y+u*p.z
				else//attachmet localpos
					local a = adata.ang
					return adata.pos + a:Forward()*p.x+a:Right()*p.y+a:Up()*p.z
				end
			else //absolute pos 
				return cp[3]
			end
		else 
			return Vector(0,0,0)
		end
	end

end
ME.__index = ME
//ME.__newindex = ME
 

LoadLParticleEffects()



if SERVER then
	util.AddNetworkString( "arena_lpeffect" ) 
end
if CLIENT then
	//LPEFFECT_LIST = LPEFFECT_LIST or {}
	local function lpe_Remove(eid)
		local effect = LPEFFECT_LIST[eid]
		if(effect) then 
			if effect.nodes then
				for k,v in pairs(effect.nodes) do
					if v._emmiter then v._emmiter:Finish() v._emmiter = nil end 
					effect:AbortTimers(v)
				end
			end
			LPEFFECT_LIST[eid] = nil
		end 
	end
	local function lpe_Spawn(eid,name) 
		local oldeffect = LPEFFECT_LIST[eid]
		if(oldeffect) then lpe_Remove(eid) end
		local effect = LParticleEffect(name) 
		effect._id = eid
		LPEFFECT_LIST[eid] = effect
		return effect
	end
	local function lpe_Start(eid,nodename)
		local effect = LPEFFECT_LIST[eid]
		if(effect) then 
			local node = effect.nodes[nodename]
			if(node) then
				if node._emitter then
					node._emitter:Finish()
					node._emitter = nil 
					node._particles = nil
					node._particleCount = 0
				end
				for k,v in pairs(node.emitter) do
					v.func(effect,node,v)
				end
			end
		end
	end
	local function lpe_Stop(eid,nodename)
		local effect = LPEFFECT_LIST[eid]
		if(effect) then 
			local node = effect.nodes[nodename]
			if node._emmiter then node._emmiter:Finish() node._emmiter = nil end 
			node._particles = nil
			node._particleCount = 0
			effect:AbortTimers(node)
		end
	end
	local function lpe_SetCpoint(eid,pid,ent,attid,pos)
		local effect = LPEFFECT_LIST[eid]
		if(effect) then 
			effect._cpoints = effect._cpoints or {} 
			effect._cpoints[pid] = {ent,attid,pos}
		end
	end
	
	local function nReceive( len, pl )
		local eid = net.ReadInt(32)
		local etype = net.ReadInt(8)
		if etype == LPEFFECT_SPAWN then
			local efftype = net.ReadString() 
			local effect = lpe_Spawn(eid,efftype)
		elseif etype == LPEFFECT_REMOVE then
			lpe_Remove(eid)
		elseif etype == LPEFFECT_START then
			local node = net.ReadString()
			lpe_Start(eid,node)
		elseif etype == LPEFFECT_STOP then
			local node = net.ReadString()
			lpe_Stop(eid,node)
		elseif etype == LPEFFECT_SETPOINT then
			local pid = net.ReadInt(32)
			local ent = net.ReadEntity()
			local attid = net.ReadInt(32)
			local pos = net.ReadVector()
			lpe_SetCpoint(eid,pid,ent,attid,pos)
		end
	end 
	net.Receive( "arena_lpeffect", nReceive)
	
	  
	
	//helper functions  
	function ps_emit_instantaneously(effect,node,argtab)
		local ast = argtab.start_time   
		if ast and ast>0 then 
			effect:AddTimedCast(node,ast,1, function()
				for	k=1,(argtab.count or 0) do
					effect:AddParticle(node)
				end 
			end)
		else
			for	k=1,(argtab.count or 0) do
				effect:AddParticle(node)
			end 
		end
	end
	function ps_emit_continuously(effect,node,argtab)
		local ast = argtab.start_time
		local pps =  argtab.pps or 10
		local pspawn = 1
		local timing = 1/pps
		if pps >100 then 
			timing = 0.01
			pspawn =math.floor( pps/100)
		end
		if ast and ast>0 then 
			effect:AddTimedCast(node,ast,1, function() 
				effect:AddTimedCast(node,timing,0, function()
					for k=1,pspawn do effect:AddParticle(node) end
				end)
			end)
		else 
			effect:AddTimedCast(node,timing,0, function() 
				for k=1,pspawn do effect:AddParticle(node) end
			end)
		end
	end
	function ps_init_abspos(effect,node,particle,argtab)
		particle:SetPos(argtab.pos) 
	end
	function ps_init_cpos(effect,node,particle,argtab)
		particle:SetPos(effect:GetPoint(argtab.id)) 
	end
	function ps_init_poscube(effect,node,particle,argtab)
		local pos = VectorRand()*(argtab.max-argtab.min)*0.5+argtab.min
		particle:SetPos(pos)
		
	end
		
	
	
	
	
	
	
end





