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
		local spos = ply:GetPos()
		local endpos = trace.Entity:GetPos()+Vector(0,-75,0)
		LParticleEffectDispatch( "ps_katarina","shunpo_flash", 4,NULL,-1,spos + Vector(0,0,35) )
        ply:SetPos(endpos)
        ply:EmitSound("katarina.shunpo")
		timer.Simple(0.2,function()
			LParticleEffectDispatch( "ps_katarina","shunpo_flash", 4,ply,-1,  Vector(0,0,35)  )end)
        print(ent)
        return true
      end
    end
  else
    return false
  end
end
