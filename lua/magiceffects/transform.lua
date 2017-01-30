AddCSLuaFile()
effect.form = "shyvana_dragon" 
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		character.Transform(ent,self.form)
		return true
	end 
end    