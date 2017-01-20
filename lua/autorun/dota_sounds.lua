AddCSLuaFile()

sound.Add( { name = "BodyImpact_Common.Light",
	channel = CHAN_BODY,
	volume = 0.2,
	level = 81,
	pitch = { 100 },
	sound = { 
		"heroes/common/body_impact_light_01.wav",
		"heroes/common/body_impact_light_02.wav",
		"heroes/common/body_impact_light_03.wav",
		"heroes/common/body_impact_light_04.wav"
	}
} )
sound.Add( { name = "BodyImpact_Common.Medium",
	channel = CHAN_BODY,
	volume = 0.3,
	level = 81,
	pitch = { 100 },
	sound = { 
		"heroes/common/body_impact_medium_01.wav",
		"heroes/common/body_impact_medium_02.wav",
		"heroes/common/body_impact_medium_03.wav",
		"heroes/common/body_impact_medium_04.wav"
	}
} )
sound.Add( { name = "BodyImpact_Common.Heavy",
	channel = CHAN_BODY,
	volume = 0.4,
	level = 81,
	pitch = { 100 },
	sound = { 
		"heroes/common/body_impact_heavy_01.wav",
		"heroes/common/body_impact_heavy_02.wav" 
	}
} )