AddCSLuaFile()
   
ability.type = "projectile" 
ability.cooldownDelay = 2
ability.effect = "heal"
ability.startpos = "eyepos"
ability.sound = nil
ability.projectile = 
{ 
	model = "models/props_junk/PopCan01a.mdl",
	speed = 100000, 
	mass = 1,
	removeontouch = true,
	removeoneffectstart = true,
	color = Color(0,0,0,0),
	trailcolor = Color(100,200,250),
	trailwidthstart = 20,
	trailwidthend = 0,
	trailmaterial = "trails/laser.vmt",
	hitsound = nil,
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
				spos = (ply:GetAttachment(att) or {}).Pos
			end 
		elseif self.startpos == "world" then
			spos = self.worldposition
		end
		if self.sound then 
			ply:EmitSound( self.sound )
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
			timer.Simple(4,function() if e and e != NULL then e:Remove() end end) 
			e.ab = self
			e.projectileOwner = ply
			//e:SetVelocity( )
			local material =pd.trailmaterial or "trails/laser.vmt" 
			if not string.EndsWith( material, ".vmt" ) then
				material = material..".vmt"
			end
			util.SpriteTrail(e, 0, pd.trailcolor ,true, pd.trailwidthstart, pd.trailwidthend, 1,
				1 / ( pd.trailwidthstart+pd.trailwidthend ) * 0.5, material)
				
				
			local targetVel = (trace.HitPos  - spos):GetNormalized()*pd.speed
			e:PhysicsInitSphere( 2, "default_silent" )
			e:SetCollisionBounds( Vector( -2, -2, -2 ), Vector( 2, 2, 2 ) )
			e:GetPhysicsObject():SetMass(pd.mass)
			e:GetPhysicsObject():SetVelocityInstantaneous(targetVel)//ply:EyeAngles():Forward()*pd.speed )
			//e:SetCollisionGroup( COLLISION_GROUP_WORLD  )
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
	if ent.ab then
		if ent.ab.projectile.hitsound then
			ent:EmitSound( ent.ab.projectile.hitsound )
		end
	end
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
 