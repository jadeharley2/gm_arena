AddCSLuaFile() 
effect.damage = 100
function effect:Begin(ent) 
	if SERVER then
		if ent and ent!=NULL then
			local e = ents.Create("env_explosion")
			e:SetPos(ent:GetPos())
			e:SetKeyValue("Magnitude ",tostring(self.damage))
			e:Spawn()  
			e:Fire("Explode") 
			return true 
		end
	end
end   