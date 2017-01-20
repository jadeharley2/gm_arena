AddCSLuaFile()
effect.amount = 10
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		local admg = self.owner.stats.attackdamage or 1
		//local resist = ent.stats.
		ent:TakeDamage(admg,self.owner,NULL)
		return true
	end 
end     