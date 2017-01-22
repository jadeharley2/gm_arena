AddCSLuaFile()
 
character.name = "bard"
character.model = "models/heroes/bard/bard.mdl"
character.move_allow_forward45 = true
character.spells = { 
	{"l_attack_ranged"},   
	//{"l_social", key = KEY_LCONTROL}
	
} 
character.stats = {
	//{base,perLevel}
	health = {535,89}, 
	healthregen = {5.4,0.55} ,
	armor = {25,4},
	magicresist = {30,0}, 
	attackdamage = {52,3},
	attackspeed = {0.625, 2.5}, //%
	movementspeed = {325,0}, 
}
character.speed_walk = 180
character.speed_run = 280
character.ab_basicattack = {
	projectile = { trailcolor = Color(250,200,100), trailwidthstart = 50 },
	startpos = "attachment",
	attachment = "weapon_tstart"
} 
function character:Behavior(ply,b)
	//b.debug = true
	b:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return 0.05 end)
	b:NewState("idle",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"idle") return 0.05 end)
	b:NewState("idlespecial", function(s,e) return BGACT.PANIM(e,"idlespecial") end) 
	
	b:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"floatrun") return 0.05 end) 
	
	b:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_ranged") return  
		BGACT.PANIMCYCLE(e, {"attack1","attack2","attack3"},true,b,"att_cycle") end)
	
	b:NewState("recall",function(s,e) return BGACT.PANIM(e,"recall") end) 
	b:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 
	
	local dance_interrupt = function(s,e,n) if n.name != "social_dance" then e:SetBodygroup(1,0)  end end
	b:NewState("social_root",function(s,e) return 0.1 end)
	b:NewState("social_dance_start",function(s,e) e:SetBodygroup(1,1) return BGACT.PANIM(e,"dancestart") end, dance_interrupt) 
	b:NewState("social_dance",function(s,e) BGACT.PANIM(e,"dance") return 0.05 end,dance_interrupt) 
	
	b:NewGroup("g_social",{"social_dance","social_dance_start"}) 
	b:NewGroup("g_stand_nosocial",{"spawn","idle","idlespecial","recall","attack"}) 
	b:NewGroup("g_stand",{"spawn","idle","idlespecial","recall","attack","g_social"}) 
	
	b:NewTransition("spawn","idle",BGCOND.ANMFIN)
	b:NewTransition("idle","idlespecial",BGCOND.RND01P) 
	b:NewTransition("idlespecial","idle",BGCOND.ANMFIN) 
	 
	b:NewTransition("g_stand","run",function(s,e) return e:KeyDown(IN_FORWARD) end) 
	b:NewTransition("run","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end)
	
	b:NewTransition("g_stand","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end) 
	b:NewTransition("recall","recall_end",BGCOND.ANMFIN)
	b:NewTransition("recall_end","spawn",BGCOND.ANMFIN)
	
	b:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_ranged") end) 
	b:NewTransition("attack","idle",BGCOND.ANMFIN) 

	b:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL) 
		and ( BGUTIL.KPRESS(e,KEY_3) or BGUTIL.KPRESS(e,KEY_4))  end) 
	b:NewTransition("social_root","social_dance_start",function(s,e) return BGUTIL.KPRESS(e,KEY_3) end) 
	b:NewTransition("social_dance_start","social_dance",BGCOND.ANMFIN) 
	//b:NewTransition("social_root","social_taunt",function(s,e) return BGUTIL.KPRESS(e,KEY_4) end)  
	//b:NewTransition("g_social_noloop","idle",BGCOND.ANMFIN) 
	   
	   
	b:SetState("spawn")
	
end 

