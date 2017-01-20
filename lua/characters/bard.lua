AddCSLuaFile()
 
Dota.AddCharacter({  
	name = "bard",
	model = "models/heroes/bard/bard.mdl",
	move_allow_forward45 = true, 
	animations = {
		//format 
		// name = { anims, specials, sounds }
		idle = { {"idle"}, {"idlespecial"},{},loop = true},
		walk = { {"floatrun"}, {},{},loop = true},
		run = { {"floatrun"}, {},{},loop = true},  
		attack = { {"attack1","attack3","attack3"}},
		  
		death = "death",
		spawn = "spawn",
		social_1 = {"dance",{},{},loop = true}, 
	},  
	spells = { 
		{"l_attack_ranged", key = IN_ATTACK},   
		{"kindred_social", key = IN_ATTACK2}
		
	}, 
	stats = {
		//{base,perLevel}
		health = {535,89}, 
		healthregen = {5.4,0.55} ,
		armor = {25,4},
		magicresist = {30,0}, 
		attackdamage = {52,3},
		attackspeed = {0.625, 2.5}, //%
		movementspeed = {325,0}, 
	}, 
	speed_walk = 180,
	speed_run = 280 
})
  
