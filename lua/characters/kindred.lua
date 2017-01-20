AddCSLuaFile()

sound.Add( {
	name = "kindred.bow",
	channel = CHAN_WEAPON,
	volume = { 0.2, 0.4 },
	level = 80,
	pitch = { 90, 110 },
	sound = {
		"heroes/kindred/bow.wav", 
	}
} )
sound.Add( {
	name = "kindred.jump",
	channel = CHAN_BODY,
	volume = { 0.2, 0.4 }, 
	level = 80,
	pitch = { 95, 105 },
	sound = {
		"heroes/kindred/jump1.wav", 
		"heroes/kindred/jump2.wav", 
		"heroes/kindred/jump3.wav", 
	}
} )
sound.Add( {
	name = "kindred.step",
	channel = CHAN_BODY,
	volume = {  0.2, 0.4 }, 
	level = 80,
	pitch = { 95, 105 },
	sound = {
		"heroes/kindred/step1.wav", 
		"heroes/kindred/step2.wav",  
		"heroes/kindred/step3.wav",  
		"heroes/kindred/step4.wav",  
	}
} )
sound.Add( {
	name = "kindred.dance",
	channel = CHAN_BODY,
	volume = {  0.3 }, 
	level = 80,
	pitch = { 100 },
	sound = {
		"heroes/kindred/dance.wav",   
	}
} )
sound.Add( {
	name = "kindred.wolfcast",
	channel = CHAN_WEAPON,
	volume = {  0.2, 0.4 }, 
	level = 80,
	pitch = { 95, 105 },
	sound = {
		"heroes/kindred/wolfcast1.wav", 
		"heroes/kindred/wolfcast2.wav",
		"heroes/kindred/wolfcast3.wav",  
	}
} )

Dota.AddCharacter({  
	name = "kindred",
	model = "models/heroes/kindred/kindred.mdl",
	move_allow_forward45 = true, 
	animations = {
		//format 
		// name = { anims, specials, sounds }
		idle = { {"idle"}, {"idlespecial"},{},loop = true},
		walk = { {"run"}, {"runspecial"},{},loop = true},
		run = { {"runfast"}, {},{},loop = true}, 
		run_injured = { {"runinjured"}, {},{},loop = true},
		attack = { {"attack1","attack3","attack4"}},
		
		casts1f = "cast_s1f",
		casts1b = "cast_s1b",
		casts1r = "cast_s1r",
		casts1l = "cast_s1l",
		casts2 = "cast_s2",
		casts3 = "cast_s3",
		casts32 = "cast_s3_2",
		casts4 = "cast_s4",
		recall = "recall",
		  
		death = "death",
		spawn = "spawn",
		social_1 = {"dance",{},{},loop = true},
		social_2 = "taunt", 
	},  
	spells = {
		{"l_attack_ranged", key = IN_ATTACK}, 
		//{"kindred_mark"}, //passive
		{"kindred_doa", key = IN_JUMP}, 
		{"kindred_wolffrenzy", key = IN_DUCK},
		//{"kindred_mdread"},
		//{"kindred_respite"},
		{"kindred_social", key = IN_ATTACK2}
		
	}, 
	stats = {
		//{base,perLevel}
		health = {540,85}, 
		healthregen = {7,0.55},
		armor = {20,3.5},
		magicresist = {30,0},
		attackdamage = {54,1.7},
		attackspeed = {0.625, 2.5}, //%
		movementspeed = {325,0}, 
	}, 
	speed_walk = 180,
	speed_run = 280, 
	func_onspawn = function(ply)
		if SERVER then
			local e =  ents.Create("base_anim") 
			e:SetModel("models/heroes/kindred/wolf.mdl")
			e:SetPos(ply:EyePos()+ply:GetForward()*20)
			e:Spawn()
			e:PhysicsInitSphere( 0.01, "flesh")
			e:GetPhysicsObject():SetMass(100)
			e:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE)// )
			e:SetGravity( 0 )
			if ply.wolf and ply.wolf != NULL then
				ply.wolf:Remove()
			end
			ply.wolf = e
			
			e:GetPhysicsObject():EnableCollisions( false )
			e:SetSequence(1)
			e:SetAutomaticFrameAdvance( true )
			e:GetPhysicsObject():SetMass(100)
			e:SetModelScale(1.5)
			
			local e2 = ents.Create("prop_dynamic") 
			e2:SetPos(e:GetPos()+Vector(0,0,70))
			e2:SetModel("models/props_junk/PopCan01a.mdl")
			e2:Spawn()
			e2:SetParent(e)
			
			util.SpriteTrail(e2, 0, Color(250/10,100/10,200/10) ,false, 25*1.5, 120, 2, 1 / ( 25*2 +120) * 0.5, "trails/smoke.vmt" )
			local tid = tostring(ply:UserID()).."wolft"
			ply.wolfupdate = timer.Create(tid,0.02,0,function() Dota.heroes.kindred.func_onthink(ply) end)
			timer.Start( tid )
		end
	end,
	func_onthink = function(ply)
		if SERVER then
			if ply.wolf then
				local dir = Vector(200,0,0)
				dir:Rotate( Angle (0,-CurTime()*60,0))
				local tar = ply:EyePos()+ dir -Vector(0,0,20)
				if ply.wfrenzy == true then
					 dir = dir * 3
					 tar = ply.wfrenzypos+ dir -Vector(0,0,20)
				end
				
				local pos = ply.wolf:GetPos()
				local p = ply.wolf:GetPhysicsObject()
				p:SetVelocity((p:GetVelocity()+(tar-pos))*0.5  ) 
				p:SetAngles(p:GetVelocity():Angle())
			end
		end
	end,
	func_ondespawn = function(ply)
		if SERVER then
			local tid = tostring(ply:UserID()).."wolft" 
			timer.Remove( tid )
			if ply.wolf then
				ply.wolf:Remove()
				ply.wolf = nil
			end
		end
	end
})
  
