AddCSLuaFile()
 
ability.type = "self" 
ability.cooldownDelay = 10 
ability.form = "unknown"
 
function ability:Begin(ply, trace)  
	local meffect = MagicEffect("transform")
	meffect.form = self.form
	meffect:Cast(ply)   
	return true
end    