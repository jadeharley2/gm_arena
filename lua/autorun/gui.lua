AddCSLuaFile()

local hud = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudWeaponSelection = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function(name)
	if !LocalPlayer().dotahero then return end
	if (hud[name]) then return false end
end)

hook.Add( "HUDPaint", "HUDMain", function()
	if !LocalPlayer().dotahero then return end

	local x,y,w,h = 25,ScrH()-150,250,125
	surface.SetDrawColor(0,0,0,150)
	surface.DrawRect(x,y,w,h)

	//Set current hero vars
	local hero = LocalPlayer().stats

	//SetFont
	surface.SetFont("Trebuchet24")

	//Health
	local health = LocalPlayer():Health()
	local maxHealth = hero.health
	local healthRatio = math.Min(health	/ maxHealth, 1)
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(x+9,y+9,w-18,h-103)

	surface.SetDrawColor(255,0,0,255)
	surface.DrawRect(x+10,y+10,(w-20)*healthRatio,h-105)

	surface.SetTextColor(255,255,255,255)
	surface.SetTextPos(x+w/2-surface.GetTextSize(health)/2, y+10)
	surface.DrawText(health)

	surface.SetTextColor(50,205,50,255)
	surface.SetTextPos(x+w-40,y+10)
	surface.DrawText("+" .. math.Round(hero.healthregen))

	//Mana,Energy,etc...
	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(x+9,y+34,w-18,h-103)

	surface.SetDrawColor(0,0,255,255)
	surface.DrawRect(x+10,y+35,w-20,h-105)

	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos(x+w/2-surface.GetTextSize(0)/2,y+35)
	surface.DrawText(0)

	//Skills bar
	local num = 1
	for k,v in SortedPairs(LocalPlayer().abilities) do
		if(k != "l_attack_melee" && k != "l_attack_ranged") then
			local icon = Material( v.icon, "noclamp smooth" )
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(icon)
			surface.DrawTexturedRect((x+25)*num,y+65,45,45)
			num = num + 1
		end
	end

end )
