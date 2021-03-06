AddCSLuaFile()

sound.Add( {
	name = "katarina.attack",
	channel = CHAN_WEAPON,
	volume = { 0.6, 0.8 },
	level = 90,
	pitch = { 90, 110 },
	sound = {
		"heroes/katarina/attack1.ogg",
		"heroes/katarina/attack2.ogg",
		"heroes/katarina/attack3.ogg",
		"heroes/katarina/attack4.ogg",
	}
} )
sound.Add( {
	name = "katarina.hitflesh",
	channel = CHAN_WEAPON,
	volume = { 0.6, 0.8 },
	level = 90,
	pitch = { 90, 110 },
	sound = {
		"heroes/katarina/hitflesh1.ogg",
		"heroes/katarina/hitflesh2.ogg",
		"heroes/katarina/hitflesh3.ogg",
		"heroes/katarina/hitflesh4.ogg",
	}
} )

sound.Add( {
	name = "katarina.shunpo",
	channel = CHAN_WEAPON,
	volume = { 0.6, 0.8 },
	level = 90,
	pitch = { 90, 110 },
	sound = {
		"heroes/katarina/shunpo1.ogg",
		"heroes/katarina/shunpo2.ogg",
		"heroes/katarina/shunpo3.ogg",
		"heroes/katarina/shunpo4.ogg",
	}
} )

sound.Add( {
	name = "katarina.dager",
	channel = CHAN_WEAPON,
	volume = { 0.6, 0.8 },
	level = 90,
	pitch = { 90, 110 },
	sound = {
		"heroes/katarina/dager1.ogg",
		"heroes/katarina/dager2.ogg",
		"heroes/katarina/dager3.ogg",
		"heroes/katarina/dager4.ogg",
	}
} )

sound.Add( {
	name = "katarina.lotus",
	channel = CHAN_WEAPON,
	volume = { 0.6, 0.8 },
	level = 90,
	pitch = { 90, 110 },
	sound = {
		"heroes/katarina/lotus1.ogg",
		"heroes/katarina/lotus2.ogg",
		"heroes/katarina/lotus3.ogg",
	}
} )

sound.Add( {
	name = "katarina.taunt",
	channel = CHAN_WEAPON,
	volume = { 0.6, 0.8 },
	level = 90,
	pitch = { 90, 110 },
	sound = {
		"heroes/katarina/taunt.ogg",
	}
} )

