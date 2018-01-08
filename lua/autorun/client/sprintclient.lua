local Version = "2.3"
if not TTTFGAddons then
	TTTFGAddons = {}
end
table.insert(TTTFGAddons, "TTT Sprint")
local ChatMessage = CreateClientConVar( "ttt_fgaddons_textmessage", "1", true, false, "Enables or disables the message in the chat. Def:1"):GetBool()
hook.Add("TTTBeginRound", "TTTBeginRound4TTTFGAddons", function()
	ChatMessage = CreateClientConVar( "ttt_fgaddons_textmessage", "1", true, false, "Enables or disables the message in the chat. Def:1"):GetBool()
	local String = ""
	for i = 1, #TTTFGAddons do
		if String == "" then
			String = TTTFGAddons[i]
		else
			String = String..", "..TTTFGAddons[i]
		end
	end
	if ChatMessage then
		chat.AddText("TTT FG Addons: ", Color( 255, 255, 255 ), "You are running "..String..".")
		chat.AddText("TTT FG Addons: ", Color( 255, 255, 255 ), "Be sure to check out the Settings in the ", Color( 255, 0, 0 ),"F1", Color( 255, 255, 255 )," menu.")
		chat.AddText("TTT FG Addons: ", Color( 255, 255, 255 ), "You can disable this message in the Settings (", Color( 255, 0, 0 ),"F1", Color( 255, 255, 255 ),").")
	end
end)
local function ConVars()
	net.Start( "SprintGetConVars" )
	net.SendToServer()
end
local Multiplikator = 0.5
local Crosshair = 1
local Regenerate = 5
local Consumption = 1
net.Receive("SprintGetConVars", function()
	local Table = net.ReadTable()
	Multiplikator = Table[1]
	Crosshair = Table[2]
	Regenerate = Table[3]
	Consumption = Table[4]
end)
ConVars()
local xPos = CreateClientConVar( "ttt_sprint_hud_x", "14.5", true, false, "The relative x-position of the HUD. (0-100) Def: 14.5")
local yPos = CreateClientConVar( "ttt_sprint_hud_y", "94.4", true, false, "The relative y-position of the HUD. (0-100) Def: 94.4")
local ActivateKey = CreateClientConVar( "ttt_sprint_activate_key", "0", true, false, "The key used to sprint. (0 = Use, 1 = Shift, 2 = Control, 3 = Custom, 4 = Double tap) Def:1")
local CustomActivateKey = CreateClientConVar( "ttt_sprint_activate_key_custom", "32", true, false, "The custom key used to sprint if ttt_sprint_activate_key = 3. It has to be a Number. (Example: 32 = V Key) Def: 32 Key Numbers: https://wiki.garrysmod.com/page/Enums/KEY")
local DoubleTapTime = CreateClientConVar( "ttt_sprint_doubletaptime", "0.25", true, false, "The time you have for double tapping if ttt_sprint_activate_key = 4. (0.001-1) Def:0.25")
local realProzent = 100
local sprinting = false
local lastReleased = -1000
local DoubleTapActivated = false
local CrosshairGroesse = 1
local TimerCon = CurTime()
local TimerReg = CurTime()
local surface = surface
local ply = LocalPlayer()
surface.CreateFont("STAMINA", {font = "Octin Sports RG", size = 28, weight = 750})
surface.CreateFont("TabTop", {font = "Octin Sports RG", size = 15, weight = 200})
hook.Add("HUDPaint", "SprintHUD", function()
	local client = LocalPlayer()
	if not TEAM_SPEC then 
		return 
	end -- nicht ttt
	if LocalPlayer():Alive() and LocalPlayer():IsTerror() and (not LocalPlayer():IsSpec()) then
		local Prozent = math.min(math.max(math.floor(realProzent),0),100)
		local x =  math.floor(ScrW()*math.min(math.max(xPos:GetFloat(),0.01),100)/100)
		local y = math.floor(ScrH()*math.min(math.max(yPos:GetFloat(),0.01),100)/100)
		--draw.RoundedBox(2, x-5, y-10, 250, 40, Color(40, 49, 58, 255))
		--draw.RoundedBox(2, x+4, y+4, 250, 40, Color(40, 49, 58, 255))
		surface.SetDrawColor(0, 0, 144, 255)
		surface.DrawRect (x+4, y+4, 10, 40)
		surface.SetDrawColor(40, 49, 58, 255)
		surface.DrawRect(x+14, y+4, 240, 40)
		surface.SetDrawColor(0, 0, 200, 255)

		
		--if 230/100*Prozent > 0 then
			surface.DrawRect( x+14, y+4, 254/100*Prozent-14, 40 )
			--surface.DrawRect( x+5, y+13, 8, 25-8*2 )
			--surface.SetTexture( surface.GetTextureID( "gui/corner8" ) )
			--surface.DrawTexturedRectRotated( x+14 + 8/2 , y+5 + 8/2, 8, 8, 0 )
			--surface.DrawTexturedRectRotated( x+14 + 8/2 , y+5 + 25 -8/2, 8, 8, 90 )
			
			--if 230/100*Prozent > 13 then
				---surface.DrawRect( x+5+230/100*Prozent-8, y+13, 8, 25-8*2 )
				---surface.DrawRect( x+5 + 230/100*Prozent - 8/2 , y+5 + 8/2, 8, 8, 270 )
				---surface.DrawRect( x+5 + 230/100*Prozent - 8/2 , y+5 + 25 - 8/2, 8, 8, 180 )
			--else
				--surface.DrawRect( x+5 + math.max(230/100*Prozent-8, 8), y+5, 8/2, 25 )
			--end
		--end
		--draw.SimpleText(Prozent, "STAMINA", x+2, y+7, Color(0, 0, 0),TEXT_ALIGN_LEFT)
		draw.SimpleText(Prozent, "STAMINA", x+20, y+10, Color(255, 255, 255),TEXT_ALIGN_LEFT)
		draw.SimpleText("STAMINA", "TabTop", x+5, y-10, Color(255, 255, 255))
	end
end)
function SprintKey()
	if ActivateKey:GetFloat() == 0 then 
		return LocalPlayer():KeyDown( IN_USE )
	elseif ActivateKey:GetFloat() == 1 then 
		return input.IsKeyDown( KEY_LSHIFT )
	elseif ActivateKey:GetFloat() == 2 then 
		return input.IsKeyDown( KEY_LCONTROL )
	elseif ActivateKey:GetFloat() == 3 then 
		return input.IsKeyDown( CustomActivateKey:GetFloat() )
	end
	return false
