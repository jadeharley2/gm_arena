AddCSLuaFile()
  
character.name = "nidalee_cat"
character.model = "models/heroes/nidalee/cat.mdl"
character.move_allow_forward45 = false   
character.spells = { 
	{"l_attack_melee"},    
	{"nidalee_transform_human"}
}
character.stats = {
	//{base,perLevel}
	health = {511,80}, 
	healthregen = {6.005,0.6} ,
	armor = {22.88,3.5}, 
	magicresist = {30,0}, 
	attackdamage = {53,3.5},
	attackspeed = {0.638, 3.22}, //%
	movementspeed = {335,0}, 
}
character.skins = {
	base = { bg = {1,0}, skn = 0},
	[1]  = { bg = {1,1}, skn = 0},
	[2]  = { bg = {1,2}, skn = 0},
	[3]  = { bg = {1,3}, skn = 0},
	[4]  = { bg = {1,4}, skn = 0}, 
	[5]  = { bg = {1,5}, skn = 0},
	[6]  = { bg = {1,6}, skn = 0},
	[7]  = { bg = {1,7}, skn = 0},
	[8]  = { bg = {1,8}, skn = 0},
}
character.speed_walk = 180
character.speed_run = 280
function character:Behavior(ply,b)
	//b.debug = true
	b:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"idle_enter") end)
	b:NewState("idle",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"idle1") end) 
	b:NewState("idle_rnd",function(s,e) BGACT.SETSPD(e,0)  return BGACT.PANIMRND(e,{"idle1","idle2"}) end) 
	b:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"run") return 0.05 end) 
	b:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_melee") return  
		BGACT.PANIMCYCLE(e, {"attack1","attack2"},true,b,"att_cycle") end)
	b:NewState("recall",function(s,e) e:EmitSound("league_misc.recall") return BGACT.PANIM(e,"recall") end, 
			function(s,e,n) e:StopSound( "league_misc.recall" )end)  
	b:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end) 
	
	b:NewState("spell4",function(s,e)  BGACT.ABCAST(e,"nidalee_transform_human")  return 0.05 end) 
	//b:NewState("spell4_end",function(s,e)  
	//	e:SetPos(e:GetPos()+Vector(0,0,2)) 
	//	local ea = e:GetAngles() 
	//	e:SetVelocity(ea:Forward()*1000+ea:Up()*500) 
	//	BGACT.ABCAST(e,"shyvana_transform") 
	//	return 0.05 
	//end) 
	
	b:NewState("social_root",function(s,e) return 0.1 end)
	b:NewState("social_dance",function(s,e) return BGACT.PANIM(e,"dance") end) 
	b:NewState("social_dance_loop",function(s,e)  BGACT.PANIM(e,"dance_loop") return 0.01 end) 
	b:NewState("social_joke",function(s,e) return BGACT.PANIM(e,"joke") end) 
	b:NewState("social_laugh",function(s,e) return BGACT.PANIM(e,"laugh") end) 
	b:NewState("social_taunt",function(s,e) return BGACT.PANIM(e,"taunt") end) 
	
	
	b:NewGroup("g_social",{"social_dance","social_joke","social_laugh","social_taunt","social_dance_loop"})  
	b:NewGroup("g_social_noloop",{"social_dance","social_joke","social_laugh","social_taunt"})  
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
	
	b:NewTransition("g_stand","spell4",function(s,e) return BGUTIL.KPRESS(e,KEY_F)  and BGUTIL.ABREADY(e,"nidalee_transform_human") end) 
	//b:NewTransition("spell4","spell4_end",BGCOND.ANMFIN) 
	
	b:NewTransition("g_stand_norecall","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end) 
	b:NewTransition("recall","recall_end",BGCOND.ANMFIN)
	b:NewTransition("recall_end","spawn",BGCOND.ANMFIN)
	
	b:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL) 
		and ( BGUTIL.KPRESS(e,KEY_1) or BGUTIL.KPRESS(e,KEY_2) or BGUTIL.KPRESS(e,KEY_3) or BGUTIL.KPRESS(e,KEY_4))  end) 
	b:NewTransition("social_root","social_joke",function(s,e) return BGUTIL.KPRESS(e,KEY_1) end)  
	b:NewTransition("social_root","social_laugh",function(s,e) return BGUTIL.KPRESS(e,KEY_2) end)  
	b:NewTransition("social_root","social_dance",function(s,e) return BGUTIL.KPRESS(e,KEY_3) end)  
	b:NewTransition("social_root","social_taunt",function(s,e) return BGUTIL.KPRESS(e,KEY_4) end)  
	b:NewTransition("social_dance","social_dance_loop",BGCOND.ANMFIN)
	b:NewTransition("g_social_noloop","idle",BGCOND.ANMFIN)
	
	
	
	b:SetState("spawn")
	
end


