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
		social_3 = "dance",
		social_4 = "taunt",  
	},  
	spells = { 
		{"l_attack_ranged"}, //, inkey = IN_ATTACK
		//{"kindred_mark"}, //passive
		{"kindred_doa"}, //, key = KEY_SPACE
		{"kindred_wolffrenzy", key = KEY_R},
		//{"kindred_mdread"},
		//{"kindred_respite"},
		//{"l_social", key = KEY_LCONTROL}
		
	}, 
	stats = {
		//{base,perLevel}
		health = {540,85}, 
		healthregen = {7,0.55}, 
		armor = {20,3.5},
		magicresist = {30,0},
		attackdamage = {54,1.7},
		attackspeed = {0.1625, 2.5}, //%
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
	end,
	func_behavior = function(ply,asn)
		asn:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"idlein") end)

		asn:NewState("idle",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"idle") return 0.05 end)
		asn:NewState("idlespecial", function(s,e) return BGACT.PANIM(e,"idlespecial") end) 
		asn:NewState("walk",function(s,e) BGACT.SETSPD(e,180) BGACT.PANIM(e,"run") return 0.05 end) 
		asn:NewState("walkspecial",function(s,e) return BGACT.PANIM(e,"runspecial") end) 
		asn:NewState("walkinjured",function(s,e) BGACT.SETSPD(e,50) BGACT.PANIM(e,"runinjured") return 0.05 end) 
		asn:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"runfast") return 0.05 end) 
		asn:NewState("recall",function(s,e) return BGACT.PANIM(e,"recall") end) 
		asn:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 

		asn:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_ranged") return  //BGACT_PANIM(e,"attack4",true) end) //
			BGACT.PANIMRND(e, {"attack1","attack3","attack4"},true) end)
		 
		asn:NewState("cast_s1_root",function(s,e) BGACT.ABCAST(e,"kindred_doa") return 0.1 end)
		asn:NewState("cast_s1_f",function(s,e) e:SetVelocity( e:GetForward()*1500+e:GetUp()*100 ) return BGACT.PANIM(e,"cast_s1f") end)
		asn:NewState("cast_s1_b",function(s,e) e:SetVelocity(-e:GetForward()*1500+e:GetUp()*100 ) return BGACT.PANIM(e,"cast_s1b") end)
		asn:NewState("cast_s1_r",function(s,e) e:SetVelocity( e:GetRight()*1500+e:GetUp()*100 ) return BGACT.PANIM(e,"cast_s1r") end)
		asn:NewState("cast_s1_l",function(s,e) e:SetVelocity(-e:GetRight()*1500+e:GetUp()*100 ) return BGACT.PANIM(e,"cast_s1l") end)
		asn:NewState("cast_s1_b_end",function(s,e) BGACT.PANIM(e,"idle") e:SetEyeAngles( NormAngle(e:EyeAngles()+Angle(0,180,0))) return 0.01 end)

		asn:NewState("cast_s2",function(s,e) BGACT.ABCAST(e,"kindred_wolffrenzy") return BGACT.PANIM(e,"cast_s2") end)
		asn:NewState("cast_s3",function(s,e) BGACT.ABCAST(e,"kindred_mdread") return BGACT.PANIMRND(e,{"cast_s3","cast_s3_2"}) end)
		asn:NewState("cast_s4",function(s,e) BGACT.ABCAST(e,"kindred_respite") return BGACT.PANIM(e,"cast_s4") end) 

		asn:NewState("social_root",function(s,e) return 0.1 end)
		asn:NewState("social_dance",function(s,e) BGACT_PANIM(e,"dance") return 0.05 end) 
		asn:NewState("social_taunt",function(s,e) return BGACT_PANIM(e,"taunt") end) 


		asn:NewGroup("g_cast_interruptable",{"cast_s2","cast_s3","cast_s4"})
		asn:NewGroup("g_social",{"social_dance","social_taunt"})
		asn:NewGroup("g_social_noloop",{"social_taunt"})
		asn:NewGroup("g_stand",{"spawn","idle","idlespecial","recall","attack","g_social","g_cast_interruptable"})
		asn:NewGroup("g_stand_nosocial",{"idle","idlespecial","recall","attack"})
		asn:NewGroup("g_walk",{"walk","walkspecial","walkinjured"})
		asn:NewGroup("g_move",{"g_walk","run"})
		asn:NewGroup("g_cast_s1",{"cast_s1_f","cast_s1_b","cast_s1_r","cast_s1_l"})
		//asn:NewGroup("g_cast_s1",{"cast_s1_f","cast_s1_b_end","cast_s1_r","cast_s1_l"})
		asn:NewGroup("g_cast",{"g_cast_s1","cast_s2","cast_s3","cast_s4"})

		asn:NewTransition("spawn","idle",BGCOND.ANMFIN)
		asn:NewTransition("idle","idlespecial",BGCOND.RND1P)
		asn:NewTransition("walk","walkspecial",BGCOND.RND1P)
		asn:NewTransition("idlespecial","idle",BGCOND.ANMFIN) 
		asn:NewTransition("walkspecial","walk",BGCOND.ANMFIN)
		asn:NewTransition("g_stand","walk",function(s,e) return e:KeyDown(IN_FORWARD) end) 
		asn:NewTransition("g_walk","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end) 
		asn:NewTransition("g_walk","run",function(s,e) return e:KeyDown(IN_SPEED) end)  
		asn:NewTransition("run","walk",function(s,e) return !e:KeyDown(IN_SPEED) end)
		 
		asn:NewTransition("walk","walkinjured",function(s,e) return e:Health()<100 end)
		asn:NewTransition("walkinjured","walk",function(s,e) return e:Health()>100 end)
		asn:NewTransition("g_stand","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end) 
		asn:NewTransition("recall","recall_end",BGCOND.ANMFIN)
		asn:NewTransition("recall_end","spawn",BGCOND.ANMFIN)

		asn:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and UAbIsReady(e,"l_attack_ranged") end) 
		//asn:NewTransition("attack","attack",function(s,e) return e:KeyDown(IN_ATTACK) and UAbIsReady(e,"l_attack_ranged") end) 
		asn:NewTransition("attack","idle",BGCOND.ANMFIN) 

		asn:NewTransition("g_stand","cast_s1_root",function(s,e) return e:KeyDown(IN_JUMP) and UAbIsReady(e,"kindred_doa") end) 
		asn:NewTransition("g_move","cast_s1_root",function(s,e) return e:KeyDown(IN_JUMP) and UAbIsReady(e,"kindred_doa") end) 
		asn:NewTransition("cast_s1_root","cast_s1_f",function(s,e) return e:KeyDown(IN_FORWARD) end)
		asn:NewTransition("cast_s1_root","cast_s1_b",function(s,e) return e:KeyDown(IN_BACK) end)
		asn:NewTransition("cast_s1_root","cast_s1_r",function(s,e) return e:KeyDown(IN_MOVERIGHT) end)
		asn:NewTransition("cast_s1_root","cast_s1_l",function(s,e) return e:KeyDown(IN_MOVELEFT) end)
		asn:NewTransition("cast_s1_root","cast_s1_f",BGCOND.ANMFIN)
		//asn:NewTransition("cast_s1_b","cast_s1_b_end",BGCOND_ANMFIN) 

		asn:NewTransition("g_stand","cast_s2",function(s,e) return BGUTIL.KPRESS(e,KEY_E) and UAbIsReady(e,"kindred_wolffrenzy") end) 
		asn:NewTransition("g_stand","cast_s3",function(s,e) return BGUTIL.KPRESS(e,KEY_R) and UAbIsReady(e,"kindred_mdread") end) 
		asn:NewTransition("g_stand","cast_s4",function(s,e) return BGUTIL.KPRESS(e,KEY_F) and UAbIsReady(e,"kindred_respite") end) 


		asn:NewTransition("g_cast","idle",BGCOND.ANMFIN) 

		asn:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL) and ( BGUTIL.KPRESS(e,KEY_3) or BGUTIL.KPRESS(e,KEY_4))  end) 
		asn:NewTransition("social_root","social_dance",function(s,e) return BGUTIL.KPRESS(e,KEY_3) end) 
		asn:NewTransition("social_root","social_taunt",function(s,e) return BGUTIL.KPRESS(e,KEY_4) end)  
		asn:NewTransition("g_social_noloop","idle",BGCOND.ANMFIN) 
		   
		   
		asn:SetState("spawn")
	end
})
  
