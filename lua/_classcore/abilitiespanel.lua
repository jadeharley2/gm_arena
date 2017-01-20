AddCSLuaFile()

if SERVER then return nil end

CabPanel = CabPanel or nil

local SpellIcons = 
{
	"vgui/icons/spells/enchantress_untouchable.png",
	"vgui/icons/spells/enchantress_enchant.png",
	"vgui/icons/spells/enchantress_natures_attendants.png",
	"vgui/icons/spells/enchantress_impetus.png",
	
}
SpellIcons = 
{
	"vgui/icons/spells/luna_lucent_beam.png",
	"vgui/icons/spells/luna_moon_glaive.png",
	"vgui/icons/spells/luna_lunar_blessing.png",
	"vgui/icons/spells/luna_eclipse.png",
	
}
function DotaAbOpen()
	if CabPanel != nil then DotaAbClose() end
	CabPanel = vgui.Create( "DPanel" )
	//CabPanel:SetDeleteOnClose( true )
	local abWidth = 84
	
	local abx = 10
	
	for k=1,4 do
		local abImg = vgui.Create( "DImage", CabPanel ) 
		abImg:SetPos( abx, 10 ) 
		abImg:SetSize( abWidth, abWidth )  
		abImg:SetImage( SpellIcons[k] )
		abx = abx + abWidth+2 
	end
	CabPanel:SetSize( abx+10, abWidth+20 )
	
	CabPanel:SetPos( ScrW()/2-CabPanel:GetWide()/2, ScrH()-CabPanel:GetTall() )
	CabPanel:SetBGColor( 50, 60, 30 )
	
	
	//abImg3_delay = vgui.Create( "DPanel",CabPanel )
	//abImg3_delay:SetPos( abImg3:GetPos() ) 
	//abImg3_delay:SetSize( abImg3:GetWide(), abImg3:GetTall()/2 ) 
	
end
function DotaAbClose()
	if CabPanel.Close then CabPanel:Close() end
	CabPanel:Remove()
	CabPanel = nil
end