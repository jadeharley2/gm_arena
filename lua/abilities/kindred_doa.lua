AddCSLuaFile()

ability.type = "self"
ability.animation = "attack"
ability.cooldownDelay = 2
ability.jumppower = 1000

function ability:Begin(ply, trace) 
	if ply:Alive() then 
		local p = self.jumppower
		//if ply:KeyDown( IN_FORWARD) then
		//	Dota.PlaySequence2(ply, "casts1f")
		//	ply:SetVelocity( ply:GetForward()*p+ply:GetUp()*p )
		//elseif ply:KeyDown( IN_BACK) then
		//	Dota.PlaySequence2(ply, "casts1b")
		//	ply:SetVelocity( ply:GetForward()*-p+ply:GetUp()*p )
		//elseif ply:KeyDown( IN_MOVERIGHT) then
		//	Dota.PlaySequence2(ply, "casts1r")
		//	ply:SetVelocity( ply:GetRight()*p+ply:GetUp()*p )
		//elseif ply:KeyDown( IN_MOVELEFT) then
		//	Dota.PlaySequence2(ply, "casts1l")
		//	ply:SetVelocity( ply:GetRight()*-p+ply:GetUp()*p )
		//else
		//	Dota.PlaySequence2(ply, "casts1f")
		//	ply:SetVelocity( ply:GetForward()*p+ply:GetUp()*p )
		//end
		return true
	end
end

  