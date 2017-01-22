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
character.death_anim = {"luna_death"}
character.ab_basicattack = { 
}
/*  
0	=	BindPose
1	=	luna_idle
2	=	luna_run
3	=	luna_attack
4	=	luna_death
5	=	luna_flail
6	=	luna_stun
7	=	luna_capture
8	=	luna_cast
9	=	luna_run_haste
10	=	luna_eclipse
11	=	luna_attack_alta
12	=	luna_attackb
13	=	workshop_anim_00
14	=	workshop_anim_01
15	=	workshop_anim_02
16	=	workshop_anim_03
17	=	workshop_anim_04
18	=	workshop_anim_05
19	=	workshop_anim_06
20	=	workshop_anim_07
21	=	workshop_anim_08
22	=	workshop_anim_09
23	=	luna_idle_alt
24	=	luna_spawn
25	=	luna_run_injured
26	=	luna_idle_injured
27	=	luna_victory
28	=	luna_defeat
29	=	luna_death_alt
30	=	teleport_in
31	=	teleport_end
32	=	luna_run_alt
33	=	luna_force_staff_start
34	=	luna_force_staff_end
35	=	luna_forcestaff_enemy
36	=	lucentyr_attackb
37	=	lucentyr_cast_eclipse
38	=	lucentyr_cast
39	=	lucentyr_spawn
40	=	lucentyr_teleport_end
41	=	lucentyr_teleport_in
42	=	lucentyr_attack
43	=	lucentyr_victory
44	=	lucentyr_run_haste
45	=	lucentyr_run_haste_turns
46	=	lucentyr_idle_alt
47	=	luna_turns
48	=	luna_turns_dupe1_lookFrame_0
49	=	luna_turns_dupe1_lookFrame_1
50	=	luna_turns_dupe1_lookFrame_2
51	=	luna_turns_dupe2_lookFrame_0
52	=	luna_turns_dupe2_lookFrame_1
53	=	luna_turns_dupe2_lookFrame_2
54	=	luna_turns_dupe3_lookFrame_0
55	=	luna_turns_dupe3_lookFrame_1
56	=	luna_turns_dupe3_lookFrame_2
57	=	luna_turns_dupe4_lookFrame_0
58	=	luna_turns_dupe4_lookFrame_1
59	=	luna_turns_dupe4_lookFrame_2
60	=	lucentyr_run_haste_turns_dupe1_lookFrame_0
61	=	lucentyr_run_haste_turns_dupe1_lookFrame_1
62	=	lucentyr_run_haste_turns_dupe1_lookFrame_2
63	=	luna_turns_dupe1
64	=	luna_turns_dupe2
65	=	luna_turns_dupe3
66	=	luna_turns_dupe4
67	=	lucentyr_run_haste_turns_dupe1
68	=	head_rot_x
69	=	head_rot_y

*/
function character:Spawn(ply) 
	if SERVER then
		local e =  ents.Create("prop_dynamic") 
		self.lunamodel = e
		e:SetModel("models/heroes/luna/luna_mounted.mdl")
		e:SetPos(ply:GetPos()) 
		e:Spawn()
		e:SetParent(ply) 
		e:SetMoveType(MOVETYPE_NONE)
		e:AddEffects(EF_BONEMERGE)
	end
end
function character:Despawn(ply)
	if SERVER then 
		if self.lunamodel then
			self.lunamodel:Remove()
			self.lunamodel = nil
		end
	end
end
function character:Behavior(ply,asn)
	asn.debug = true
	asn:NewState("spawn",function(s,e) BGACT.SETSPD(e,0) return BGACT.PANIM(e,"luna_spawn")  end) 
	asn:NewState("idle",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"luna_idle") return 0.05 end) 
	asn:NewState("idlespecial", function(s,e) return BGACT.PANIM(e,"luna_idle_alt") end) 
	asn:NewState("walk",function(s,e) BGACT.SETSPD(e,180) BGACT.PANIM(e,"luna_run") return 0.05 end) 
	asn:NewState("run",function(s,e) BGACT.SETSPD(e,280) BGACT.PANIM(e,"luna_run_haste") return 0.05 end) 
	asn:NewState("attack",function(s,e) BGACT.ABCAST(e,"l_attack_ranged")  return BGACT.PANIM(e,"luna_attack",true) end) 
	
	asn:NewState("stunned",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"luna_stun") return ply.stuntime or 4 end)
	asn:NewState("flail",function(s,e) BGACT.SETSPD(e,0) BGACT.PANIM(e,"luna_flail") return ply.flailtime or 4 end)
	
	
	asn:NewGroup("g_stand",{"spawn","idle","attack","idlespecial"})
	
	asn:NewTransition("spawn","idle",BGCOND.ANMFIN)  
	asn:NewTransition("idle","idlespecial",BGCOND.RND01P) 
	asn:NewTransition("idlespecial","idle",BGCOND.ANMFIN)  
	
	asn:NewTransition("g_stand","walk",function(s,e) return e:KeyDown(IN_FORWARD) end)  
	asn:NewTransition("walk","idle",function(s,e) return !e:KeyDown(IN_FORWARD) end) 
	asn:NewTransition("walk","run",function(s,e) return e:KeyDown(IN_SPEED) end)  
	asn:NewTransition("run","walk",function(s,e) return !e:KeyDown(IN_SPEED) or !e:KeyDown(IN_FORWARD) end) 
	
	
	asn:NewTransition("g_stand","attack",function(s,e) return e:KeyDown(IN_ATTACK) and BGUTIL.ABREADY(e,"l_attack_ranged") end) 
	asn:NewTransition("attack","idle",BGCOND.ANMFIN) 
	
	asn:NewTransition("stunned","idle",BGCOND.ANMFIN) 
	asn:NewTransition("flail","idle",BGCOND.ANMFIN) 
	asn:SetState("spawn")
end 
