AddCSLuaFile()
effect.amount = 10
effect.dmg_type = DMG_SLASH
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		local admg = 1
		if self.owner then admg =  self.owner.stats.attackdamage end
		//local resist = ent.stats.
		local d = DamageInfo()
		d:SetDamage( ent:Health() )
		d:SetAttacker( self.owner )
		d:SetDamageType( self.dmg_type ) 
		ent:TakeDamageInfo( d )
		//ent:TakeDamage(admg,self.owner,NULL)
		return true
	end 
end     