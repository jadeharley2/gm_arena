AddCSLuaFile()
 
character.name = "leona"
character.model = "models/heroes/leona/leona.mdl"
//character.move_allow_forward45 = true   
character.spells = { 
	{"l_attack_melee"},
	{"leona_shield"}
}
character.stats = {
	//{base,perLevel}
	health = {595,95},  
	healthregen = {8.6,0.8} ,
	armor = {27.628,3.35}, 
	magicresist = {32.1,1.25}, 
	attackdamage = {60.712,3.4},
	attackspeed = {0.658, 2.5}, //%
	movementspeed = {350,0}, 
}
character.speed_walk = 180
character.speed_run = 280
function character:Behavior(ply,b)
	//b.debug = true
	b:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return 0.05 end)
	b:NewState("idle",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"idle1") end) //:D
	b:NewState("idle_rnd",function(s,e) BGACT.SETSPD(e,0)  return BGACT.PANIMRND(e,{"idle1","idle2","idle3"}) end) 
	b:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"run") return 0.05 end) 
	//b:NewState("runfast",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"run_fast") return 0.05 end) 
	b:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_melee") return  
		BGACT.PANIMCYCLE(e, {"attack1","attack2","attack3"},true,b,"att_cycle") end)
	b:NewState("recall",function(s,e) e:EmitSound("league_misc.recall") return BGACT.PANIM(e,"recall_loop") end, 
			function(s,e) e:StopSound( "league_misc.recall" )end) 
	b:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 
	
	  
	b:NewState("spell2_enter",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"spell2")*0.5 end) 
	b:NewState("spell2_idle",function(s,e) BGACT.SETSPD(e,0)  BGACT.PANIM(e,"spell2_idle") return 0.05 end) 
	b:NewState("spell2_attack",function(s,e) BGACT.SETSPD(e,0)  BGACT.ABCAST(e,"l_attack_melee") return BGACT.PANIM(e,"spell2_attack",true) end) 
	b:NewState("spell2_run",function(s,e) BGACT.SETSPD(e,120)  BGACT.PANIM(e,"spell2_run") return 0.05 end) 
	b:NewState("spell2_exit",function(s,e) BGACT.ABCAST(e,"leona_shield") return BGACT.SANIM(e,"spell2",0.5,0.5) end) 
	
	b:NewState("social_root",function(s,e) return 0.1 end)
	b:NewState("social_dance",function(s,e) return BGACT.PANIM(e,"dance") end) 
	b:NewState("social_joke",function(s,e) return BGACT.PANIM(e,"joke") end) 
	b:NewState("social_laugh",function(s,e) return BGACT.PANIM(e,"laugh") end) 
	b:NewState("social_taunt",function(s,e) return BGACT.PANIM(e,"taunt") end) 
	
	
	b:NewGroup("g_social",{"social_dance","social_joke","social_laugh","social_taunt"})  
	b:NewGroup("g_stand_nosocial",{"spawn","idle","idle_rnd","recall"}) 
	b:NewGroup("g_stand_norecall",{"spawn","idle","idle_rnd","g_social"})
	b:NewGroup("g_stand",{"spawn","idle","idle_rnd","recall","g_social"})
	
	b:NewGroup("g_spell2_stand",{"spell2_idle","spell2_attack"})
	
	
	b:NewTransition("spawn","idle",BGCOND.ANMFIN) 
	b:NewTransition("idle","idle_rnd",BGCOND.ANMFIN) 
	b:NewTransition("idle_rnd","idle",BGCOND.ANMFIN) 
	
	b:NewTransition("g_stand","run",function(s,e) return e:KeyDown(IN_FORWARD) end)  
	b:NewTransition("run","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end) 
	//b:NewTransition("run","runfast",function(s,e) return e:KeyDown(IN_SPEED) end)
	//b:NewTransition("runfast","run",function(s,e) return !e:KeyDown(IN_SPEED) or !e:KeyDown(IN_FORWARD) end)
			
	b:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_melee") end) 
	b:NewTransition("attack","idle",BGCOND.ANMFIN) 
	 
	
	b:NewTransition("g_stand","spell2_enter",function(s,e) return e:KeyDown(IN_ATTACK2) and BGUTIL.ABREADY(e,"leona_shield") end) //...
	b:NewTransition("spell2_enter","spell2_idle",BGCOND.ANMFIN) 
	b:NewTransition("g_spell2_stand","spell2_run",function(s,e) return e:KeyDown(IN_FORWARD) end)  
	b:NewTransition("spell2_run","spell2_idle",function(s,e) return !e:KeyDown(IN_FORWARD) end)  
	b:NewTransition("spell2_idle","spell2_attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_melee")  end) 
	b:NewTransition("spell2_attack","spell2_idle",BGCOND.ANMFIN) 
	b:NewTransition("g_spell2_stand","spell2_exit",function(s,e) return e:KeyDown(IN_ATTACK2)  end)
	b:NewTransition("spell2_exit","idle",BGCOND.ANMFIN) 
	
	
	b:NewTransition("g_stand_norecall","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end) 
	b:NewTransition("recall","recall_end",BGCOND.ANMFIN)
	b:NewTransition("recall_end","spawn",BGCOND.ANMFIN)
	
	b:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL) 
		and ( BGUTIL.KPRESS(e,KEY_1) or BGUTIL.KPRESS(e,KEY_2) or BGUTIL.KPRESS(e,KEY_3) or BGUTIL.KPRESS(e,KEY_4))  end) 
	b:NewTransition("social_root","social_joke",function(s,e) return BGUTIL.KPRESS(e,KEY_1) end)  
	b:NewTransition("social_root","social_laugh",function(s,e) return BGUTIL.KPRESS(e,KEY_2) end)  
	b:NewTransition("social_root","social_dance",function(s,e) return BGUTIL.KPRESS(e,KEY_3) end)  
	b:NewTransition("social_root","social_taunt",function(s,e) return BGUTIL.KPRESS(e,KEY_4) end)  
	b:NewTransition("g_social","idle",BGCOND.ANMFIN)
	
	
	
	b:SetState("spawn")
	
end


