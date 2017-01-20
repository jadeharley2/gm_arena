AddCSLuaFile()
 
effect.dispellDelay = 10 //sec 
function effect:Begin(ent) 
	if (ent:IsPlayer() or ent:IsNPC())  then
		//ent:SetNoDraw(true)
		self:FadeOut(ent)
		return true
	end 
end

function effect:End(ent)  
	self:FadeIn(ent)
	//ent:SetNoDraw(false) 
end   


function effect:FadeOut(ent)
	local cc = ent:GetColor()
	local i = 0
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	timer.Create( tostring(math.random(0,9999999)), 0.1, 12, function()
		cc.a = 255*(1-i)
		i = i + 0.1
		ent:SetColor(cc) 
		if(i>=1) then 
			ent:SetNoDraw(true) 
		end
	end)
end
function effect:FadeIn(ent)
	local cc = ent:GetColor()
	local i = 0
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetNoDraw(false)
	timer.Create( tostring(math.random(0,9999999)), 0.1, 12, function()
		cc.a = 255*(i)
		i = i + 0.1
		ent:SetColor(cc) 
		if(i>=1) then 
			ent:SetRenderMode(RENDERMODE_NORMAL)
		end
	end)
end