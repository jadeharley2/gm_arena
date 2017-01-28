AddCSLuaFile()


   
effect.nodes = //node = emitter
{
	shunpo_smoke = {
		//use3D = true, 
		material = "particle/particle_smokegrenade",
		maxparticles = 64,
		
		drag = 0,
		startvel = Vector(0,0,0),
		lifetime = 0 ,
		dietime = 1,
		startalpha = 255,
		endalpha =  0,
		startsize = 30,
		endsize = 30,
		//roll = 0, 
		//rolldelta = 0.1, 
		gravity =  Vector( 0, 0, 0 ),
		 
		emitter = {  
			{  func = ps_emit_instantaneously, count = 20  }, 
		},
		init = {  
			{ func = ps_init_cpos, id = 1 },
			{ func = function(e,n,p,a)  
				p:SetPos(p:GetPos()+VectorRand()*10)
				p:SetRollDelta(math.Rand( -2, 2 ))
				p:SetVelocity(VectorRand()*1)  
				p:SetColor(50,5,5) 
				//e:AddTimedCast(n,0.1,30,function()
				//	local entvel = e._cpoints[1][1]:GetVelocity()
				//	p:SetVelocity(entvel*0.9)  
				//end)
			end }
		},
	},
	shunpo_flash = {
		//use3D = true, 
		material = "effects/yellowflare",
		maxparticles = 64,
		
		drag = 0,
		startvel = Vector(0,0,0),
		lifetime = 0 ,
		dietime = 0.1,
		startalpha = 255,
		endalpha =  0,
		startsize = 20,
		endsize = 80, 
		//roll = 0, 
		//rolldelta = 0.1, 
		gravity =  Vector( 0, 0, 0 ),
		 
		emitter = { 
			{  func = ps_emit_instantaneously, count = 10  }, 
		},
		init = {  
			{ func = ps_init_cpos, id = 1 },
			{ func = function(e,n,p,a)  
				p:SetRollDelta(math.Rand( -2, 2 ))
				p:SetVelocity(VectorRand()*5)  
				p:SetColor(255,200,200) 
			end }
		},
		child = {"shunpo_smoke"}
	}
}