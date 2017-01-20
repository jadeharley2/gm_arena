AddCSLuaFile()

ability.type = "self"  
ability.cooldownDelay = 0.5    

function ability:Begin(ply, trace) 
	if ply:Alive() and SERVER then 
		Dota.PlaySequence2(ply, "social_1",true) 
		return true
	end
end 
    