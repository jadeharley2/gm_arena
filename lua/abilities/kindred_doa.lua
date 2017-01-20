AddCSLuaFile()

ability.type = "self"
ability.animation = "attack"
ability.cooldownDelay = 2

function ability:Begin(ply, trace) 
	if ply:Alive() then 
		if ply:KeyDown( IN_FORWARD) then
			Dota.PlaySequence2(ply, "casts1f")
			ply:SetVelocity( ply:GetForward()*1000+ply:GetUp()*1000 )
		elseif ply:KeyDown( IN_BACK) then
			Dota.PlaySequence2(ply, "casts1b")
			ply:SetVelocity( ply:GetForward()*-1000+ply:GetUp()*1000 )
		elseif ply:KeyDown( IN_MOVERIGHT) then
			Dota.PlaySequence2(ply, "casts1r")
			ply:SetVelocity( ply:GetRight()*1000+ply:GetUp()*1000 )
		elseif ply:KeyDown( IN_MOVELEFT) then
			Dota.PlaySequence2(ply, "casts1l")
			ply:SetVelocity( ply:GetRight()*-1000+ply:GetUp()*1000 )
		else
			Dota.PlaySequence2(ply, "casts1f")
			ply:SetVelocity( ply:GetForward()*1000+ply:GetUp()*1000 )
		end
		return true
	end
end

  