end
local function SprintFunction()
	if realProzent > 0 then
		if not sprinting then
			SpeedChange(true)
			sprinting = true
			TimerCon = CurTime()
		end
		realProzent = realProzent-(CurTime()-TimerCon)*(math.min(math.max(Consumption, 0.1),5 )*250)
		TimerCon = CurTime()
	else
		if sprinting then
			SpeedChange(false)
			sprinting = false
		end
	end
end
hook.Add("TTTPrepareRound", "TTTSprint4TTTPrepareRound", function()
	realProzent = 100
	ConVars()
	hook.Add( "Think", "TTTSprint4Think", function()
		if LocalPlayer():KeyReleased( IN_FORWARD ) and ActivateKey:GetFloat() == 4 then
			lastReleased = CurTime()
		end
		if ActivateKey:GetFloat() == 4 and LocalPlayer():KeyDown( IN_FORWARD ) and (lastReleased + math.min(math.max(DoubleTapTime:GetFloat(),0.001),1) >= CurTime() or DoubleTapActivated) then
			SprintFunction()
			DoubleTapActivated = true	
			TimerReg = CurTime()			
		elseif LocalPlayer():KeyDown( IN_FORWARD ) and SprintKey() then
			SprintFunction()
			DoubleTapActivated = false
			TimerReg = CurTime()
		else
			if sprinting then
				SpeedChange(false)
				sprinting = false
				TimerReg = CurTime()
			end
			realProzent = realProzent+(CurTime()-TimerReg)*(math.min(math.max(Regenerate, 0.01),2 )*250)
			TimerReg = CurTime()
			DoubleTapActivated = false
		end
		--[[if not TimerReg then
			TimerReg = CurTime()
		end
		if not TimerCon then
			TimerCon = CurTime()
		end--]]
		if realProzent < 0 then
			realProzent = 0
		elseif realProzent > 100 then
			realProzent = 100
		end
	end)
end)
function SpeedChange(Bool)
	net.Start( "SprintSpeedset" )
		if Bool then
			net.WriteFloat(math.min(math.max(Multiplikator, 0.1),2 ))
			ply.mult = 1+math.min(math.max(Multiplikator, 0.1),2 )
		else
			net.WriteFloat(0)
			ply.mult = nil
		end
	net.SendToServer()
	if Crosshair then
		if Bool then
			CrosshairGroesse = GetConVarString( "ttt_crosshair_size" )
			RunConsoleCommand( "ttt_crosshair_size", "0" )
		else
			RunConsoleCommand( "ttt_crosshair_size", CrosshairGroesse )
		end
	end
