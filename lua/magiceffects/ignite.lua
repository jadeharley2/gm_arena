AddCSLuaFile()
effect.duration = 10
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		ent:Ignite(self.duration)
		return true
	end 
end   