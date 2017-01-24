AddCSLuaFile()
 
character.name = "shyvana"
character.model = "models/heroes/shyvana/dragon.mdl"
character.move_allow_forward45 = true   
character.spells = { 
	{"l_attack_melee"},     
	{"shyvana_transform", form = "shyvana"}
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
	b:NewState("idle",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"idle") end) 
	b:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"run") return 0.05 end) 
	b:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_melee") return  
		BGACT.PANIMCYCLE(e, {"attack1","attack2"},true,b,"att_cycle") end)
	b:NewState("recall",function(s,e) e:EmitSound("league_misc.recall") return 2 end, 
			function(s,e) e:StopSound( "league_misc.recall" )end) 
	b:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 
	
	b:NewState("transform",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"spell4") return 2 end)
	b:NewState("transform_land",function(s,e) return BGACT.PANIM(e,"spell4_land") end)
	
	b:NewState("spell4",function(s,e)  BGACT.ABCAST(e,"shyvana_transform") return 0.05 end) 
	
	b:NewState("social_root",function(s,e) return 0.1 end)
	b:NewState("social_laugh",function(s,e) return  BGACT.PANIM(e,"laugh") end) 
	b:NewState("social_taunt",function(s,e) return  BGACT.PANIM(e,"taunt") end) 
	
	
	b:NewGroup("g_social",{"social_laugh","social_taunt"}) 
	b:NewGroup("g_stand_nosocial",{"spawn","idle","recall"}) 
	b:NewGroup("g_stand_norecall",{"spawn","idle","g_social"})
	b:NewGroup("g_stand",{"spawn","idle","recall","g_social"})
	
	b:NewTransition("spawn","idle",BGCOND.ANMFIN)  
	
	b:NewTransition("g_stand","run",function(s,e) return e:KeyDown(IN_FORWARD) end)  
	b:NewTransition("run","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end)
			
	b:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_melee") end) 
	b:NewTransition("attack","idle",BGCOND.ANMFIN) 
	
	b:NewTransition("g_stand","spell4",function(s,e) return BGUTIL.KPRESS(e,KEY_F)  and BGUTIL.ABREADY(e,"shyvana_transform") end) 
	
	b:NewTransition("g_stand_norecall","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end) 
	b:NewTransition("recall","recall_end",BGCOND.ANMFIN)
	b:NewTransition("recall_end","spawn",BGCOND.ANMFIN)
	
	b:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL) 
		and ( BGUTIL.KPRESS(e,KEY_1) or BGUTIL.KPRESS(e,KEY_2))  end) 
	b:NewTransition("social_root","social_laugh",function(s,e) return BGUTIL.KPRESS(e,KEY_1) end)  
	b:NewTransition("social_root","social_taunt",function(s,e) return BGUTIL.KPRESS(e,KEY_2) end)  
	
	b:NewTransition("g_social","idle",BGCOND.ANMFIN)  
	
	b:NewTransition("transform","transform_land",function(s,e) return e:OnGround() end)  
	b:NewTransition("transform_land","idle",BGCOND.ANMFIN) 
	
	b:SetState("spawn")
	
end


