AddCSLuaFile()
ability.icon = "vgui/icons/spells/Katarina_E.png"
ability.type = "self"
ability.cooldownDelay = 2
ability.blinkValid = {
  "player",
  "dager"
}

function ability:Begin(ply,trace)
  if ply:Alive() then
    local entList = ents.FindInBox(trace.Entity:GetPos()-Vector(200,200,100), trace.Entity:GetPos()+Vector(200,200,100))
    for key, ent in pairs(entList) do
      ply:SetPos(trace.Entity:GetPos()+Vector(0,-75,0))
      return true
    end
  end
end
