AddCSLuaFile()

ability.icon = "vgui/icons/spells/Kindred_W.png"
ability.type = "self" 
ability.cooldownDelay = 15
ability.dispellDelay = 12 

function ability:Begin(ply, trace) 
	if ply:Alive() then 
		ply.wfrenzy = true
		ply.wfrenzypos = ply:GetPos()
		//Dota.PlaySequence2(ply, "casts2")
		if SERVER then 
			DoForAll("kindredClientPJTex("..tostring(ply:EntIndex())..")")
		end
		return true
	end
end
function ability:End(ply, trace) 
	ply.wfrenzy = false
end
  
local pjtc = 0
function kindredClientPJTex(eid)
	if pjtc and pjtc != 0 then
		pjtc:Remove()
	end
	local e = Entity(eid)
	pjtc = ProjectedTexture()
	pjtc:SetPos(e:GetPos()+Vector(0,0,150))
	pjtc:SetAngles(Angle(90,0,0))
	pjtc:SetBrightness( 10 )
	pjtc:SetColor( Color(100,-100,100,200) )
	pjtc:SetTexture( "effects/flashlight/hard" )
	pjtc:SetEnableShadows( false )
	pjtc:SetFOV( 150 )
	pjtc:Update() 
	MsgN(pjtc) 
	timer.Simple(10,function() PJTCFadeout(pjtc) end)
	timer.Simple(12,function() if pjtc and pjtc != 0 then pjtc:Remove() pjtc = 0 end end)
end
function PJTCFadeout(p)
	local ii = 0
	timer.Create("atid", 0.01, 20, function() 
		if p != 0 then
			p:SetBrightness(10-(ii*10))
			p:Update()
			ii= ii + 0.05
			if ii>0.9 then
				p:Remove() 
				pjtc = 0
			end
		end
	end)
	timer.Start("atid")
end 