AddCSLuaFile()

ability.base = "base_projectile"
ability.type = "self"
ability.animation = "attack"
ability.cooldownDelay = 0.1
ability.effect = "l_hurt"

  
function ability:Begin(ply, trace)  
	if SERVER and ply:Alive() and 
	not (
		ply:KeyDown( IN_FORWARD) or ply:KeyDown( IN_BACK) or
		ply:KeyDown( IN_MOVERIGHT) or ply:KeyDown( IN_MOVELEFT))
	then 
		if self._base.Begin(self,ply,trace) then
			Dota.PlaySequence2(ply, "attack",true)   
			return true
		end
		return true
	end
end           