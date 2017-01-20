AddCSLuaFile()

ability.type = "target" 
ability.cooldownDelay = 2
ability.effect = "heal"

function ability:Begin(ply, trace)  
	if trace.Entity then
		local meffect = MagicEffect(self.effect)
		return meffect:Cast(trace.Entity) 
	end
	return false
end    