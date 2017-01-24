AddCSLuaFile()

ability.icon = "vgui/icons/spells/Bard_R.png"
ability.type = "self"  
ability.cooldownDelay = 2
ability.range = 500
ability.effect = "ignite"

function ability:Begin(ply, trace) 
	if ply:Alive() then  
		if SERVER then 
			DoForAll("kindredClientPJTex22("..tostring(ply:EntIndex())..")")
			for k,v in pairs(player.GetAll()) do 
				if  v != ply and v:GetPos():Distance(ply:GetPos())<self.range then 
					local meffect = MagicEffect(self.effect)
					meffect.amount = 100
					meffect.owner = ply.owner
					local result = meffect:Cast(v) 
				end 
			end
		end
		return true
	end
end

  local pjtc = 0
function kindredClientPJTex22(eid)
	if pjtc and pjtc != 0 then
		pjtc:Remove()
	end
	local e = Entity(eid)
	pjtc = ProjectedTexture()
	pjtc:SetPos(e:GetPos()+Vector(0,0,150))
	pjtc:SetAngles(Angle(90,0,0))
	pjtc:SetBrightness( 10 )
	pjtc:SetColor( Color(200,10,10,200) )
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