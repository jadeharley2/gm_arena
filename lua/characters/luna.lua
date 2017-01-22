AddCSLuaFile()
/*
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
*/ 
character.name = "luna"
character.model = "models/heroes/luna/luna_mount.mdl"
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
character.ab_basicattack = { 
}
/*  
*/
function character:Behavior(ply,asn)
	asn.debug = true
	asn:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"spawn")  end) 
	asn:NewState("idle",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"idle") return 0.05 end) 
	  
	asn:NewTransition("spawn","idle",BGCOND.ANMFIN) 
	asn:NewTransition("idle","idlespecial",BGCOND.RND01P)  
	asn:SetState("spawn")
end 
