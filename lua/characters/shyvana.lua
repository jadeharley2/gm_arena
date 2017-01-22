AddCSLuaFile()
 
character.name = "shyvana"
character.model = "models/heroes/shyvana/shyvana.mdl"
character.move_allow_forward45 = true   
character.spells = { 
	{"l_attack_melee"},    
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
	b:NewState("idle",function(s,e) BGACT.SETSPD(e,0) return 0.05 end) 
	b:NewState("idle_rnd",function(s,e) BGACT.SETSPD(e,0)  return BGACT.PANIMRND(e,{"idle1","idle2","idle3","idle4"}) end) 
	b:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"run") return 0.05 end) 
	b:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_melee") return  
		BGACT.PANIMCYCLE(e, {"attack1","attack2","attack3"},true,b,"att_cycle") end)
	b:NewState("recall",function(s,e) e:EmitSound("league_misc.recall") return BGACT.PANIM(e,"recall") end, 
			function(s,e) e:StopSound( "league_misc.recall" )end) 
	b:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 
	
	b:NewState("social_root",function(s,e) return 0.1 end)
	b:NewState("social_dance",function(s,e) BGACT.PANIM(e,"dance") return 0.05 end) 
	
	
	b:NewGroup("g_social",{"social_dance"}) 
	b:NewGroup("g_stand_nosocial",{"spawn","idle","idle_rnd","recall"}) 
	b:NewGroup("g_stand_norecall",{"spawn","idle","idle_rnd","g_social"})
	b:NewGroup("g_stand",{"spawn","idle","idle_rnd","recall","g_social"})
	
	b:NewTransition("spawn","idle",BGCOND.ANMFIN) 
	b:NewTransition("idle","idle_rnd",BGCOND.ANMFIN) 
	b:NewTransition("idle_rnd","idle",BGCOND.ANMFIN) 
	
	b:NewTransition("g_stand","run",function(s,e) return e:KeyDown(IN_FORWARD) end)  
	b:NewTransition("run","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end)
			
	b:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_melee") end) 
	b:NewTransition("attack","idle",BGCOND.ANMFIN) 
	
	b:NewTransition("g_stand_norecall","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end) 
	b:NewTransition("recall","recall_end",BGCOND.ANMFIN)
	b:NewTransition("recall_end","spawn",BGCOND.ANMFIN)
	
	b:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL) 
		and ( BGUTIL.KPRESS(e,KEY_3) or BGUTIL.KPRESS(e,KEY_4))  end) 
	b:NewTransition("social_root","social_dance",function(s,e) return BGUTIL.KPRESS(e,KEY_3) end)  
	
	
	
	b:SetState("spawn")
	
end


