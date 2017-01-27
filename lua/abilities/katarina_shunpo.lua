AddCSLuaFile()
ability.icon = "vgui/icons/spells/Katarina_E.png"
ability.type = "self"
ability.cooldownDelay = 2
ability.aimVector = Vector(300,300,200)

function ability:Begin(ply,trace)
  if ply:Alive() then
    local entList = ents.FindInBox(trace.Entity:GetPos()-self.aimVector, trace.Entity:GetPos()+self.aimVector)
    for key, ent in pairs(entList) do
      if (ent:IsPlayer() or ent:IsNPC()) then
        ply:SetPos(trace.Entity:GetPos()+Vector(0,-75,0))
        ply:EmitSound("katarina.shunpo")
        print(ent)
        return true
      end
    end
  else
    return false
  end
end
