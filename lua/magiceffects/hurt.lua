AddCSLuaFile()
effect.amount = 10
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		ent:TakeDamage(effect.amount,NULL,NULL)
		return true
	end 
end    