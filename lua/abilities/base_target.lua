AddCSLuaFile()

ability.type = "target" 
ability.cooldownDelay = 2
ability.effect = "heal"
ability.range = 150

function ability:Begin(ply, trace)  
	if trace.Entity then
		if trace.Entity:GetPos():Distance(ply:GetPos()) < self.range then
			local meffect = MagicEffect(self.effect)
			meffect.owner = ply
			return meffect:Cast(trace.Entity) 
		end
	end
	return false
end    