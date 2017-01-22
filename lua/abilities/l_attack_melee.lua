AddCSLuaFile()

ability.base = "base_target"  
ability.cooldownDelay = 0.5
ability.effect = "l_hurt" 

  
function ability:Begin(ply, trace)  
	if not self.initialised and ply.dotahero then  
		table.Merge(self, ply.dotahero.ab_basicattack or {})
		self.initialised = true
	end 
	if SERVER and ply:Alive() and 
	not (
		ply:KeyDown( IN_FORWARD) or ply:KeyDown( IN_BACK) or
		ply:KeyDown( IN_MOVERIGHT) or ply:KeyDown( IN_MOVELEFT))
	then 
		if self._base.Begin(self,ply,trace) then
			//Dota.PlaySequence2(ply, "attack",true)   
		end 
	end
	
	return true
end           