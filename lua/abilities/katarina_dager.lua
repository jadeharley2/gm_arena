AddCSLuaFile()
ability.base = "base_projectile"
ability.icon = "vgui/icons/spells/Katarina_Q.png"
ability.type = "self"
ability.cooldownDelay = 2
ability.effect = "l_hurt"
ability.projectile = {
  removeontouch = false
}

function ability:Begin(ply,trace)
  if ply:Alive() then
    if self._base.Begin(self,ply,trace) then
      ply:EmitSound("katarina.dager")
			return true
		end
  end
end
