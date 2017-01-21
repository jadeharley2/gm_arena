AddCSLuaFile()

ability.type = "self"  
ability.cooldownDelay = 0.01  

function ability:Begin(ply, trace) 
	if ply:Alive() and SERVER then 
		if UTILS_IsKeysPressed(ply,KEY_1) then
			Dota.PlaySequence2(ply, "social_1",true) 
		elseif UTILS_IsKeysPressed(ply,KEY_2) then
			Dota.PlaySequence2(ply, "social_2",true) 
		elseif UTILS_IsKeysPressed(ply,KEY_3) then
			Dota.PlaySequence2(ply, "social_3",true) 
		elseif UTILS_IsKeysPressed(ply,KEY_4) then
			Dota.PlaySequence2(ply, "social_4",true) 
		end
		return true
	end
end 
     