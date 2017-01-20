AddCSLuaFile()

ability.type = "self"
ability.animation = "attack"
ability.cooldownDelay = 0.5

function ability:Begin(ply, trace) 
	if SERVER and ply:Alive() and 
	not (
		ply:KeyDown( IN_FORWARD) or ply:KeyDown( IN_BACK) or
		ply:KeyDown( IN_MOVERIGHT) or ply:KeyDown( IN_MOVELEFT))
	then
		Dota.PlaySequence2(ply, "attack",true)  
		local e = ents.Create("prop_physics")
		e:SetModel("models/props_junk/PopCan01a.mdl")
		e:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
		e:SetPos(ply:EyePos()+ply:GetForward()*20)
		e:Spawn()
		//e:SetVelocity( )
		util.SpriteTrail(e, 0, Color(100,200,250) ,true, 20, 0, 1, 1 / ( 20 ) * 0.5, "trails/laser.vmt" )
		e:GetPhysicsObject():SetMass(100)
		e:GetPhysicsObject():SetVelocityInstantaneous(ply:EyeAngles():Forward()*100000 )
		timer.Simple(4,function() e:Remove() end)
		return true
	end
end  