end
local function DefaultI()
	RunConsoleCommand( "ttt_sprint_hud_x", "43.75" )
	RunConsoleCommand( "ttt_sprint_hud_y", "89" )
end
local function DefaultII()
	RunConsoleCommand( "ttt_sprint_hud_x", "1.4" )
	RunConsoleCommand( "ttt_sprint_hud_y", "80.6" )
end
local function DefaultIII()
	RunConsoleCommand( "ttt_sprint_hud_x", "85" )
	RunConsoleCommand( "ttt_sprint_hud_y", "92.7" )
end
local function DefaultIV()
	RunConsoleCommand( "ttt_sprint_hud_x", "18.2" )
	RunConsoleCommand( "ttt_sprint_hud_y", "85.4" )
end
local function DefaultV()
	RunConsoleCommand( "ttt_sprint_hud_x", "18.2" )
	RunConsoleCommand( "ttt_sprint_hud_y", "89" )
end
local function DefaultVI()
	RunConsoleCommand( "ttt_sprint_hud_x", "18.2" )
	RunConsoleCommand( "ttt_sprint_hud_y", "92.7" )
end
hook.Add("TTTSettingsTabs", "TTTSprint4TTTSettingsTabs", function(dtabs)
	local settings_panel = vgui.Create( "DPanelList",dtabs )
	settings_panel:StretchToParent(0,0,dtabs:GetPadding()*2,0)
	settings_panel:EnableVerticalScrollbar(true)
	settings_panel:SetPadding(10)
	settings_panel:SetSpacing(10)
	dtabs:AddSheet( "Sprint", settings_panel, "icon16/arrow_up.png", false, false, "The sprint settings")
	local AddonList = vgui.Create( "DIconLayout", settings_panel )
	AddonList:SetSpaceX( 5 )
	AddonList:SetSpaceY( 5 )
	AddonList:Dock( FILL )
	AddonList:DockMargin( 5, 5, 5, 5 )
	AddonList:DockPadding( 10, 10, 10, 10 )
	
	local General_Settings = vgui.Create( "DForm" )
	General_Settings:SetSpacing( 10 )
	General_Settings:SetName( "General settings" )
	General_Settings:SetWide(settings_panel:GetWide()-30)
	settings_panel:AddItem(General_Settings)
	General_Settings:CheckBox("Print chat message at the beginning of the round (TTT FG Addons)","ttt_fgaddons_textmessage")
	
	local settings_sprint_tabII = vgui.Create( "DForm" )
	settings_sprint_tabII:SetSpacing( 10 )
	settings_sprint_tabII:SetName( "Controls" )
	settings_sprint_tabII:SetWide(settings_panel:GetWide()-30)
	settings_panel:AddItem(settings_sprint_tabII)
	local Settings_text = vgui.Create("DLabel", General_Settings)
	Settings_text:SetText("Activation method:")
	Settings_text:SetColor(Color(0,0,0))
	settings_sprint_tabII:AddItem( Settings_text )
	local Key_box = vgui.Create("DComboBox")
	local function Auswahl()
		if ActivateKey:GetFloat() == 0 then
			KeySelected = "Use Key"
		elseif ActivateKey:GetFloat() == 1 then
			KeySelected = "Shift Key"
		elseif ActivateKey:GetFloat() == 2 then
			KeySelected = "Control Key"
		elseif ActivateKey:GetFloat() == 3 then
			KeySelected = "Custom Key"
		elseif ActivateKey:GetFloat() == 4 then
			KeySelected = "Double tap"
		else
			KeySelected = " "
		end
	end

	local function KeySettingExtra()
		if KeySelected == "Custom Key" then
			settings_sprint_tabII:TextEntry("Key Number:", "ttt_sprint_activate_key_custom")
			local Link = vgui.Create("DLabelURL")
			Link:SetText("Key Numbers: https://wiki.garrysmod.com/page/Enums/KEY")
			Link:SetURL("https://wiki.garrysmod.com/page/Enums/KEY")
			settings_sprint_tabII:AddItem(Link)
		elseif KeySelected == "Double tap" then
			settings_sprint_tabII:NumSlider("Double tap time", "ttt_sprint_doubletaptime", 0.001, 1, 2)
		end
	end
	local function ComboBox()
		settings_sprint_tabII:AddItem( Settings_text )
		Key_box:Clear()
		Key_box:SetValue(KeySelected)
		Key_box:AddChoice("Use Key")
		Key_box:AddChoice("Shift Key")
		Key_box:AddChoice("Control Key")
		Key_box:AddChoice("Custom Key")
		Key_box:AddChoice("Double tap")
		settings_sprint_tabII:AddItem( Key_box )
	end
	function Key_box:OnSelect(table_key_box, Ausgewaehlt, data_key_box)
		if Ausgewaehlt == "Use Key" then
			RunConsoleCommand( "ttt_sprint_activate_key", "0" )
		elseif Ausgewaehlt == "Shift Key" then
			RunConsoleCommand( "ttt_sprint_activate_key", "1" )
		elseif Ausgewaehlt == "Control Key" then
			RunConsoleCommand( "ttt_sprint_activate_key", "2" )
		elseif Ausgewaehlt == "Custom Key" then
			RunConsoleCommand( "ttt_sprint_activate_key", "3" )
		elseif Ausgewaehlt == "Double tap" then
			RunConsoleCommand( "ttt_sprint_activate_key", "4" )
		end 
		settings_sprint_tabII:Clear()
		KeySelected = Ausgewaehlt
		ComboBox()
		KeySettingExtra()
	end
	Auswahl()
	ComboBox()
	KeySettingExtra()
	
	local settings_sprint_tab = vgui.Create( "DForm" )
	settings_sprint_tab:SetSpacing( 10 )
	settings_sprint_tab:SetName( "HUD Positioning" )
	settings_sprint_tab:SetWide(settings_panel:GetWide()-30)
	settings_panel:AddItem(settings_sprint_tab)
	
	settings_sprint_tab:NumSlider("X Postion", "ttt_sprint_hud_x", 0, 100, 2)
	settings_sprint_tab:NumSlider("Y Postion", "ttt_sprint_hud_y", 0, 100, 2)
	
	local Settings_text = vgui.Create("DLabel", General_Settings)
	Settings_text:SetText("Presets:")
	Settings_text:SetColor(Color(0,0,0))
	settings_sprint_tab:AddItem( Settings_text )
	
	local DefaultI_button = vgui.Create("DButton")
	DefaultI_button:SetText("Lower middle")
	DefaultI_button.DoClick = DefaultI
	settings_sprint_tab:AddItem( DefaultI_button )
	
	local DefaultII_button = vgui.Create("DButton")
	DefaultII_button:SetText("On top of role")
	DefaultII_button.DoClick = DefaultII
	settings_sprint_tab:AddItem( DefaultII_button )
	
	local DefaultIII_button = vgui.Create("DButton")
	DefaultIII_button:SetText("Lower right corner")
	DefaultIII_button.DoClick = DefaultIII
	settings_sprint_tab:AddItem( DefaultIII_button )
	
	local DefaultIV_button = vgui.Create("DButton")
	DefaultIV_button:SetText("Next to role")
	DefaultIV_button.DoClick = DefaultIV
	settings_sprint_tab:AddItem( DefaultIV_button )
	
	local DefaultV_button = vgui.Create("DButton")
	DefaultV_button:SetText("Next to role 2")
	DefaultV_button.DoClick = DefaultV
	settings_sprint_tab:AddItem( DefaultV_button )
	
	local DefaultVI_button = vgui.Create("DButton")
	DefaultVI_button:SetText("Next to role 3")
	DefaultVI_button.DoClick = DefaultVI
	settings_sprint_tab:AddItem( DefaultVI_button )
	
	settings_sprint_tab:SizeToContents()
	local Version_text = vgui.Create("DLabel", General_Settings)
	Version_text:SetText("Version: "..Version.." by Fresh Garry")
	Version_text:SetColor(Color(100,100,100))
	settings_panel:AddItem( Version_text )
end)


hook.Add("TTTPlayerSpeedModifier", "TTTSprint4TTTPlayerSpeed" , function(ply)
	return ply.mult
end)