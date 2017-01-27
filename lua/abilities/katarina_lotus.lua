AddCSLuaFile()
ability.icon = "vgui/icons/spells/Katarina_R.png"
ability.type = "self"
ability.cooldownDelay = 2
ability.thinkDelay = 0.3
ability.dispellDelay = 5
ability.damage = 20

function ability:DamageDealing(ply)
  if ply:Alive() then
  local entList = ents.FindInBox(ply:GetPos()-Vector(200,200,100), ply:GetPos()+Vector(200,200,100))
  for key, ent in pairs(entList) do
    if (ent:GetClass() != "player") then
      local dmgInfo = DamageInfo()
      dmgInfo:SetAttacker(ply)
      //dmgInfo:SetInflictor(ent)
      dmgInfo:SetDamage(self.damage)
      //dmgInfo:SetReportedPosition(ply:GetPos())
      ent:TakeDamageInfo(dmgInfo)
    end
  end
  return true
end
end

function ability:Begin(ply,trace)
    ply:EmitSound("katarina.lotus")
    return self:DamageDealing(ply)
end

function ability:Think(ply)
  self:DamageDealing(ply)
return true
end

function ability:End(ply)
  ply:StopSound("katarina.lotus")
end
