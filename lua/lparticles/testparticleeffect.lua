AddCSLuaFile()


 
effect.nodes = //node = emitter
{
	test = {
		use3D = true, 
		material = "particle/particle_ring_blur",
		maxparticles = 64,
		
		drag = 0,
		startvel = Vector(0,0,0),
		lifetime = 0 ,
		dietime = 10.5,
		startalpha = 255,
		endalpha =  0,
		startsize = 10,
		endsize = 100 ,
		roll = 0, 
		rolldelta = 0, 
		gravity =  Vector( 0, 0, 0 ),
		
		emitter = { 
			{  func = ps_emit_instantaneously, count = 1, start_time = 0, },
			{  func = ps_emit_instantaneously, count = 2, start_time = 0.2, },
			{  func = ps_emit_instantaneously, count = 4, start_time = 0.4, },
			{  func = ps_emit_instantaneously, count = 8, start_time = 0.6, },
			{  func = ps_emit_instantaneously, count = 16, start_time = 0.8, },
			{  func = ps_emit_continuously, start_time = 1, pps = 500 }, 
		},
		init = { 
			//{ func = ps_init_abspos, pos = Vector(-121,-1290,-134) },
			{ func = ps_init_cpos, id = 1 },
			{ func = function(e,n,p,a) 
				p:SetVelocity(VectorRand()*100*Vector(1,1,0)) 
				p:SetAngles( Angle(90,0,0) ) 
			end }
		},
		child = { "test_a" }
	},
	test_a = {  
		material = "effects/fire_embers1",
		maxparticles = 64,
		
		drag = 0,
		startvel = Vector(0,0,100),
		lifetime = 0 ,
		dietime = 0.5,
		startalpha = 255,
		endalpha =  0,
		startsize = 10,
		endsize = 100 ,
		roll = 0,
		rolldelta = 0.1, 
		gravity =  Vector( 0, 0, 100 ),
		
		emitter = { 
			{  func = ps_emit_instantaneously, count = 10, start_time = 0, }, 
		},
		init = { 
			//{ func = ps_init_abspos, pos = Vector(-121,-1290,-134) }
			{ func = ps_init_cpos, id = 1 }
		} 
	}
}