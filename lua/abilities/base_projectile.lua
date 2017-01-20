AddCSLuaFile()
   
ability.type = "projectile" 
ability.cooldownDelay = 2
ability.effect = "heal"
ability.startpos = "eyepos"
ability.projectile = 
{ 
	model = "models/props_junk/PopCan01a.mdl",
	speed = 100000, 
	mass = 1,
	removeontouch = true,
	removeoneffectstart = true,
	color = Color(0,0,0,0),
}
 
function ability:Begin(ply, trace) 
	if SERVER then
		local spos = ply:GetPos()
		if self.startpos == "eyepos" then
			spos = ply:EyePos()
		elseif self.startpos == "attachment" then
			local att = self.attachment
			if isstring(att) then att = ply:LookupAttachment(att) end
			if att >= 0 then
				spos = ply:GetAttachment(att)
			end
		elseif self.startpos == "world" then
			spos = self.worldposition
		end
		
		if spos then
			local e = ents.Create("prop_physics")
			local pd = self.projectile
			e:SetModel(pd.model)
			e:SetPos(spos)
			e:AddCallback( "PhysicsCollide", function(ent, data) self:OnTouch(ent,data) end)
			e:SetColor(pd.color)
			if pd.color.a != 255 then
				e:SetRenderMode( RENDERMODE_TRANSALPHA ) 
			else
				e:SetRenderMode( RENDERMODE_NORMAL ) 
			end
			e:Spawn()
			//e:SetVelocity( )
			util.SpriteTrail(e, 0, Color(100,200,250) ,true, 20, 0, 1, 1 / ( 20 ) * 0.5, "trails/laser.vmt" )
			e:GetPhysicsObject():SetMass(pd.mass)
			e:GetPhysicsObject():SetVelocityInstantaneous(ply:EyeAngles():Forward()*pd.speed )
			timer.Simple(4,function() if e and e != NULL then e:Remove() end end) 
			//e:SetCollisionGroup( COLLISION_GROUP_WORLD  )
			e.projectileOwner = ply
			e:SetCustomCollisionCheck(true)
			ply:SetCustomCollisionCheck(true)
			//MsgN(ply)
			//MsgN(e)
			//MsgN( constraint.NoCollide(ply, e, 0,0 ))
		end
		
		
		return true
	end
end  

function ability:OnTouch(ent,data)
	if data.HitEntity and data.HitEntity != NULL and data.HitEntity !=game.GetWorld() then 
		local meffect = MagicEffect(self.effect)
		meffect.owner = ent.projectileOwner
		local result = meffect:Cast(data.HitEntity) 
		timer.Simple(0.001, function()
			if self.projectile.removeoneffectstart and ent != NULL then
				ent:SetCollisionGroup( COLLISION_GROUP_WORLD  )
				ent:SetParent(data.HitEntity)
				ent:PhysicsDestroy()//:Remove()
			end
		end)
		return result
	else  
		timer.Simple(0.001, function()
			if self.projectile.removeontouch and ent != NULL then
				ent:SetCollisionGroup( COLLISION_GROUP_WORLD  )
				ent:PhysicsDestroy()//:Remove() 
			end
		end) 
	end
end

hook.Add( "ShouldCollide", "CSH_projectile", function(ent1,ent2)
	if ( ent1:IsPlayer() and ent2.projectileOwner == ent1 ) or
		( ent2:IsPlayer() and ent1.projectileOwner == ent2 ) or 
		( ent1.projectileOwner and ent2.projectileOwner )
		then
		return false
	end
end)
hook.Add( "EntityTakeDamage", "CSH_projectile", function(target, dmginfo)
	if ( dmginfo:GetInflictor().projectileOwner ) then
		return true
	end
end)
 