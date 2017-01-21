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
/*
sound.Add( {
	name = "Hero_Enchantress.Attack",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 80,
	pitch = { 90, 110 },
	sound = {
		"heroes/enchantress/attack1.wav",
		"heroes/enchantress/attack02.wav", 
	}
} )
sound.Add( {
	name = "Hero_Enchantress.Cast",
	channel = CHAN_WEAPON,
	volume = 0.5,
	level = 80,
	pitch = { 90, 110 },
	sound =  "heroes/enchantress/enchant_cast.wav"  
	 
} )
*/
game.AddParticles( "particles/units/heroes/hero_enchantress_pold.pcf" )

Dota.heroes.enchantress = { 
	name = "enchantress",
	model = "models/heroes/enchantress/enchantress.mdl",
	a_idle  = 1,
	a_idle_special  = 2,
	a_cast  = 8,
	s_cast = "Hero_Enchantress.EnchantCast",
	a_attack = {3,4},
	s_attack = "Hero_Enchantress.Attack",
	a_walk  = 10,
	a_run  = 11,
	a_spawn = 14,
	a_death = {5,6},
	cooldown_cast = 2,
	cooldown_attack = 1,
}
