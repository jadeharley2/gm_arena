AddCSLuaFile()
effect.amount = 10
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		local admg = 1
		if self.owner then admg =  self.owner.stats.attackdamage end
		//local resist = ent.stats.
		ent:TakeDamage(admg,self.owner,NULL)
		return true
	end 
end     