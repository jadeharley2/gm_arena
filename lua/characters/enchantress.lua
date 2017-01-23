AddCSLuaFile()

sound.Add( { name = "Hero_Enchantress.PreAttack",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 72,
	pitch = { 100, 110 },
	sound = { "heroes/pugna/preattack.wav"   }
} )
sound.Add( { name = "Hero_Enchantress.Attack",
	channel = CHAN_WEAPON,
	volume = 1,
	level = 75,
	pitch = { 95, 105 },
	sound = { 
		"heroes/enchantress/attack01.wav",
		"heroes/enchantress/attack02.wav"
	}
} )
sound.Add( { name = "Hero_Enchantress.ProjectileImpact",
	channel = CHAN_STATIC,
	volume = 1,
	level = 72,
	pitch = { 95, 105 },
	sound = { 
		"heroes/enchantress/impact01.wav",
		"heroes/enchantress/impact02.wav",
		"heroes/enchantress/impact03.wav" 
	}
} )
sound.Add( { name = "Hero_Enchantress.Untouchable",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 75,
	pitch = { 95, 105 },
	sound = { 
		"heroes/pugna/netherblast_precast.wav"
	}
} )
sound.Add( { name = "Hero_Enchantress.EnchantCast",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 75,
	pitch = { 100 },
	sound = { 
		"heroes/enchantress/enchant_cast.wav"
	}
} )
sound.Add( { name = "Hero_Enchantress.EnchantHero",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 78,
	pitch = { 100 },
	sound = { 
		"heroes/enchantress/enchant_hero.wav"
	}
} )
sound.Add( { name = "Hero_Enchantress.EnchantCreep",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 78,
	pitch = { 100 },
	sound = { 
		"heroes/enchantress/enchant_creep.wav"
	}
} )
sound.Add( { name = "Hero_Enchantress.NaturesAttendantsCast",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 81,
	pitch = { 100 },
	sound = { 
		"heroes/enchantress/natures_attendants.mp3"
	}
} )
sound.Add( { name = "Hero_Enchantress.Impetus",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 81,
	pitch = { 95, 105 },
	sound = { 
		"heroes/enchantress/impetus01.wav",
		"heroes/enchantress/impetus02.wav",
		"heroes/enchantress/impetus03.wav"
	}
} )
sound.Add( { name = "Hero_Enchantress.ImpetusDamage",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 81,
	pitch = { 75, 85 },
	sound = { 
		"heroes/enchantress/impact01.wav",
		"heroes/enchantress/impact02.wav",
		"heroes/enchantress/impact03.wav"
	}
} ) 
sound.Add( { name = "Hero_Enchantress.Footsteps",
	channel = CHAN_BODY,
	volume = { 0.3, 0.6 },
	level = 72,
	pitch = { 95, 105 },
	sound = {
		"heroes/enchantress/footstep01.wav",
		"heroes/enchantress/footstep02.wav",
		"heroes/enchantress/footstep03.wav",
		"heroes/enchantress/footstep04.wav",
		"heroes/enchantress/footstep05.wav"
	}
} )
 


sound.Add( {
	name = "Hero_Enchantress.FootstepsLight",
	channel = CHAN_BODY,
	volume = { 0.2, 0.4 },
	level = 80,
	pitch = { 90, 110 },
	sound = {
		"heroes/enchantress/footstep01.wav",
		"heroes/enchantress/footstep02.wav",
		"heroes/enchantress/footstep03.wav",
		"heroes/enchantress/footstep04.wav", 
		"heroes/enchantress/footstep05.wav"
	}
} ) 
game.AddParticles( "particles/units/heroes/hero_enchantress_pold.pcf" )
 
character.name = "enchantress"
character.model = "models/heroes/enchantress/enchantress.mdl"
character.move_allow_forward45 = false
character.spells = {  
	{"l_attack_ranged"}, 
}
character.stats = { 
	health = {540,85}, 
	healthregen = {7,0.55}, 
	armor = {20,3.5},
	magicresist = {30,0},
	attackdamage = {54,1.7},
	attackspeed = {0.625, 2.5}, //%
	movementspeed = {325,0}, 
}
character.speed_walk = 180
character.speed_run = 280 
character.death_anim = {"death","death_lodestar"}
character.ab_basicattack = {
	sound = "Hero_Enchantress.Attack",
	startpos = "attachment",
	attachment = "attach_attack1",
	projectile = {
		trailcolor = Color(250,200,100), 
		trailwidthstart = 50,
		hitsound = "kindred.bowhit" 
	} 
}
/*
0	=	BindPose
1	=	idle
2	=	idle_alt
3	=	attack
4	=	attack_alt
5	=	death
6	=	death_lodestar
7	=	enchant
8	=	natures_attendants
9	=	impetus
10	=	run
11	=	run_haste
12	=	stun
13	=	flail
14	=	spawn
15	=	capture
16	=	workshop_anim_00
17	=	workshop_anim_01
18	=	workshop_anim_02
19	=	workshop_anim_03
20	=	workshop_anim_04
21	=	workshop_anim_05
22	=	workshop_anim_06
23	=	workshop_anim_07
24	=	workshop_anim_08
25	=	workshop_anim_09
26	=	turns_lookFrame_0
27	=	turns_lookFrame_1
28	=	turns_lookFrame_2
29	=	turns
30	=	head_rot_x
31	=	head_rot_y 
*/
function character:Behavior(ply,asn)
	//asn.debug = true
	asn:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"spawn")  end) 
	asn:NewState("idle",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"idle") return 0.05 end) 
	asn:NewState("idlespecial", function(s,e) return BGACT.PANIM(e,"idle_alt") end) 
	asn:NewState("walk",function(s,e) BGACT.SETSPD(e,180) BGACT.PANIM(e,"run") return 0.05 end) 
	asn:NewState("run",function(s,e) BGACT.SETSPD(e,320) BGACT.PANIM(e,"run_haste") return 0.05 end) 
	asn:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_ranged") return BGACT.PANIMRND(e, {"attack","attack_alt"},true) end)
	
	asn:NewState("stunned",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"stun") return ply.stuntime or 4 end)
	asn:NewState("flail",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"flail") return ply.flailtime or 4 end)
	
	asn:NewGroup("g_stand",{"spawn","idle","idlespecial","attack"})
	 
	asn:NewTransition("spawn","idle",BGCOND.ANMFIN) 
	asn:NewTransition("idle","idlespecial",BGCOND.RND01P) 
	asn:NewTransition("idlespecial","idle",BGCOND.ANMFIN)  
	asn:NewTransition("g_stand","walk",function(s,e) return e:KeyDown(IN_FORWARD) end)  
	asn:NewTransition("walk","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end) 
	asn:NewTransition("walk","run",function(s,e) return e:KeyDown(IN_SPEED) end)  
	asn:NewTransition("run","walk",function(s,e) return !e:KeyDown(IN_SPEED) or !e:KeyDown(IN_FORWARD) end)
	    
	asn:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_ranged") end) 
	asn:NewTransition("attack","idle",BGCOND.ANMFIN) 
	
	asn:NewTransition("stunned","idle",BGCOND.ANMFIN) 
	asn:NewTransition("flail","idle",BGCOND.ANMFIN) 
	asn:SetState("spawn")
end 
