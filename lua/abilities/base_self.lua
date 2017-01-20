AddCSLuaFile()

ability.type = "self" 
ability.cooldownDelay = 2
ability.effect = "heal"

function ability:Begin(ply, trace)  
	local meffect = MagicEffect(self.effect)
	return meffect:Cast(ply) 
end    