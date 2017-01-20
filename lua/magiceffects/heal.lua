AddCSLuaFile()

effect.healRate = 10 //per sec
effect.dispellDelay = 10 //sec
effect.thinkDelay = 1
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		return true
	end 
end
function effect:Think(ent)
	if ent:Health()>0 then
		if ent:GetMaxHealth()>ent:Health() then
			ent:SetHealth( math.Min( ent:Health() + self.healRate, ent:GetMaxHealth()) )
			Util_StopEffect(ent, "healtest")
			Util_ParticleEffect(ent, "healtest", "enchantress_natures_attendants_heal")
		end 
		return true
	end
end
function effect:End(ent)
	Util_StopEffect(ent, "healtest")
end   