character.name = "katarina"
character.model = "models/heroes/katarina/katarina.mdl"
character.move_allow_forward45 = false
character.spells = {
	{"l_attack_melee"},
	{"katarina_passive"},
	{"katarina_dager"},
	{"katarina_shunpo"},
	{"katarina_lotus"}
}
character.stats = {
	//{base,perLevel}
	health = {590,82},
	healthregen = {7.5,0.7} ,
	armor = {27.88,3.5},
	magicresist = {34.1,1.25},
	attackdamage = {58,3.2},
	attackspeed = {0.658, 2.74}, //%
	movementspeed = {340,0},
}
character.speed_walk = 180
character.speed_run = 280
function character:Behavior(ply,b)
	//b.debug = true
	b:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return 0.05 end)
	b:NewState("idle",function(s,e) BGACT.SETSPD(e,0) return 0.05 end)
	b:NewState("idle_rnd",function(s,e) BGACT.SETSPD(e,0)  return BGACT.PANIMRND(e,{"idle1","idle2"}) end)
	b:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"run1") return 0.05 end)
	b:NewState("runspecial",function(s,e) BGACT.SETSPD(e,280)  return BGACT.PANIM(e,"run2") end)
	b:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_melee") return
		BGACT.PANIMCYCLE(e, {"attack1","attack2"},true,b,"att_cycle") end)
	b:NewState("recall",function(s,e) e:EmitSound("league_misc.recall") return BGACT.PANIM(e,"recall") end,
			function(s,e) e:StopSound( "league_misc.recall" )end)
	b:NewState("recall_end",function(s,e) e:SetPos(Vector(0,0,0)) return 0.05 end)

	b:NewState("spell1",function(s,e) BGACT.ABCAST(e,"katarina_dager") return BGACT.PANIM(e,"spell1") end)
	b:NewState("spell3",function(s,e) BGACT.ABCAST(e,"katarina_shunpo")  e:SetCycle( 0) return BGACT.PANIM(e,"spell3") end)
	b:NewState("spell4",function(s,e) return BGACT.PANIM(e,"spell4",true) end,
	function(s,e,ns) if ns.name !="spell4"then e.abilities.katarina_lotus:Dispell() end end)
	b:NewState("spell4_start",function(s,e) s.spell4_end = CurTime()+5 BGACT.ABCAST(e,"katarina_lotus") return 0.01 end)

	b:NewState("social_root",function(s,e) return 0.1 end)
	b:NewState("social_dance",function(s,e) return  BGACT.PANIM(e,"dance") end)
	b:NewState("social_taunt",function(s,e) e:EmitSound("katarina.taunt") return  BGACT.PANIM(e,"taunt") end)
	b:NewState("social_laugh",function(s,e) return  BGACT.PANIM(e,"laugh") end)
	b:NewState("social_joke",function(s,e) return  BGACT.PANIM(e,"joke") end)

	b:NewGroup("g_cast_interruptable",{"spell1","spell3","spell4"})
	b:NewGroup("g_social",{"social_dance","social_taunt","social_laugh","social_joke"})
	b:NewGroup("g_stand_nosocial",{"spawn","idle","idle_rnd","recall","attack"})
	b:NewGroup("g_stand_norecall",{"spawn","idle","idle_rnd","g_social","attack"})
	b:NewGroup("g_stand",{"spawn","idle","idle_rnd","recall","g_social","attack","g_cast_interruptable"})
	b:NewGroup("g_run",{"run","runspecial"})
	b:NewGroup("g_cast",{"spell1","spell3"})

	b:NewTransition("spawn","idle",BGCOND.ANMFIN)
	b:NewTransition("idle","idle_rnd",BGCOND.ANMFIN)
	b:NewTransition("idle_rnd","idle",BGCOND.ANMFIN)

	b:NewTransition("g_stand","run",function(s,e) return e:KeyDown(IN_FORWARD) end)
	b:NewTransition("g_run","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end)
	b:NewTransition("run","runspecial",BGCOND.RND01P)
	b:NewTransition("runspecial","idle",BGCOND.ANMFIN)

	b:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_melee") end)
	b:NewTransition("attack","idle",BGCOND.ANMFIN)

	b:NewTransition("g_stand_norecall","recall",function(s,e) return BGUTIL.KPRESS(e,KEY_B) end)
	b:NewTransition("recall","recall_end",BGCOND.ANMFIN)
	b:NewTransition("recall_end","spawn",BGCOND.ANMFIN)

	b:NewTransition("g_stand_nosocial","social_root",function(s,e) return BGUTIL.KPRESS(e,KEY_LCONTROL)
		and ( BGUTIL.KPRESS(e,KEY_1) or BGUTIL.KPRESS(e,KEY_2) or BGUTIL.KPRESS(e,KEY_3) or BGUTIL.KPRESS(e,KEY_4))  end)

	b:NewTransition("social_root","social_taunt",function(s,e) return BGUTIL.KPRESS(e,KEY_1) end)
	b:NewTransition("social_root","social_laugh",function(s,e) return BGUTIL.KPRESS(e,KEY_2) end)
	b:NewTransition("social_root","social_dance",function(s,e) return BGUTIL.KPRESS(e,KEY_3) end)
	b:NewTransition("social_root","social_joke",function(s,e) return BGUTIL.KPRESS(e,KEY_4) end)
	b:NewTransition("g_social","idle",BGCOND.ANMFIN)

	//Spells
	b:NewTransition("g_stand","spell1",function(s,e) return BGUTIL.KPRESS(e,KEY_Q) and BGUTIL.ABREADY(e,"katarina_dager") end)
	b:NewTransition("g_stand","spell3",function(s,e) return BGUTIL.KPRESS(e,KEY_E) and BGUTIL.ABREADY(e,"katarina_shunpo") end)
	b:NewTransition("g_stand","spell4_start",function(s,e) return BGUTIL.KPRESS(e,KEY_R) and BGUTIL.ABREADY(e,"katarina_lotus") end)

	b:NewTransition("spell4_start","spell4",BGCOND.ANMFIN)
  b:NewTransition("spell4","spell4",BGCOND.ANMFIN)
  b:NewTransition("spell4","idle", function(s,e)  return s.spell4_end<CurTime() end)

	b:NewTransition("g_cast","idle",BGCOND.ANMFIN)

	b:SetState("spawn")

end
