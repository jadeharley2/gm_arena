AddCSLuaFile()

ability.icon = "vgui/icons/spells/ShyvanaDragonsDescent.png"
ability.type = "self" 
ability.cooldownDelay = 10
ability.effect = "transform"
ability.form = "shyvana_dragon"

function ability:Begin(ply, trace)  
	local meffect = MagicEffect(self.effect)
	meffect.form = self.form
	meffect:Cast(ply) 
	if self.form == "shyvana_dragon" then
		ply._angraph:SetState("transform")
	end
	return true
end    