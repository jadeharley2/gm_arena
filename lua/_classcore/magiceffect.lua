AddCSLuaFile()

MagicEffectList = MagicEffectList or {}
local ME = {}
 
function MagicEffect(baseeffect)
	local m = nil
	if baseeffect then
		local b = MagicEffectList[baseeffect] 
		if b then
			m = table.Copy(b)
		else
			MsgN( "Magic effect "..baseeffect.." not found!\n" )
			return nil
		end
	else
		m = {} 
	end
	setmetatable(m,ME)
	return m
end

function AddMagicEffect(name,effect)
	MagicEffectList[name] = effect
end


function LoadEffects()
	local ray = file.Find( "magiceffects/*.lua", "LUA"  )
	for k,v in pairs(ray) do 
		local cname = string.sub( v, 1, #v-4 )
		MsgN("magic effect: "..cname)
		AddCSLuaFile("lua/magiceffects/"..v)
		AddMagicEffect(cname, UTILS_AddClass("magiceffects/"..v,MagicEffect,"effect"))
	end
end



//props:
//dispellDelay
//thinkDelay
 
//funcs:
//self:Begin(ent) - returns if effect is can be applied
//self:Think(ent)
//self:End(ent)

function ME:Cast(ent)
	if self.Begin != nil then
		if self:Begin(ent) then
			//MsgN("cast")
			ent.meffects = ent.meffects or {}
			self.id = #ent.meffects
			ent.meffects[self.id ] = self 
			self.tid = "think".. tostring(math.random( 1, 99999 ))
			self.target = ent
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
function ME:Dispell()
	local ent = self.target
	timer.Destroy(self.tid)
	timer.Destroy(self.did)
	if(self.End !=nil) then self:End(ent) end
	ent.meffects[self.id] = nil
	//MsgN("dispelled")
end

ME.__index = ME
//ME.__newindex = ME
 

LoadEffects()