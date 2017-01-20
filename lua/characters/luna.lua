Dota.heroes.lunamount = { 
	name = "lunamount",
	model = "models/heroes/luna/luna_mount.mdl",
	ismount  = true,
	a_idle  = 1,
	a_idle_special  = 23,
	a_cast  = 8, 
	a_attack = {3,11,12}, 
	a_walk  = 2,
	a_run  = 9,
}
Dota.heroes.luna  = { 
	name = "luna",
	isplayermodel = true,
	model = "models/heroes/luna/luna.mdl", 
	mounted = "lunamounted"
}

Dota.heroes.lunamounted  = { 
	name = "lunamounted", 
	model = "models/heroes/luna/luna_mounted.mdl",
	dismounted = "luna"
	
}