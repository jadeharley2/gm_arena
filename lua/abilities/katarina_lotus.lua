AddCSLuaFile()
ability.icon = "vgui/icons/spells/Katarina_R.png"
ability.type = "self"
ability.cooldownDelay = 2
ability.damage = 500

function ability:Begin(ply,trace)
  if ply:Alive() then
    local entList = ents.FindInBox(ply:GetPos()-Vector(200,200,100), trace.Entity:GetPos()+Vector(200,200,100))
    for key, ent in pairs(entList) do
      print(ent)
      local dmgInfo = DamageInfo()
      dmgInfo:SetAttacker(ply)
      //dmgInfo:SetInflictor(ent)
      dmgInfo:SetDamage(self.damage)
      ent:TakeDamageInfo(dmgInfo)
    end
    return true
  end
end
