AddCSLuaFile()

AbilitiesList =  {}//AbilitiesList or
local AB = {}
    
function Ability(baseeffect)
	local m = nil
	if baseeffect then
		local b = AbilitiesList[baseeffect] 
		if b then
			m = table.Copy(b)
		else
			MsgN( "Magic effect "..baseeffect.." not found!\n" )
			return nil
		end
	else
		m = {
			nextcast = 0
		}
	end  
	setmetatable(m,AB)
	return m
end 
  
function AddAbility(name,effect)
	AbilitiesList[name] = effect
end    
     

function LoadAbilities()
	local ray = file.Find( "abilities/*.lua", "LUA"  )
	for k,v in pairs(ray) do 
		local cname = string.sub( v, 1, #v-4 )
		MsgN("ability: "..cname)
		AddCSLuaFile("lua/abilities/"..v)
		AddAbility(cname, UTILS_AddClass("abilities/"..v,Ability,"ability"))
	end
end

    

//props:
//type (self,target)
//dispellDelay
//thinkDelay  
//cooldownDelay
 
//funcs:
//self:Begin(ent, trace) - returns if effect is can be applied
//self:Think(ent)
//self:End(ent)

function AB:Cast(ent) 
	self.nextcast = self.nextcast or 0
	if self.Begin != nil and self.nextcast<CurTime() then
		local trace = 0
		if self.type == "target" then trace = ent:GetEyeTrace() end
		if self:Begin(ent,trace) then
			//MsgN("cast")
			ent.meffects = ent.meffects or {}
			self.id = #ent.meffects
			ent.meffects[self.id ] = self 
			self.tid = "think".. tostring(math.random( 1, 99999 ))
			self.target = ent
			if self.cooldownDelay then
				self.nextcast = CurTime()+self.cooldownDelay
			end
			if(self.Think != nil) then
				timer.Create(self.tid,self.thinkDelay or 1,0, function()
					//MsgN("think")
					if not self:Think(ent) then
						timer.Destroy(self.tid)
					end
				end)
			end
			if (  self.dispellDelay !=nil and self.dispellDelay>0) then
				self.did = "dispell".. tostring(math.random( 1, 99999 ))
				timer.Create(self.did,self.dispellDelay,1, function()
					self:Dispell()
				end)
			end
			return true
		end
	end
	return false
end
function AB:Dispell()
	local ent = self.target
	timer.Destroy(self.tid)
	timer.Destroy(self.did)
	if(self.End !=nil) then self:End(ent) end
	ent.meffects[self.id] = nil
	//MsgN("dispelled")
end

AB.__index = AB
//AB.__newindex = AB
 
LoadAbilities()
 