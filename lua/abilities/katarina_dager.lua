AddCSLuaFile()
ability.icon = "vgui/icons/spells/Katarina_Q.png"
ability.type = "self"
ability.animation = "attack"
ability.cooldownDelay = 2

function ability:Begin(ply,trace)
  if ply:Alive() then
    print(trace)
    PrintTable(trace)
  end
end
