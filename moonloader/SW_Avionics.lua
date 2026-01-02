--Default encoding: Cyrillic, Windows-1251

require 'moonloader'
require 'sampfuncs'

sampev = require 'lib.samp.events'

local as_action = require('moonloader').audiostream_state
local safp = require 'safp'

local CentralPosX
local CentralPosY

local RenderColor

local keys = require "vkeys"
local inicfg = require "inicfg"

local IsAvionicsActive
local IsPlaneRendered
local IsTabPressed

local SPO_IsAutoFlaresKeyNeeded

local Iteration = 0
local STime

local Ver = "0.1.7-beta.2001"

script_name("SW_Avionics")
script_author("d7.KrEoL")
script_version(Ver)
script_url("https://vk.com/d7kreol")
script_description("Скрипт авионики для ЛА.")

local settings = inicfg.load(
        {
          maincfg = {
            IsNightMode=false,--Режим интерфейса "ночь"
			IsAutoLeave=false,--Автопокидание
			IsAutoFlares=false,--АвтоЛТЦ
			IsHUDEnabled = true,--Включена ли сетка ИЛС
			IsRadioEnabled = false,--Включено ли радио
			IsRadioFullyOff = false,--Полное отключение радио (TODO добавить автоотключение при входе в ТС, при активном данном параметре)
			IsSpoEnabled = true,--Система предупреждения об угрозе
			IsBETTYDefault = true,--Речевой информатор по умолчанию для неизвестных ЛА
			IsTargetInputActive = true,--Получение целеуказания из чата
			IsShowMessage = true,--Показ сообщения при посадке в технику
			IsBallisticBombRender = true, -- Отображение баллистического вычислителя (бомбы) в режиме воздух-земля
			IsBallisticGunRender = false, -- Отображение балистического вычислителя (пушка) в режиме воздух-земля
			IsShowInfantry = true,
			Localization = "Russian.txt",
			BombBallisticRU = 1.395,
			BombBallisticEN = 1.210,
			AvionicsMode=0,--0 не отображать, 1 воздух-воздух, 2 воздух-земля
			OffcetX=0,--Оффсет для ИЛС
			OffcetY=0,--Оффсет для ИЛС
			ZoomFix=10,--Скорость приближения камеры
			DangerAlt = 20,--Опасная высота
			PrevWPTKey=tonumber(keys.VK_OEM_4),--Бинд клавиши предыдущего ППМ
			NextWPTKey=tonumber(keys.VK_OEM_6),--Бинд клавиши следующего ППМ
			DropLockKey=tonumber(keys.VK_BACK),--Бинд клавиши сброса захвата
			NextModeKey=tonumber(keys.VK_3),--Бинд клавиши следующего режима
			PrevModeKey=tonumber(keys.VK_1),--Бинд клавиши предыдущего режима
			OpenMenuKey=tonumber(keys.VK_4)--Бинд клавиши показа меню
          },
        },
        "avionics"
)

-------------imgui

local imgui = require "imgui"
local encoding = require 'encoding'
encoding.default = 'CP1251'
local MainWindow = imgui.ImBool(false)

if Lang_Eng then
	GUI_KeyInput_BombBallistic = imgui.ImFloat(settings.maincfg.BombBallisticEN)
else
	GUI_KeyInput_BombBallistic = imgui.ImFloat(settings.maincfg.BombBallisticRU)
end
local GUI_KeyInput_DangerAlt = imgui.ImInt(settings.maincfg.DangerAlt)
local GUI_KeyInput_PrevWPT = imgui.ImInt(settings.maincfg.PrevWPTKey)
local GUI_KeyInput_NextWPT = imgui.ImInt(settings.maincfg.NextWPTKey)
local GUI_KeyInput_DropLock = imgui.ImInt(settings.maincfg.DropLockKey)
local GUI_KeyInput_NextMode = imgui.ImInt(settings.maincfg.NextModeKey)
local GUI_KeyInput_PrevMode = imgui.ImInt(settings.maincfg.PrevModeKey)
local GUI_KeyInput_OpenMenu = imgui.ImInt(settings.maincfg.OpenMenuKey)

-----------------

local Lang_Eng
local Messages = {}
local Languages
local SelectedLanguage

local PrevX
local PrevY
local PrevZ
local PrevSpd
local PrevHdng
local IterTimer

local AudioTimer
local AudioMax
local IsAudioAvaliable
local AudioLaunchAuthorizedTime = 0

local PPMX
local PPMY
local PPMZ
local PPMCur

local IsAutoPilot

local WeapCur
local WeapAmmo
local LTCCur
local IsInLock
local IsUnderAttack
local TargetDist
local TargetAlt
local LongRageMarkers

local vehTarget
local radarSize

local Text_FontMain
local Text_FontMedium
local Text_FontLow
local Text_FontLowest

local T_radZColor
local T_deltaZColor
local T_vZColor
local T_deltaSpdColor
local T_deltaZColor

local T_deltaSpdPosX
local T_deltaSpdPosY

local IsCameraMode
local Cam_IsOnceAttached
local Cam_PrevRotX
local Cam_PrevRotY
local Cam_M_PrevX
local Cam_M_PrevY
local Cam_TarX
local Cam_TarY
local Cam_TarZ
local Cam_Zoom

local IsNightVis

local deltaZ
local deltaSpd

local IsGearDown
local IsMagneto

local IsDangerAlt
local DamageLevel
local AltStatus

local IsRadarEnabled

local MarkId
local GlobalTarget

----------------Ballistic
local BallisticHistory

----------------HUD icons
local hud_ap_ac
local hud_ap_da
local hud_ap_ls
local hud_ap_lv
local hud_ap_sf
local hud_comp
local hud_gear
local hud_ils
local hud_lineh
local hud_linev
local hud_lock
local hud_mesh
local hud_numboxSpd
local hud_numboxAlt
local hud_numboxAz
local hud_out1
local hud_out2
local hud_out3
local hud_pithb
local hud_pithh
local hud_pithn
local hud_pithp
local hud_pitht
local hud_radar
local hud_self
local hud_vvec
local hud_warn
local hud_fire
local hud_aft
----------------

-----------------------------Audio warning systems
local audio_startingmessage
local audio_pullup
local audio_pullup2
local audio_power
local audio_systemfail
local audio_catapult
local audio_hydrofail
local audio_leftenginefire
local audio_rightenginefire
local audio_autopilotoff
local audio_maxG
local audio_threat
local audio_launch

local audio_misfu
local audio_misfd
local audio_misru
local audio_misrd
local audio_misbu
local audio_misbd
local audio_mislu
local audio_misbd
local audio_mislu
local audio_misld
----------------------------

---------------------landing system
local landing_data
local landing_dist
---------------------


function main()

	repeat wait(0) until isSampLoaded()
	--repeat wait(0) until isSampAvailable()
	print("Loading avionics script")
	
	InitVars()
	InitGUI()
	
	
	
	print("VirPiL Avionics Script Loaded")
	print(string.format("{00A2FF}V{FFFFFF}ir{00A2FF}P{FFFFFF}i{00A2FF}L {FFFFFF}Avionics. Версия: {00A2FF}%s", Ver))
	print("{00A2FF}discord.gg/QSKkNhZrTh")

	OnUpdateF()
  
end

------------------------------------------------------#region #INIT
function InitVars()
	InitLocalization()
	IsAvionicsActive = true
	Iteration = 100
	STime = os.clock()--socket.gettime()
	
	InitPrevs()
	InitGlobalsRender()
	InitGlobalsWaypoints()
	InitGlobalsCamera()
	InitGlobalsFlyMode()
	InitGlobalsBVRMode()
	InitGlobalsGRDMode()
	InitGlobalsLRFMode()
	InitGlobalsLNDMode()
	InitTarget()
	InitLandingData()
end

function InitGlobalsRender()
	if settings.maincfg.IsNightMode then
		RenderColor = 0xFF008800
	else
		RenderColor = 0xFF00FF00
	end
	CentralPosX, CentralPosY = getScreenResolution()
	CentralPosX = CentralPosX/2
	CentralPosY = CentralPosY/2
	Lang_Eng = false
	
	T_deltaSpdPosX = CentralPosX-303
	T_deltaSpdPosY = CentralPosY-100
	T_deltaSpdColor = RenderColor
	T_deltaZColor = RenderColor
	T_radZColor = RenderColor
	T_vZColor = RenderColor
end

function InitGlobalsSystems()
	DamageLevel = 0
	AltStatus = 0
	
	IsRadarEnabled = false
	
	IsPlaneRendered = false
	IsTabPressed = false
	IsGearDown = true
	IsMagneto = false
	IsAudioAvaliable = true
	AudioLaunchAuthorizedTime = os.clock()
	
	SPO_IsAutoFlaresKeyNeeded = false
	IsDangerAlt = false
end

function InitGlobalsWaypoints()
	PPMX = {}
	PPMY = {}
	PPMZ = {}
	PPMCur = -1
	
	IsAutoPilot = false
end

function InitGlobalsCamera()
	IsCameraMode = false
	Cam_IsOnceAttached = false
	Cam_PrevRotX = 0
	Cam_PrevRotY = 0
	Cam_M_PrevX = 0
	Cam_M_PrevY = 0
	Cam_TarX = -999
	Cam_TarY = -999
	Cam_TarZ = -999
	Cam_Zoom = 70
	IsNightVis = false
end

function InitGlobalsFlyMode()
	
end

function InitGlobalsBVRMode()
	WeapCur = ""
	WeapAmmo = 0
	LTCCur = 0
	IsInLock = false
	IsUnderAttack = false
	TargetDist = 0
	TargetAlt = 0
end

function InitGlobalsGRDMode()
	BallisticHistory = {}
	for i = 0, 5 do
		table.insert(BallisticHistory, {x = 0, y = 0, z = 0})
	end
end

function InitGlobalsLRFMode()
	LongRageMarkers = {playerid, isActiveMarker, coords = {x, y, z}}
	MarkId = -1
	GlobalTarget = nil
end

function InitGlobalsLNDMode()
	
end

function InitLocalization()
	Languages = GetLocalizationFiles()
	ReloadLocalization()
	SelectedLanguage = imgui.ImInt(0)
end

function ReloadLocalization()
	ClearLocalizationData()
	LoadLocalizationFile(settings.maincfg.Localization)
end

function LoadLocalizationFile(path)
	path = getGameDirectory() .. "\\moonloader\\resource\\avionics\\localization\\" .. path
	return GetFileDataLines(path)
end

function ClearLocalizationData()
	if Messages == nil then return end
	for i in ipairs(Messages) do
		Messages[i] = nil;
	end
	Messages = {}
end

function RestoreLocalizationContainer()
	if Messages == nil then Messages = {} end
end

function GetFileDataLines(path)
	print("Trying to load localization data from file: ", path)
	RestoreLocalizationContainer()
	if not doesFileExist(path) then print("Localization file does not exist: ", path) return {} end
	local i = 0
	for line in io.lines(path) do
		print("Messages[", i, "] - ", line)
		i = i + 1
		table.insert(Messages, line)
	end
end

function GetLocalizationMessage(index)
	if Messages == nil then return "ERR: NO LOCALIZATION FOUND" end
	if index > #Messages then return "ERR: MESSAGE " .. index .. " - LOCALIZATION FILE HAVE ONLY " .. #Messages .. " ELEMENTS" end
	if Messages[index] == nil then 
		print("{FF0000}----------------------------")
		print("Debug localization messages:")
		for i = 0, #Messages do
			print("Messages[", i, "] - ", Messages[i])
		end
		print("{FF0000}----------------------------")
		return encoding.UTF8("ERR: NO LOCALIZATION MESSAGE FOUND AT INDEX: ") .. index

	end
	return Messages[index]
end

function GetLocalizationFiles()
	local filenames = {}
	local searchHandle, file = findFirstFile(string.format("%s\\resource\\avionics\\localization\\*.txt", getWorkingDirectory()));
	table.insert(filenames, file)
	while file do file = findNextFile(searchHandle) table.insert(filenames, file) end
    return filenames
end


function InitLandingData()
	landing_data = {Airport = "ERR0", Approach={x = 0, y = 0, z = 500}, Glidepath = {x = 0, y = 0, z = 0}, BPRM = {x = 0, y = 0, z = 0}, Runway = {x = 0, y = 0, z = 0}}
	LoadLSIA_CMD()
end

function InitGUI()
	
end

function InitPrevs()
	PrevX = 0
	PrevY = 0
	PrevZ = 0
	PrevHdng = 0
	deltaZ = 0
	IterTimer = 0
	PrevSpd = 0
	deltaSpd = 0
	AudioMax = 7
	AudioTimer = STime
end

function InitTarget()
	vehTarget = -1
	radarSize = 300
end

function OnUpdateF()
	while true do
		wait(0)
		if Iteration < 1 and not sampIsDialogActive() and not sampIsScoreboardOpen() then
			if (isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED)) and not (IsTabPressed) then
				local vehID = storeCarCharIsInNoSave(PLAYER_PED)
				local NTime = os.clock()
				
				UpdateGUI()
				onUpdateGlobals(vehID, NTime)
				
				if IsPlaneRendered then
					onUpdatePlaneRendered(vehID)
				else
					onUpdateFirstRender(vehID)
				end
			else
				Iteration = 100
				onUpdateUnrender()
			end
		else
			Iteration = Iteration - 1
		end
	end
end

function onUpdateGlobals(vehID, NTime)
	if (NTime - STime) > 0.1 then
		if IterTimer > 5 then 
			IterTimer = 0 
			PrevSpd = getCarSpeed(vehID)*2
		else
			IterTimer = IterTimer + 1
		end
		local h, m = getTimeOfDay()
		
		if h > 20 and IsAutoMode and not settings.maincfg.IsNightMode then
			settings.maincfg.IsNightMode = true
		end
		
		STime = NTime
		local vdX, vdY, vdZ = getCarCoordinates(vehID)
		deltaZ = (vdZ - PrevZ)*10
		PrevX = vdX
		PrevY = vdY
		PrevZ = vdZ
	end
end

function onUpdatePlaneRendered(vehID)
	AvionicsModeBindings(vehID)
	AvionicsOtherBindings(vehID)
	if IsAvionicsActive then 
		UpdatePlaneDamage(vehID)
		UpdatePlaneGUI(vehID)
		if Lang_Eng then
			RenderPlaneGUI()
			UpdatePlaneRText(vehID)
		else
			UpdatePlaneRTextRU(vehID)
		end
		CheckChatPPMUpdates()
		CheckTargets(vehID)
		UpdateTimers()
		if IsCameraMode then
			Cam_UpdateCamera(vehID)
		end
		if IsAutoPilot then
			UpdateAP(vehID)
		end
		WPT_Ctrls()
		SPOCheck(vehID)
		UpdateStatusModed(vehID)
		UpdateRadio()
		OnRenderLRFTargetPlayer()
	end
end

function onUpdateFirstRender(vehID)
	if settings.maincfg.IsShowMessage then
		sampAddChatMessage(GetLocalizationMessage(1), 0xFFFFFFFF)--{00A2FF}V{FFFFFF}ir{00A2FF}P{FFFFFF}i{00A2FF}L {FFFFFF}Avionics. Чтобы открыть меню ИЛС введите {00A2FF}/swavionics
	end
	IsPlaneRendered = true
	if settings.maincfg.IsBETTYDefault then
		Lang_Eng = Lang_IsCarEng(vehID)
	else
		Lang_Eng = not(Lang_IsCarEng(vehID))
	end
	LoadTextFont()
	LoadAudioStreams()
	OnLoadPlaneGUI()
	PlayPlaneAvionicsStart(vehID)
	if Lang_Eng then
		RenderPlaneGUI()
	end
end

function onUpdateUnrender()
	if IsPlaneRendered then
		if MainWindow.v then MainMenu_CMD() end
		UnRenderPlaneGUI()
		UnLoadAudioStreams()
		UnloadTextFont()
		IsPlaneRendered = false
	end
end

-----------------------------------------------------#region GUI
function UpdateGUI()
end

function imgui.OnDrawFrame()
	GUI_DrawMainMenu()
end

function GUI_DrawMainMenu()
	local sX, sY = getScreenResolution()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	
	colors[clr.TitleBg] = ImVec4(0.00, 0.34, 0.65, 0.6)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.34, 0.65, 0.6)
	colors[clr.TitleBgActive] = ImVec4(0.00, 0.24, 0.6, 0.6)
	colors[clr.WindowBg] = ImVec4(0.11, 0.10, 0.11, 0.6)
	colors[clr.Header] = ImVec4(0.00, 0.64, 1.0, 0.4)
	colors[clr.HeaderHovered] = ImVec4(0.00, 0.64, 1.0, 0.4)
	colors[clr.HeaderActive] = ImVec4(0.00, 0.64, 1.0, 0.6)
	
	local cb_render_in_menu = imgui.ImBool(imgui.RenderInMenu)
	local cb_show_cursor = imgui.ImBool(imgui.ShowCursor)
	local WinStr = string.format("VirPiL Avionics by d7.KrEoL - Main Menu.                     ver. %s", Ver)
	local strCur
	local GUI_ZoomSpd = imgui.ImInt(settings.maincfg.ZoomFix)

	imgui.SetNextWindowPos(imgui.ImVec2(CentralPosX-(sX*0.28), CentralPosY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(455, 720), imgui.Cond.FirstUseEver)
	imgui.Begin(WinStr, show_main_window, imgui.WindowFlags.NoResize)
	
	if imgui.ListBox(encoding.UTF8(GetLocalizationMessage(2)), SelectedLanguage, Languages, 2) then --Выберите язык
		settings.maincfg.Localization = Languages[SelectedLanguage.v + 1]
		inicfg.save(settings, "avionics")
		ReloadLocalization()
	end
	
	
	
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-35)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(3)))---Системы-
	strCur = encoding.UTF8(string.format(encoding.UTF8(GetLocalizationMessage(4)), GUI_Func_CheckBoolStr(settings.maincfg.IsHUDEnabled)))--HUD: %s
	if imgui.Button(strCur, imgui.ImVec2(100, 0)) then
		settings.maincfg.IsHUDEnabled = not settings.maincfg.IsHUDEnabled
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(5), GUI_Func_CheckRadarStr(settings.maincfg.AvionicsMode)))--Режим: %s
	imgui.SameLine() if imgui.Button(strCur, imgui.ImVec2(100, 0)) then
		if settings.maincfg.AvionicsMode > 2 then
			settings.maincfg.AvionicsMode = 0
		elseif settings.maincfg.AvionicsMode == 0 then
			settings.maincfg.AvionicsMode = 1
		elseif settings.maincfg.AvionicsMode == 1 then
			settings.maincfg.AvionicsMode = 2
		elseif settings.maincfg.AvionicsMode == 2 then
			settings.maincfg.AvionicsMode = 3
		elseif settings.maincfg.AvionicsMode == 3 then
			settings.maincfg.AvionicsMode = 1
		end
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(6), GUI_Func_CheckBoolStr(settings.maincfg.IsRadioEnabled)))--Радио: %s
	imgui.SameLine() if imgui.Button(strCur, imgui.ImVec2(100, 0)) then
		settings.maincfg.IsRadioEnabled = not settings.maincfg.IsRadioEnabled
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(7), GUI_Func_CheckBoolStr(settings.maincfg.IsRadioFullyOff)))--Радио 2: %s
	imgui.SameLine() if imgui.Button(strCur, imgui.ImVec2(100, 0)) then
		settings.maincfg.IsRadioFullyOff = not settings.maincfg.IsRadioFullyOff
		local memory = require 'memory'
		local value = memory.read(0x4EB9A0, 3, true)
		local memory = require 'memory'
		if settings.maincfg.IsRadioFullyOff then 
			setRadioChannel(12)
			memory.copy(0x4EB9A0, memory.strptr('\x55\x8B\xE9'), 3, true) 
		else 
			setRadioChannel(12)
			memory.copy(0x4EB9A0, memory.strptr('\xC2\x04\x00'), 3, true)
		end
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(8), GUI_Func_CheckBoolStr(settings.maincfg.IsAutoLeave)))--Автопокидание: %s
	if imgui.Button(strCur, imgui.ImVec2(150, 0)) then
		settings.maincfg.IsAutoLeave = not settings.maincfg.IsAutoLeave
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(9), GUI_Func_CheckBoolStr(settings.maincfg.IsSpoEnabled)))--СПО: %s
	imgui.SameLine() if imgui.Button(strCur, imgui.ImVec2(100, 0)) then
		settings.maincfg.IsSpoEnabled = not settings.maincfg.IsSpoEnabled
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(10), GUI_Func_CheckBoolStr(settings.maincfg.IsTargetInputActive)))--Приём целеуказ.: %s
	imgui.SameLine() if imgui.Button(strCur, imgui.ImVec2(157, 0)) then
		SwitchTargetInput()
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(11), GUI_Func_CheckBoolStr(settings.maincfg.IsAutoFlares)))--Авто-ЛТЦ: %s
	if imgui.Button(strCur, imgui.ImVec2(100, 0)) then
		settings.maincfg.IsAutoFlares = not settings.maincfg.IsAutoFlares
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(12), GUI_Func_CheckBoolStr(IsAvionicsActive)))--Отображение HUD: %s
	imgui.SameLine() 
	if imgui.Button(strCur, imgui.ImVec2(170, 0)) then
		IsAvionicsActive = not IsAvionicsActive
	end
		
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(13), GUI_Func_CheckBoolStr(settings.maincfg.IsShowMessage)))--Инф. сообщ.: %s
	imgui.SameLine() 
	if imgui.Button(strCur, imgui.ImVec2(140, 0)) then
		settings.maincfg.IsShowMessage = not settings.maincfg.IsShowMessage
		inicfg.save(settings, "avionics")
	end
	
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(137), GUI_Func_CheckBoolStr(settings.maincfg.IsShowInfantry)))--Инф. сообщ.: %s
	if imgui.Button(strCur, imgui.ImVec2(170, 0)) then
		settings.maincfg.IsShowInfantry = not settings.maincfg.IsShowInfantry
		inicfg.save(settings, "avionics")
	end
	
	imgui.NewLine()
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-90)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(14)))---Баллистические вычислители-
	imgui.NewLine()
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(15), GUI_Func_CheckBoolStr(settings.maincfg.IsBallisticBombRender)))--ЗМЛ-Бомба: %s
	if imgui.Button(strCur, imgui.ImVec2(70, 0)) then
		settings.maincfg.IsBallisticBombRender = not settings.maincfg.IsBallisticBombRender
		inicfg.save(settings, "avionics")
	end
	imgui.SameLine()
	strCur = encoding.UTF8(string.format(GetLocalizationMessage(16), GUI_Func_CheckBoolStr(settings.maincfg.IsBallisticGunRender)))--ЗМЛ-Пушка: %s
	if imgui.Button(strCur, imgui.ImVec2(70, 0)) then
		settings.maincfg.IsBallisticGunRender = not settings.maincfg.IsBallisticGunRender
		inicfg.save(settings, "avionics")
	end
	imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.65,0.0,0.0,0.5)
	imgui.Text(string.format(encoding.UTF8(GetLocalizationMessage(17)), Lang_Eng and encoding.UTF8(GetLocalizationMessage(18)) or encoding.UTF8(GetLocalizationMessage(19))))--Баллистика бомб %s ; (тип NATO) ; (тип RU)
	imgui.PushItemWidth(150)
	imgui.InputFloat(encoding.UTF8(GetLocalizationMessage(20)), GUI_KeyInput_BombBallistic) --(коэф.)
	imgui.PopItemWidth()
	if imgui.Button(encoding.UTF8(GetLocalizationMessage(21)), imgui.ImVec2(200, 0)) then --Применить (задать коэф.)
		if Lang_Eng then
			settings.maincfg.BombBallisticEN = tonumber(GUI_KeyInput_BombBallistic.v)
		else
			settings.maincfg.BombBallisticRU = tonumber(GUI_KeyInput_BombBallistic.v)
		end
		inicfg.save(settings, "avionics")
	end
	imgui.SameLine()
	if imgui.Button(encoding.UTF8(GetLocalizationMessage(22)), imgui.ImVec2(200, 0)) then --Сбросить
		if Lang_Eng then
			settings.maincfg.BombBallisticEN = 1.210
			GUI_KeyInput_BombBallistic.v = settings.maincfg.BombBallisticEN
		else
			settings.maincfg.BombBallisticRU = 1.395
			GUI_KeyInput_BombBallistic.v = settings.maincfg.BombBallisticRU
		end
		inicfg.save(settings, "avionics")
	end
	
	imgui.NewLine()
	imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.65,0.0,0.0,0.5)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(23))) --Задатчик опасной высоты
	imgui.InputInt(encoding.UTF8(GetLocalizationMessage(24)), GUI_KeyInput_DangerAlt)  --(м), радиовысотомер
	if imgui.Button(encoding.UTF8(GetLocalizationMessage(25)), imgui.ImVec2(200, 0)) then --Применить (задать высоту)
		
		settings.maincfg.DangerAlt = tonumber(GUI_KeyInput_DangerAlt.v)
		inicfg.save(settings, "avionics")
	end
	
	imgui.NewLine()
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-40)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(26))) ---Настройки-
	imgui.Text(encoding.UTF8(GetLocalizationMessage(27))) --!Низкие значения могут привести к уходу в Loading!
	if imgui.SliderInt(encoding.UTF8(GetLocalizationMessage(28)), GUI_ZoomSpd, 10, 1000) then --Скорость приближения
		settings.maincfg.ZoomFix = GUI_ZoomSpd.v
	end
	imgui.NewLine()
	
	if imgui.CollapsingHeader(encoding.UTF8(GetLocalizationMessage(29))) then --Клавиши управления
		local ffi = require('ffi')
		imgui.NewLine()
		imgui.Text(encoding.UTF8(GetLocalizationMessage(30) .. '\n' .. GetLocalizationMessage(31))) --Назначить клавишу управления можно нажав по кнопке напротив ; настройки, затем нажав на нужную клавишу на клавиатуре
		imgui.NewLine()
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
		
		curStr = string.format(encoding.UTF8(GetLocalizationMessage(32)), keys.id_to_name(settings.maincfg.PrevWPTKey)) --Текущая клавиша: %s
		imgui.Text(curStr)
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetWindowWidth()/2)
		if imgui.Button(encoding.UTF8(GetLocalizationMessage(33)), imgui.ImVec2(180, 0)) then --Переназначить (пред. ППМ)
			lua_thread.create(function()
				settings.maincfg.PrevWPTKey = tonumber(ProcessClientInput())
				sampAddChatMessage(string.format(GetLocalizationMessage(34), settings.maincfg.PrevWPTKey, keys.id_to_name(settings.maincfg.PrevWPTKey)), -1) --[Avionics]: клавиша теперь назначена на: %i (%s)
				inicfg.save(settings, "avionics")
				end)
		end
		
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
		curStr = string.format(encoding.UTF8(GetLocalizationMessage(32)), keys.id_to_name(settings.maincfg.NextWPTKey)) --Текущая клавиша: %s
		imgui.Text(curStr)
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetWindowWidth()/2)
		if imgui.Button(encoding.UTF8(GetLocalizationMessage(35)), imgui.ImVec2(180, 0)) then --Переназначить (след. ППМ)
			lua_thread.create(function()
				settings.maincfg.NextWPTKey = tonumber(ProcessClientInput())
				sampAddChatMessage(string.format(GetLocalizationMessage(34), settings.maincfg.NextWPTKey, keys.id_to_name(settings.maincfg.NextWPTKey)), -1) --[Avionics]: клавиша теперь назначена на: %i (%s)
				inicfg.save(settings, "avionics")
				end)
		end
		
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
		curStr = string.format(encoding.UTF8(GetLocalizationMessage(32)), keys.id_to_name(settings.maincfg.PrevModeKey)) --Текущая клавиша: %s
		imgui.Text(curStr)
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetWindowWidth()/2)
		if imgui.Button(encoding.UTF8(GetLocalizationMessage(36)), imgui.ImVec2(180, 0)) then --Переназначить (пред. реж.)
			lua_thread.create(function()
				settings.maincfg.PrevModeKey = tonumber(ProcessClientInput())
				sampAddChatMessage(string.format(GetLocalizationMessage(34), settings.maincfg.PrevModeKey, keys.id_to_name(settings.maincfg.PrevModeKey)), -1) --[Avionics]: клавиша теперь назначена на: %i (%s)
				inicfg.save(settings, "avionics")
				end)
		end
		
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
		curStr = string.format(encoding.UTF8(GetLocalizationMessage(32)), keys.id_to_name(settings.maincfg.NextModeKey)) --Текущая клавиша: %s
		imgui.Text(curStr)
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetWindowWidth()/2)
		if imgui.Button(encoding.UTF8(GetLocalizationMessage(37)), imgui.ImVec2(180, 0)) then --Переназначить (след. реж.)
			lua_thread.create(function()
				settings.maincfg.NextModeKey = tonumber(ProcessClientInput())
				sampAddChatMessage(string.format(GetLocalizationMessage(34), settings.maincfg.NextModeKey, keys.id_to_name(settings.maincfg.NextModeKey)), -1) --[Avionics]: клавиша теперь назначена на: %i (%s)
				inicfg.save(settings, "avionics")
				end)
		end
		
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
		curStr = string.format(encoding.UTF8(GetLocalizationMessage(32)), keys.id_to_name(settings.maincfg.DropLockKey)) --Текущая клавиша: %s
		imgui.Text(curStr)
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetWindowWidth()/2)
		if imgui.Button(encoding.UTF8(GetLocalizationMessage(38)), imgui.ImVec2(180, 0)) then --Переназначить (сброс захв.)
			lua_thread.create(function()
				settings.maincfg.DropLockKey = tonumber(ProcessClientInput())
				sampAddChatMessage(string.format(GetLocalizationMessage(34), settings.maincfg.DropLockKey, keys.id_to_name(settings.maincfg.DropLockKey)), -1) --[Avionics]: клавиша теперь назначена на: %i (%s)
				inicfg.save(settings, "avionics")
				end)
		end
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
		curStr = string.format(encoding.UTF8(GetLocalizationMessage(32)), keys.id_to_name(settings.maincfg.OpenMenuKey)) --Текущая клавиша: %s
		imgui.Text(curStr)
		imgui.SameLine()
		imgui.SetCursorPosX(imgui.GetWindowWidth()/2)
		if imgui.Button(encoding.UTF8(GetLocalizationMessage(39)), imgui.ImVec2(180, 0)) then --Переназначить (меню)
			lua_thread.create(function()
				settings.maincfg.OpenMenuKey = tonumber(ProcessClientInput())
				sampAddChatMessage(string.format(GetLocalizationMessage(34), settings.maincfg.PrevWPTKey, keys.id_to_name(settings.maincfg.PrevWPTKey)), -1) --[Avionics]: клавиша теперь назначена на: %i (%s)
				inicfg.save(settings, "avionics")
				end)
		end
		imgui.Text(encoding.UTF8"--------------------------------------------------------------------------------------")
	end
	
	---------------------------------------------------
	if imgui.CollapsingHeader(encoding.UTF8(GetLocalizationMessage(40))) then --Настройки окна меню
		if imgui.Checkbox(encoding.UTF8(GetLocalizationMessage(41)), cb_render_in_menu) then --Не скрывать в меню паузы
			imgui.RenderInMenu = cb_render_in_menu.v
		end
	end
	
	
	
	------------------------------------------Футер
	imgui.NewLine()
	if settings.maincfg.IsNightMode then 
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,1.0,0.5)
		strCur = encoding.UTF8(GetLocalizationMessage(42)) --Цвет: ночь
	else
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,1.0,0.7)
		strCur = encoding.UTF8(GetLocalizationMessage(43)) --Цвет: день
	end
	if imgui.Button(strCur, imgui.ImVec2(200, 0)) then
		settings.maincfg.IsNightMode = not settings.maincfg.IsNightMode
		if settings.maincfg.IsNightMode then
			RenderColor = 0xFF008800
		else
			RenderColor = 0xFF00FF00
		end
		inicfg.save(settings, "avionics")
		UpdateTDColor()
	end
	if Lang_Eng then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,1.0,0.7)
		strCur = encoding.UTF8(GetLocalizationMessage(44)) --Речевой информатор: BETTY
		
	else
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,1.0,0.5)
		strCur = encoding.UTF8(GetLocalizationMessage(45)) --Речевой информатор: РИТА
	end
	imgui.SameLine() if imgui.Button(strCur, imgui.ImVec2(200, 0)) then
		Lang_Eng = not Lang_Eng
		GUI_KeyInput_BombBallistic.v = Lang_Eng and settings.maincfg.BombBallisticEN or settings.maincfg.BombBallisticRU
		Lang_Update()
	end
	
	if settings.maincfg.IsBETTYDefault then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,1.0,0.7)
		strCur = encoding.UTF8(GetLocalizationMessage(46)) --РИ по умолчанию: BETTY
	else
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,1.0,0.5)
		strCur = encoding.UTF8(GetLocalizationMessage(47)) --РИ по умолчанию: РИТА
	end
	imgui.SetCursorPosX(imgui.GetWindowWidth()/2-11)
	if imgui.Button(strCur, imgui.ImVec2(200, 0)) then
		settings.maincfg.IsBETTYDefault = not settings.maincfg.IsBETTYDefault
		inicfg.save(settings, "avionics")
	end
	
	
	imgui.NewLine()
	if imgui.CollapsingHeader(encoding.UTF8(GetLocalizationMessage(48))) then --Список текстовых команд скрипта
	imgui.Text(encoding.UTF8(GetLocalizationMessage(49))) --Данные команды вводятся в общий чат, как обычные команды сервера:
	imgui.Text(encoding.UTF8(GetLocalizationMessage(50))) --/setppm /setwpt - установить текущий ППМ
	imgui.Text(encoding.UTF8(GetLocalizationMessage(51))) --/swavionics /swav /avionix - Открыть/закрыть данное меню
	imgui.Text(encoding.UTF8(GetLocalizationMessage(52))) --/swcam - Перейти в контейнер целеуказания/выйти из него
	imgui.Text(encoding.UTF8(GetLocalizationMessage(53))) --/swmag - (Для вертолётов) выпустить/сбросить магнит
	imgui.Text(encoding.UTF8(GetLocalizationMessage(54))) --/addwpt /addppm - Добавить ППМ по координатам
	imgui.Text(encoding.UTF8(GetLocalizationMessage(55))) --/clearppm /clearwpt - Очистить план полёта (удалить все ППМ)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(56))) --/autopilot /swapt - Включить автопилот
	imgui.Text(encoding.UTF8(GetLocalizationMessage(57))) --/swapto - Отключить автопилот
	imgui.Text(encoding.UTF8(GetLocalizationMessage(58))) --/wptcam /ppmcam /tarcam - Повернуть камеру контейнера целеуказания на ППМ
	imgui.Text(encoding.UTF8(GetLocalizationMessage(59))) --/tarppm /tarwpt - Добавить ППМ из координат цели \n(фиксированной камеры)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(60))) --/vehppm /vehwpt - Добавить ППМ из текущих координат самолёта \n(собственных)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(61))) --/swamode /swam - Переключение режима авионики
	imgui.Text(encoding.UTF8(GetLocalizationMessage(62))) --/swazoom /swaz - Изменить скорость приближения камеры
	imgui.Text(encoding.UTF8(string.format("%s\n%s", GetLocalizationMessage(63), GetLocalizationMessage(65)))) --/safp /ldfp - Загрузить план полёта из файла (ложить в папку\nresource/avionics/flightplan)
	imgui.Text(encoding.UTF8(string.format("%s\n%s", GetLocalizationMessage(64), GetLocalizationMessage(66)))) --/savefp /svfp - Сохранить план полёта в файл (будет лежать в папке\nresource/avionics/flightplan)
	imgui.Text(encoding.UTF8(GetLocalizationMessage(67))) --/raceppm /markppm
	imgui.Text(encoding.UTF8(GetLocalizationMessage(68))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	imgui.Text(encoding.UTF8(GetLocalizationMessage(69))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	imgui.Text(encoding.UTF8(GetLocalizationMessage(70))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	imgui.Text(encoding.UTF8(GetLocalizationMessage(71))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	imgui.Text(encoding.UTF8(GetLocalizationMessage(72))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	imgui.Text(encoding.UTF8(GetLocalizationMessage(73))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	imgui.Text(encoding.UTF8(GetLocalizationMessage(74))) --%RESERVED FOR "LONG WORD" LANGUAGES%
	end
  
	imgui.NewLine()
	if imgui.Button("GitHub", imgui.ImVec2(50, 0)) then
		os.execute("start https://github.com/d7KrEoL/avionics")
	end
	imgui.SameLine() if imgui.Button("Discord", imgui.ImVec2(50, 0)) then
		os.execute("start https://discord.gg/QSKkNhZrTh")
	end
	imgui.SameLine() if imgui.Button("VK", imgui.ImVec2(50, 0)) then
		os.execute("start https://vk.com/d7kreol")
	end
	imgui.End()
end

function GUI_Func_CheckBoolStr(boolName)
	if boolName then 
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,0.0,0.5)
		return GetLocalizationMessage(75) --Вкл
	else 
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.65,0.0,0.0,0.5)
		return GetLocalizationMessage(76) --Откл
	end
end

function GUI_Func_CheckRadarStr(radarMode)
	if radarMode == 0 then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.64,0.0,0.0,0.5)
		return GetLocalizationMessage(77) --НАВ
	elseif radarMode == 1 then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,0.0,0.5)
		return GetLocalizationMessage(78) --БВБ
	elseif radarMode == 2 then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,0.0,0.5)
		return GetLocalizationMessage(79) --ЗМЛ
	elseif radarMode == 3 then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,0.0,0.5)
		return GetLocalizationMessage(80) --ДВБ
	elseif radarMode == 4 then
		imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.0,0.64,0.0,0.5)
		return GetLocalizationMessage(81) --ПОС
	end
end

function GUI_Style_MainMenu()
	imgui.SwitchContext()
end

function ProcessClientInput()
	sampAddChatMessage(GetLocalizationMessage(82), -1) --[Avionics]: Нажмите на нужную клавишу
	local NotPressed = true
	local j = 0
	while NotPressed do
		for i = 1, 255 do
			print(keys.id_to_name(i), j)
			if isKeyDown(i) then
				NotPressed = false
				return i
			end
		end
		j = j + 1
		wait(0)
	end
end

-----------------------------------------------------------------------------------

----------------------------------------------------------------------------------#region CMD
function SetPPM_CMD(arg)
	if arg == nil then
		sampAddChatMessage(GetLocalizationMessage(83), 0xFFFFFFFF)
		return
	end
	if #arg < 1 then
			print(GetLocalizationMessage(83)) --Синтаксис: /setppm [number]
	else
		print(arg, arg[1])
		local numberValue = tonumber(arg[1])
		if (numberValue < 1) then
			PPMCur = -1
			sampAddChatMessage(GetLocalizationMessage(84), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Отображение ППМ отключено {00A2FF}(/setppm 0)
		else
			
			if (numberValue == nil) then 
				sampAddChatMessage(GetLocalizationMessage(83), 0xFFFFFFFF) 
				return
			end
			if ((#PPMX > numberValue) or (#PPMX == numberValue)) and ((#PPMY > numberValue) or (#PPMY == numberValue)) then
				sampAddChatMessage(string.format(GetLocalizationMessage(85), numberValue, PPMX[numberValue], PPMY[numberValue]), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Установлен ППМ №{00A2FF}%s {FFFFFF}[%s, %s] 
					PPMCur = numberValue
			else
				sampAddChatMessage(string.format(GetLocalizationMessage(86), numberValue), 0xFFFFFFFF) --{00A2FF}[Avionics]: Ошибка. {FFFFFF}ППМ №%s не добавлен в бортовую систему
			end
		end
	end
end

function AvionicsMode_CMD(arg)
	if arg == nil then
		sampAddChatMessage(string.format(GetLocalizationMessage(116), settings.maincfg.AvionicsMode), 0xFFFFFFFF)
		return
	end
	if #arg < 1 then
			print(GetLocalizationMessage(87)) --Синтаксис: /swamode [number] (0 - НАВ, 1 - БВБ, 2 - ЗМЛ, 3 - ДВБ, 4 - ПОС)
			sampAddChatMessage(string.format(GetLocalizationMessage(88), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Синтаксис: /swamode [номер] (0 - Нав, 1 - БВБ, 2 - ЗМЛ, 3 - ДВБ)
	else
		if tonumber(arg) < 5 then
			print(arg)
			settings.maincfg.AvionicsMode = tonumber(arg)
			if settings.maincfg.AvionicsMode == 0 then
				sampAddChatMessage(string.format(GetLocalizationMessage(89), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Включен режим навигации
			elseif settings.maincfg.AvionicsMode == 1 then
				sampAddChatMessage(string.format(GetLocalizationMessage(90), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Включен режим ближнего воздушного боя
			elseif settings.maincfg.AvionicsMode == 2 then
				sampAddChatMessage(string.format(GetLocalizationMessage(91), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Включен режим воздух-поверхность
			elseif settings.maincfg.AvionicsMode == 3 then
				sampAddChatMessage(string.format(GetLocalizationMessage(92), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Включен режим дальнего воздушного боя
			elseif settings.maincfg.AvionicsMode == 4 then
				sampAddChatMessage(string.format(GetLocalizationMessage(93), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Включен режим посадки
			elseif settings.maincfg.AvionicsMode < 0 then
				sampAddChatMessage(string.format(GetLocalizationMessage(94), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Режим с номером '%s' не найден. Включен режим навигации
				settings.maincfg.AvionicsMode = 0
			end
			inicfg.save(settings, "avionics")
		else
			print(GetLocalizationMessage(95)) --{00A2FF}[Avionics]: {FFFFFF}/swamode не может быть больше 4
			sampAddChatMessage(string.format(GetLocalizationMessage(95), arg), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}/swamode не может быть больше 4
		end
	end
end

function SetZoomFix_CMD(arg)
	if #arg < 1 then
			print(GetLocalizationMessage(96)) --Синтаксис: /swaz [value]
	else
		print(arg[1])
		if (arg[1]) == nil then print("Zoom is null") return end
		settings.maincfg.ZoomFix = tonumber(arg[1])
		sampAddChatMessage(string.format(GetLocalizationMessage(97), arg[1]), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Скорость приближения камеры установлена на %s
		inicfg.save(settings, "avionics")
	end
end

function AddPPM_CMD(arg)
	if #arg < 2 then
		print(GetLocalizationMessage(98), " [", arg[1], arg[2], arg[3], "])") --Синтаксис: /addppm [X] [Y] *[Z] (now:
	else
		local args = {}
		table.insert(PPMX, tonumber(arg[1]))
		table.insert(PPMY, tonumber(arg[2]))
		if arg[3] == nil then 
			table.insert(PPMZ, 0)
		elseif tonumber(arg[3]) > 800 then
			table.insert(PPMZ, 800)
		else
			table.insert(PPMZ, tonumber(arg[3]))
		end
		PPMCur = #PPMX
		sampAddChatMessage(string.format(GetLocalizationMessage(99), PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur], PPMCur), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}%.2f %.2f %.2f - ППМ %i
	end
end

function AddNextPPM_CMD(arg)
	sampAddChatMessage(GetLocalizationMessage(100), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Полноценно редактировать планы полёта можно с Avionics Editor, или на сайте http://sampmap.ru/samap
end

function DelPPM_CMD(arg)
	sampAddChatMessage(GetLocalizationMessage(100), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Полноценно редактировать планы полёта можно с Avionics Editor, или на сайте http://sampmap.ru/samap
end

function ClrPPM_CMD()
	for i in ipairs(PPMX) do
		PPMX[i] = nil
		PPMY[i] = nil
		PPMZ[i] = nil
	end
	PPMCur = -1
	sampAddChatMessage(GetLocalizationMessage(101), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Координаты всех ППМ очищены.
end

function CamToPPM_CMD()
	if IsCameraMode then
		if PPMCur > 0 then
			Cam_TarX = PPMX[PPMCur]
			Cam_TarY = PPMY[PPMCur]
			Cam_TarZ = PPMZ[PPMCur]
			sampAddChatMessage(string.format(GetLocalizationMessage(102), PPMCur, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur]), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Камера установлена в координаты ППМ %i (%.2f; %.2f; %.2f).
		else
			sampAddChatMessage(GetLocalizationMessage(103), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Невозможно направить камеру. ППМ Не задан.
		end
	else
		sampAddChatMessage(GetLocalizationMessage(104), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Вы находитесь в режиме пилотирования. Чтобы перейти в режим камеры введите {00A2FF}/swcam
	end
end

function TargetToPPM_CMD()
	if IsCameraMode then
		if not (Cam_TarX == -999 and Cam_TarY == -999 and Cam_TarZ == -999) then
			print(Cam_TarX, Cam_TarY, Cam_TarZ)
			AddPPM_CMD({Cam_TarX, Cam_TarY, Cam_TarZ})--string.format("%.2f %.2f %.2f", Cam_TarX, Cam_TarY, Cam_TarZ))
		else
			sampAddChatMessage(GetLocalizationMessage(105), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Камера находится в Unfixed mode. Перейдите в Fixed mode {00A2FF}нажав ЛКМ
		end
	else
		sampAddChatMessage(GetLocalizationMessage(106), 0xFFFFFFFF) --{00A2FF}[Avionics]: {FFFFFF}Добавить ППМ возможно только в режиме камеры. {00A2FF}/swcam
	end
end

function MarkerToPPM_CMD()
	local result, x, y, z = getTargetBlipCoordinates()
	if not result then return end
	AddPPM_CMD({x, y, z})
end

function SAMarkerToPPM_CMD()
	local posX, posY, posZ = getCharCoordinates(playerPed)
	local res, x, y, z = SearchMarker(0, 0, 0, 4000.0, false)
	if res then
		AddPPM_CMD({x, y, z})
	else
		res, x, y, z = SearchMarker(0, 0, 0, 4000.0, false)
		if res then 
			AddPPM_CMD({x, y, z}) 
		else
			print(GetLocalizationMessage(107))--No samp markers (single/race) found
		end
	end
end

function RaceToPPM_CMD()
	local posX, posY, posZ = getCharCoordinates(playerPed)
	local res, x, y, z = SearchMarker(0, 0, 0, 4000.0, true)
	if res then
		AddPPM_CMD({x, y, z})
	else
		print(GetLocalizationMessage(108))--No samp race markers found
	end
end

function PlayerIdToPPM_CMD(arg)
	if #arg < 1 then return end
	if arg[1] == nil  then return end
	ClearLRFTargetPlayer()
	local id = tonumber(arg[1])
	if id == nil then return end
	if not sampIsPlayerConnected(id) then 
		print("Player not connected: ", id)
		return
	end
	print("Player added as target: ", MarkId)
	SetTargetPlayerId(id)
end

function VehicleToPPM_CMD()
	if (isCharInAnyPlane(PLAYER_PED) or isCharInAnyHeli(PLAYER_PED)) then
		local vehID = storeCarCharIsInNoSave(PLAYER_PED)
		local PX, PY, PZ = getCarCoordinates(vehID)
		AddPPM_CMD({PX, PY, PZ})--string.format("%.2f %.2f %.2f", PX, PY, PZ))
		sampAddChatMessage(string.format(GetLocalizationMessage(109), PX, PY, PZ), 0xFFFFFFFF)--{00A2FF}[Avionics]: {FFFFFF}ППМ добавлен из текущих координат: [%.2f;%.2f;%.2f]
	else
		sampAddChatMessage(GetLocalizationMessage(110), 0xFFFFFFFF)--{00A2FF}[Avionics]: {FFFFFF}Невозможно добавить ППМ. Вы не находитесь в транспорте.
	end
end

function AutoPilot_CMD()
	if PPMCur == -1 then
		sampAddChatMessage(GetLocalizationMessage(111), 0xFFFFFFFF)
		AutoPilotOff_CMD()
	elseif settings.maincfg.AvionicsMode == 0 then
		sampAddChatMessage(string.format(GetLocalizationMessage(112), PPMCur), 0xFFFFFFFF)--{00A2FF}[Avionics]: {FFFFFF}Автопилот отключен (ППМ не задан)
		local vid = storeCarCharIsInNoSave(PLAYER_PED)
		if isCharInAnyPlane(PLAYER_PED) then
			planeGotoCoords(vid, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur], 50, 100)
		elseif isCharInAnyHeli(PLAYER_PED) then
			 heliGotoCoords(vid, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur], 30, 100)
		end
		IsAutoPilot = true
	end
end

function AutoPilotOff_CMD()
	if IsAutoPilot then
		sampAddChatMessage(GetLocalizationMessage(113), 0xFFFFFFFF)--{00A2FF}[Avionics]: {FFFFFF}Автопилот включен. ППМ: %i
		if getAudioStreamState(audio_autopilotoff) == -1 then
			setAudioStreamState(audio_autopilotoff, as_action.PLAY)
		end
		clearCharTasks(PLAYER_PED)
		taskWarpCharIntoCarAsDriver(PLAYER_PED, storeCarCharIsInNoSave(PLAYER_PED))
		IsAutoPilot = false
	else
		sampAddChatMessage(string.format("%s", GetLocalizationMessage(114)), 0xFFFFFFFF)--{00A2FF}[Avionics]: {FFFFFF}Автопилот отключен (Управляй вручную)
	end
end

function ResPPM_CMD(arg)
	
end

-------------------------------------------------------------------------------------------#region PPM

function CheckIfTabPressed()
	if isKeyJustPressed(VK_TAB) and not(sampIsChatInputActive()) then 
		if IsTabPressed then IsTabPressed = false
		else IsTabPressed = true end		
		--print(IsTabPressed)
	end
end

function CheckChatPPMUpdates()
	if not(settings.maincfg.IsTargetInputActive) then return end
	text, prefix, color, pcolor = sampGetChatString(99)
	if string.find(text, GetLocalizationMessage(115)) then--{00A2FF}[Avionics]: {FFFFFF}Автопилот уже отключен. Дополнительных действий не требуется.
		local args={}
		local minindex
		for str in string.gmatch(text, "([^".." ".."]+)") do
			table.insert(args, str)
		end
		if args == nil then 
			print(GetLocalizationMessage(117)) return
		elseif #args < 2 then
			print(GetLocalizationMessage(118), #args) return
		else
			minindex = tonumber(keyOf(args, GetLocalizationMessage(119)))
			if minindex == nil then print(GetLocalizationMessage(120), table.concat(args)) return end
			print(GetLocalizationMessage(121), args[minindex+1], GetLocalizationMessage(122), args[minindex+2])
			sampAddChatMessage(string.format(GetLocalizationMessage(123), args[minindex+1], args[minindex+2]), 0xFFFFFFFF)
			table.insert(PPMX, tonumber(args[minindex+1]))
			table.insert(PPMY, tonumber(args[minindex+2]))
			table.insert(PPMZ, 0)
			PPMCur = #PPMX
		end
	elseif string.find(text, GetLocalizationMessage(124)) then
		local args={}
		local minindex
		for str in string.gmatch(text, "([^".." ".."]+)") do
			table.insert(args, str)
		end
		if #args < 2 then
			print(GetLocalizationMessage(118), #args)
			return
		end
		minindex = tonumber(keyOf(args, GetLocalizationMessage(125)))
		if minindex == nil then print("Unable to parse args: ", table.concat(args)) return end
		print(GetLocalizationMessage(121), args[minindex+1], GetLocalizationMessage(122), args[minindex+2])
		sampAddChatMessage(string.format(GetLocalizationMessage(123), args[minindex+1], args[minindex+2]), 0xFFFFFFFF)
		table.insert(PPMX, tonumber(args[minindex+1]))
		table.insert(PPMY, tonumber(args[minindex+2]))
		table.insert(PPMZ, 0)
		PPMCur = #PPMX
	end
end

function SwitchTargetInput()
	settings.maincfg.IsTargetInputActive = not(settings.maincfg.IsTargetInputActive)
end

function UpdateAP(vehID)
	local vpX, vpY, vpZ = getCarCoordinates(vehID)
	if getDistanceBetweenCoords3d(vpX, vpY, vpZ, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur]) < 10 then
		AutoPilot_NextPPM()
	end
	if not sampIsChatInputActive() and not(sampIsChatInputActive()) then
		if isKeyJustPressed(keys.VK_W) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_S) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_A) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_D) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_LEFT) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_RIGHT) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_DOWN) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_UP) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_Q) then
			AutoPilotOff_CMD()
		elseif isKeyJustPressed(keys.VK_E) then
			AutoPilotOff_CMD()
		end
	end
end

function AutoPilot_NextPPM()
	if PPMCur+1 < #PPMX+1 and not (PPMX[PPMCur+1] == nil) then
		PPMCur = PPMCur+1
		AutoPilot_CMD()
	elseif not (PPMX[1] == nil) then
		PPMCur = 1
		AutoPilot_CMD()
	else
		AutoPilotOff_CMD()
	end
end

function NextPPM()
	if PPMCur+1 < #PPMX+1 and not (PPMX[PPMCur+1] == nil) then
		PPMCur = PPMCur+1
	elseif not (PPMX[1] == nil) then
		PPMCur = 1
	else
	end
end

function AutoPilot_PrevPPM()
	if PPMCur-1 > 0 and not (PPMX[PPMCur-1] == nil) then
		PPMCur = PPMCur-1
		AutoPilot_CMD()
	elseif not (PPMX[#PPMX] == nil) then
		PPMCur = #PPMX
		AutoPilot_CMD()
	else
		AutoPilotOff_CMD()
	end
end

function PrevPPM()
	if PPMCur-1 > 0 and not (PPMX[PPMCur-1] == nil) then
		PPMCur = PPMCur-1
	elseif not (PPMX[#PPMX] == nil) then
		PPMCur = #PPMX
	else
	end
end

function WPT_Ctrls()
	if isKeyJustPressed(settings.maincfg.NextWPTKey) and not(sampIsChatInputActive()) then--keys.VK_OEM_6) then
		if (IsAutoPilot) then
			AutoPilot_NextPPM()
		elseif settings.maincfg.AvionicsMode == 4 then
			NextAirport()
		else
			NextPPM()
		end
	elseif isKeyJustPressed(settings.maincfg.PrevWPTKey) and not(sampIsChatInputActive()) then--keys.VK_OEM_4) then
		if (IsAutoPilot) then
			AutoPilot_PrevPPM()
		elseif settings.maincfg.AvionicsMode == 4 then
			PrevAirport()
		else
			PrevPPM()
		end
	end
end

----------------------------------------------------------#region LOADS
function OnLoadPlaneGUI()
	print("loadrender")
	hud_ap_ac = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_ap_ac.png")
	hud_ap_da = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_ap_da.png")
	hud_ap_ls = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_ap_ls.png")
	hud_ap_lv = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_ap_lv.png")
	hud_ap_sf = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_ap_sf.png")
	hud_comp = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_comp.png")
	hud_gear = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_gear.png")
	hud_ils = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_ils.png")
	hud_lineh = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_lineh.png")
	hud_linev = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_linev.png")
	hud_lock = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_lock.png")
	hud_mesh = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_mesh.png")
	hud_numbox = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_numbox.png")
	hud_out1 = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_out1.png")
	hud_out2 = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_out2.png")
	hud_out3 = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_out3.png")
	hud_pithb = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_pithb.png")
	hud_pithh = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_pithh.png")
	hud_pithn = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_pithn.png")
	hud_pithp = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_pithp.png")
	hud_pitht = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_pitht.png")
	hud_radar = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_radar.png")
	hud_self = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_self.png")
	hud_vvec = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_vvec.png")
	hud_warn = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_warn.png")
	hud_fire = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_fire.png")
	hud_aft = renderLoadTextureFromFile(getGameDirectory() .. "\\moonloader\\resource\\avionics\\hud_aft.png")
end

function LoadTextFont()
	Text_FontMain = renderCreateFont("Arial Rounded MT", 17, 1, 1)--traffix
	Text_FontMedium =	renderCreateFont("EagleSans", 11, 1, 1)
	Text_FontLow = renderCreateFont("EagleSans", 9, 1, 1)
	Text_FontLowest = renderCreateFont("EagleSans", 7, 1, 1)
end

function UnloadTextFont()
	renderReleaseFont(Text_FontMain)
	renderReleaseFont(Text_FontMedium)
	renderReleaseFont(Text_FontLow)
	renderReleaseFont(Text_FontLowest)
end

function RenderPlaneGUI()
	renderDrawTexture(hud_numbox, CentralPosX-310, CentralPosY-95, 100, 50, 180, RenderColor)
	renderDrawTexture(hud_numbox, CentralPosX+225, CentralPosY-95, 100, 50, 180, RenderColor)
	renderDrawTexture(hud_numbox, CentralPosX-40, CentralPosY-215, 100, 50, 180, RenderColor)
end

function StartRenderingPlaneGUI()
	
end

function RenderAfterBurner(vehID)
	local GearStatus = getPlaneUndercarriagePosition(vehID)
end

function Lang_IsCarEng(vehID)
	local modelID = getCarModel(vehID)
	if modelID == 461 then return true
	elseif modelID == 443 then return true
	elseif modelID == 438 then return true
	elseif modelID == 408 then return true
	elseif modelID == 476 then return true
	elseif modelID == 513 then return true
	else return false
	end
end

function Lang_Update()
	UnLoadAudioStreams()
	LoadAudioStreams()
end

function LoadAudioStreams()
	if Lang_Eng then-------------------------------------------------------------------------------------------ENG
		audio_startingmessage = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\StartingMessage_ENG.mp3")
		audio_pullup = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Altitude_ENG.mp3")
		audio_systemfail = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\FlightControls_ENG.mp3")
		audio_power = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Power_ENG.mp3")
		audio_catapult = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Fire_ENG.mp3")
		audio_hydrofail = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\WarningWarning_ENG.mp3")
		audio_leftenginefire = audio_catapult
		audio_rightenginefire = audio_catapult
		audio_pullup2 = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\PullUp_ENG.mp3")
		audio_autopilotoff = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\ACSOff_ENG.mp3")
		audio_maxG = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\MaxG_ENG.mp3")
		audio_threat = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\SPO_Lock_EN.mp3")
		audio_bigroll = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Roll_ENG.mp3")
		audio_launch = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\LaunchAuthorised.mp3")
	else-------------------------------------------------------------------------------------------------------RU
		audio_startingmessage = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\StartingMessage.mp3")
		audio_pullup = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\PullUp.mp3")
		audio_systemfail = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\SystemsFailure.mp3")
		audio_power = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Power.mp3")
		audio_catapult = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Catapult.mp3")
		audio_hydrofail = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\HydrolicsFailure.mp3")
		audio_leftenginefire = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\LeftEngineFire.mp3")
		audio_rightenginefire = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\RightEngineFire.mp3")
		audio_pullup2 = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\PullUp2.mp3")
		audio_autopilotoff = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\ACSOff.mp3")
		audio_maxG = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\MaxG.mp3")
		audio_threat = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\SPO_Lock.mp3")
		audio_bigroll = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Roll.mp3")
		audio_launch = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\LaunchAuthorised.mp3")
	end
	setAudioStreamVolume(audio_startingmessage, 1.0)
	setPlay3dAudioStreamAtCar(audio_startingmessage, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_pullup, 1.0)
	setPlay3dAudioStreamAtCar(audio_pullup, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_power, 1.0)
	setPlay3dAudioStreamAtCar(audio_power, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_systemfail, 1.0)
	setPlay3dAudioStreamAtCar(audio_systemfail, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_catapult, 1.0)
	setPlay3dAudioStreamAtCar(audio_catapult, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_hydrofail, 1.0)
	setPlay3dAudioStreamAtCar(audio_hydrofail, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_pullup2, 1.0)
	setPlay3dAudioStreamAtCar(audio_pullup, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_autopilotoff, 1.0)
	setPlay3dAudioStreamAtCar(audio_autopilotoff, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_autopilotoff, 1.0)
	setPlay3dAudioStreamAtCar(audio_maxG, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_threat, 1.0)
	setPlay3dAudioStreamAtCar(audio_threat, storeCarCharIsIn(PLAYER_PED))

	setAudioStreamVolume(audio_bigroll, 1.0)
	setPlay3dAudioStreamAtCar(audio_bigroll, storeCarCharIsIn(PLAYER_PED))
	
	setAudioStreamVolume(audio_launch, 1.0)
	setPlay3dAudioStreamAtCar(audio_launch, storeCarCharIsIn(PLAYER_PED))
	
	
	audio_misfu = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile12OClockHigh.mp3")
	setAudioStreamVolume(audio_misfu, 1.0)
	setPlay3dAudioStreamAtCar(audio_misfu, storeCarCharIsIn(PLAYER_PED))
	audio_misfd = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile12OClockLow.mp3")
	setAudioStreamVolume(audio_misfd, 1.0)
	setPlay3dAudioStreamAtCar(audio_misfd, storeCarCharIsIn(PLAYER_PED))
	audio_misru = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile3OClockHigh.mp3")
	setAudioStreamVolume(audio_misru, 1.0)
	setPlay3dAudioStreamAtCar(audio_misru, storeCarCharIsIn(PLAYER_PED))
	audio_misrd = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile3OClockLow.mp3")
	setAudioStreamVolume(audio_misrd, 1.0)
	setPlay3dAudioStreamAtCar(audio_misrd, storeCarCharIsIn(PLAYER_PED))
	audio_misbu = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile6OClockHigh.mp3")
	setAudioStreamVolume(audio_misbu, 1.0)
	setPlay3dAudioStreamAtCar(audio_misbu, storeCarCharIsIn(PLAYER_PED))
	audio_misbd = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile6OClockLow.mp3")
	setAudioStreamVolume(audio_misbd, 1.0)
	setPlay3dAudioStreamAtCar(audio_misbd, storeCarCharIsIn(PLAYER_PED))
	audio_mislu = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile9OClockHigh.mp3")
	setAudioStreamVolume(audio_mislu, 1.0)
	setPlay3dAudioStreamAtCar(audio_mislu, storeCarCharIsIn(PLAYER_PED))
	audio_misld = loadAudioStream(getGameDirectory() .. "\\moonloader\\resource\\avionics\\audio\\Missile9OClockLow.mp3")
	setAudioStreamVolume(audio_misld, 1.0)
	setPlay3dAudioStreamAtCar(audio_misld, storeCarCharIsIn(PLAYER_PED))
end

function UnLoadAudioStreams()
	releaseAudioStream(audio_startingmessage)
	releaseAudioStream(audio_pullup)
	releaseAudioStream(audio_power)
	releaseAudioStream(audio_systemfail)
	releaseAudioStream(audio_catapult)
	if not Lang_Eng then 
		releaseAudioStream(audio_hydrofail)	
		releaseAudioStream(audio_leftenginefire)	
		releaseAudioStream(audio_rightenginefire)	
	end
	releaseAudioStream(audio_pullup2)
	releaseAudioStream(audio_autopilotoff)
	releaseAudioStream(audio_misfu)
	releaseAudioStream(audio_misfd)
	releaseAudioStream(audio_misru)
	releaseAudioStream(audio_misrd)
	releaseAudioStream(audio_misbu)
	releaseAudioStream(audio_misbd)
	releaseAudioStream(audio_mislu)
	releaseAudioStream(audio_misld)
	releaseAudioStream(audio_threat)
	releaseAudioStream(audio_bigroll)
	releaseAudioStream(audio_launch)
end

function UnRenderPlaneGUI()
	print("unrender")
	renderReleaseTexture(hud_ap_ac)
	renderReleaseTexture(hud_ap_da)
	renderReleaseTexture(hud_ap_ls)
	renderReleaseTexture(hud_ap_lv)
	renderReleaseTexture(hud_ap_sf)
	renderReleaseTexture(hud_comp)
	renderReleaseTexture(hud_gear)
	renderReleaseTexture(hud_ils)
	renderReleaseTexture(hud_lineh)
	renderReleaseTexture(hud_linev)
	renderReleaseTexture(hud_lock)
	renderReleaseTexture(hud_mesh)
	renderReleaseTexture(hud_numbox)
	renderReleaseTexture(hud_out1)
	renderReleaseTexture(hud_out2)
	renderReleaseTexture(hud_out3)
	renderReleaseTexture(hud_pithb)
	renderReleaseTexture(hud_pithh)
	renderReleaseTexture(hud_pithn)
	renderReleaseTexture(hud_pithp)
	renderReleaseTexture(hud_pitht)
	renderReleaseTexture(hud_radar)
	renderReleaseTexture(hud_self)
	renderReleaseTexture(hud_vvec)
	renderReleaseTexture(hud_warn)
	renderReleaseTexture(hud_fire)
	renderReleaseTexture(hud_aft)
end


----------------------------------------------------------#region UPDATES
function UpdatePlaneDamage(vehID)
	chp = getCarHealth(vehID)
	if (chp < 350) then 
		DamageLevel = 4
		if (chp < 237) and settings.maincfg.IsAutoLeave then taskLeaveCar(PLAYER_PED, vehID) end
		return
	end
	if (chp < 500) then
		DamageLevel = 3
		return
	end
	if (chp < 700) then
		DamageLevel = 2
		return
	end
	if (chp < 800) then
		DamageLevel = 1
		return
	end
	DamageLevel = 0
end

function UpdatePlaneGUI(vehID)
	if DamageLevel < 2 and settings.maincfg.IsHUDEnabled then UpdateSpeedVector(vehID) end
	if DamageLevel < 3 and settings.maincfg.IsHUDEnabled then 
		if settings.maincfg.AvionicsMode == 0 then
			if Lang_Eng then
				UpdateLines(vehID)
				
			else
				UpdateLinesRU(vehID)
			end
		elseif settings.maincfg.AvionicsMode == 4 then
			if Lang_Eng then
				UpdateLines_LND(vehID)
			else
				UpdateLines_LND_RU(vehID)
			end
		else
			UpdateLines2(vehID)
		end
	end
	if DamageLevel < 4 then UpdateGEAR(vehID) end
	if not (PPMCur == -1) and DamageLevel < 1 then
		UpdatePPM(PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur], vehID)
	end
end

function PlayPlaneAvionicsStart(vehID)
	setAudioStreamState(audio_startingmessage, as_action.PLAY)
end

function UpdatePlaneRText(vehID)
	local vX, vY, vZ = getCarCoordinates(vehID)
	local vRX, vRY, vRZ;
	local vSpd = getCarSpeed(vehID)*2
	local TDistance = 0
	local TTime = 0
	local vHP = getCarHealth(vehID)
	local radZ = vZ - getGroundZFor3dCoord(vX,vY,vZ)
	local deltaHeading
	
	
	local T_PPMCurColor = RenderColor
	local T_TTimeColor = RenderColor
	local T_TDistanceColor = RenderColor
	local T_vRZColor = RenderColor
	local T_vRXColor = RenderColor
	local T_vRYColor = RenderColor
	local T_vSpdColor = RenderColor	
	if not (PPMCur == -1) then
		TDistance = getDistanceBetweenCoords3d(vX, vY, vZ, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur])
		TTime = TDistance*2/vSpd
	end
	
	vRX = getCarRoll(vehID)
	vRY = getCarPitch(vehID)
	if vRY > 180 then vRY = vRY-360 end
	if math.abs(vRX) > 90 then 
		if vRY > 90 then 
			vRY = math.abs(vRY) - 180 
		else 
			if vRY < -90 then
				vRY = (vRY + 180)*-1
			end
		end
	end
	
	vRZ = 360-getCarHeading(vehID)
	deltaHeading = vRZ - PrevHdng
	PrevHdng = vRZ
	
	
	if (IterTimer == 5) then 
		deltaSpd = (vSpd - PrevSpd)*2
			
		if deltaSpd > 0 then
			T_deltaSpdPosX = CentralPosX-303
			T_deltaSpdPosY = CentralPosY-100
		else
			T_deltaSpdPosX = CentralPosX-303
			T_deltaSpdPosY = CentralPosY-55		
		end
		T_deltaSpdColor = RenderColor
		
	end
	if math.abs(vRX) > 100 then
		T_vRXPos = {242, 322}
	else
		if math.abs(vRX) < 100 then
			T_vRXPos = {242, 322}
		end
	end
	
	if (radZ < settings.maincfg.DangerAlt) or (vZ < settings.maincfg.DangerAlt) then
		if not AltStatus == 1 then
			AltStatus = 1
		else
		end
		if IsDangerAlt then
		else
			if radZ < 5 then--Для наземной стоянки
				IsAudioAvaliable = false
				AltStatus = 0
			else
				IsDangerAlt = true
				T_vZColor = 0xFFCC0000
				T_radZColor = 0xFFCC0000
				T_deltaZColor = 0xFFCC0000
				if IsAudioAvaliable and not (isCharInAnyHeli(PLAYER_PED)) then 
					setAudioStreamState(audio_pullup, as_action.PLAY)
					IsAudioAvaliable = false
					ResetAudioTimer()			
				end
			end
		end
		
	else		
		if not AltStatus == 2 then
			setAudioStreamState(audio_engineback, as_action.PLAY)
			AltStatus = 2
		end
		if IsDangerAlt then 
			IsDangerAlt = false 
			T_vZColor = RenderColor
			T_radZColor = RenderColor
			T_deltaZColor = RenderColor
		end
	end
	
	if (radZ < math.abs(deltaZ*2)) and (deltaZ < 0) and IsAudioAvaliable and not (isCharInAnyHeli(PLAYER_PED)) then
		setAudioStreamState(audio_pullup2, as_action.PLAY)
		IsAudioAvaliable = false
		ResetAudioTimer()
	end
	
	if vSpd < 40 and deltaZ < 0 and (radZ > 5) and not (isCharInAnyHeli(PLAYER_PED)) then--<60
		T_vSpdColor = 0xFFCC0000
		
		if (isKeyDown(keys.VK_W) and not(sampIsChatInputActive()) and not (getCarModel(vehID) == 520)) then
			if (getAudioStreamState(audio_maxG) == -1) and (getAudioStreamState(audio_power) == -1) and IsAudioAvaliable then
				setAudioStreamState(audio_maxG, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
			renderFontDrawText(Text_FontMain, "Over-G!", CentralPosX-30, CentralPosY-20, 0xFFCC0000, false)
		elseif (getCarModel(vehID) ~= 520) then
			if (getAudioStreamState(audio_maxG) == -1) and (getAudioStreamState(audio_power) == -1) then
				setAudioStreamState(audio_power, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
			renderFontDrawText(Text_FontMain, "STALL!", CentralPosX-25, CentralPosY-20, 0xFFCC0000, false)
		end
		T_deltaSpdColor = 0xFFCC0000
	else
		sampTextdrawSetLetterSizeAndColor(237, 0.3, 1.0, RenderColor)
		T_vSpdColor = RenderColor
	end
	
	if vHP < 600 then
		if vHP < 300 then
			if IsAudioAvaliable then 
				setAudioStreamState(audio_catapult, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
		elseif vHP < 351 then
			if IsAudioAvaliable then 
				setAudioStreamState(audio_hydrofail, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
		else
			if IsAudioAvaliable then 
				setAudioStreamState(audio_systemfail, as_action.PLAY)
				IsAudioAvaliable = false	
				ResetAudioTimer()				
			end
		end
	else
		
	end
	if isCharInAnyHeli(PLAYER_PED) then
		--print("{FF0000}YEA")
		if math.abs(vRX) > 50 and getAudioStreamState(audio_bigroll) == -1 and IsAudioAvaliable then
			setAudioStreamState(audio_bigroll, as_action.PLAY)
			IsAudioAvaliable = false
			ResetAudioTimer()
		end
	end
	local vModel = getCarModel(vehID)
	if DamageLevel < 4 then 
		render_text(Text_FontMain, string.format("%.0f", vSpd), CentralPosX-283, CentralPosY-85, T_vSpdColor, 1, 0xFF000000, false)
		render_text(Text_FontMedium, string.format("%.1f", deltaSpd), T_deltaSpdPosX, T_deltaSpdPosY, T_deltaSpdColor, 1, 0xFF000000, false)
		if settings.maincfg.AvionicsMode == 4 then
			render_text(Text_FontMain, string.format("%.0f", vZ-landing_data.Runway.z), CentralPosX+255, CentralPosY-85, T_vZColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontMain, string.format("%.0f", vZ), CentralPosX+255, CentralPosY-85, T_vZColor, 1, 0xFF000000, false)
		end
		render_text(Text_FontMedium, string.format("%.2f", deltaZ), CentralPosX+235, CentralPosY-10, T_deltaZColor, 1, 0xFF000000, false)
		if (radZ > 200) then
			render_text(Text_FontMedium,"rad: inf.", CentralPosX+315, CentralPosY-70, T_radZColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontMedium, string.format("rad: %.0f", radZ), CentralPosX+315, CentralPosY-70, T_radZColor, 1, 0xFF000000, false)
		end
	end
	if DamageLevel < 3 then
		UpdateVHeight(deltaZ)
	end
	if DamageLevel < 2 then
		render_text(Text_FontMedium, string.format("Pitch: %.1f", vRY), CentralPosX-300, CentralPosY, T_vRYColor, 1, 0xFF000000, false)
		render_text(Text_FontMedium, string.format("Roll: %.0f", vRX), CentralPosX-10, CentralPosY+250, T_vRXColor, 1, 0xFF000000, false)
		render_text(Text_FontMain, string.format("%.0f", vRZ), CentralPosX-2, CentralPosY-205, T_vRZColor, 1, 0xFF000000, false)
		if deltaHeading > 0.09 then--+52 -162
			render_text(Text_FontMedium, string.format("%.2f", deltaHeading), CentralPosX+52, CentralPosY-173, RenderColor, 1, 0xFF000000, false)
		elseif deltaHeading < -0.09 then
			local TxtSize = renderGetFontDrawTextLength(Text_FontMedium, string.format("%.2f", deltaHeading))
			render_text(Text_FontMedium, string.format("%.2f", deltaHeading*-1), CentralPosX-32-TxtSize, CentralPosY-173, RenderColor, 1, 0xFF000000, false)
		end
	end
	if DamageLevel < 1 then
		render_text(Text_FontLow, string.format("DST: %.0f (m)", TDistance), CentralPosX+215, CentralPosY+90, RenderColor, 1, 0xFF000000, false)
		render_text(Text_FontLow, string.format("TOT: %.1f (sec)", TTime), CentralPosX+215, CentralPosY+110, RenderColor, 1, 0xFF000000, false)
		if PPMCur > 0 then
			render_text(Text_FontLow, string.format("WPT: %i [%.2f; %.2f; %.2f]", PPMCur, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur]), CentralPosX+215, CentralPosY+70, RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("WPT: %i [NOT SET]", PPMCur), CentralPosX+215, CentralPosY+70, RenderColor, 1, 0xFF000000, false)
		end
		if settings.maincfg.AvionicsMode == 0 then
			render_text(Text_FontLow, string.format("NAV", PPMCur), CentralPosX+215, CentralPosY+215, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 1 then
			render_text(Text_FontLow, string.format("VRF", PPMCur), CentralPosX+215, CentralPosY+215, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 2 then
			render_text(Text_FontLow, string.format("GRD", PPMCur), CentralPosX+215, CentralPosY+215, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 3 then
			render_text(Text_FontLow, string.format("LRF", PPMCur), CentralPosX+215, CentralPosY+215, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 4 then
			render_text(Text_FontLow, string.format("LND", PPMCur), CentralPosX+215, CentralPosY+215, RenderColor, 1, 0xFF000000, false)
		end
	end
	if IsAutoPilot then
		renderFontDrawText(Text_FontMedium, string.format("Autopilot", TDistance), CentralPosX+242, CentralPosY-103, RenderColor, false)
		renderFontDrawText(Text_FontMedium, string.format("Autopilot", TDistance), CentralPosX-290, CentralPosY-103, RenderColor, false)
		if  not IsCameraMode then renderFontDrawText(Text_FontMain, string.format("Autopilot", TDistance), CentralPosX-20, CentralPosY, RenderColor, false) end
	end
	if IsCameraMode then
		if  IsNightVis then
			render_text(Text_FontLow, string.format("Channel: IR", (Cam_Zoom-70)*-1), CentralPosX-260, CentralPosY+240, RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("Channel: Visual", (Cam_Zoom-70)*-1), CentralPosX-260, CentralPosY+240, RenderColor, 1, 0xFF000000, false)
		end
		if not (Cam_TarX == -999 and Cam_TarY == -999 and Cam_TarZ == -999) then
			render_text(Text_FontLow, string.format("Fixed camera\n[%.2f; %.2f; %.2f]\n(GNSS coordinates)", Cam_TarX, Cam_TarY, Cam_TarZ), CentralPosX-260, CentralPosY+190, RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("Unfixed camera\n[%.2f; %.2f]\n(Local orientation)", Cam_PrevRotX, Cam_PrevRotY), CentralPosX-260, CentralPosY+190, RenderColor, 1, 0xFF000000, false)
		end
	end
end


function UpdatePlaneRTextRU(vehID)
	local vX, vY, vZ = getCarCoordinates(vehID)
	local vRX, vRY, vRZ;
	local vSpd = getCarSpeed(vehID)*2
	local TDistance = 0
	local TTime = 0
	local vHP = getCarHealth(vehID)
	local radZ = vZ - getGroundZFor3dCoord(vX,vY,vZ)
	local deltaHeading
	
	
	local T_PPMCurColor = RenderColor
	local T_TTimeColor = RenderColor
	local T_TDistanceColor = RenderColor
	local T_vRZColor = RenderColor
	local T_vRXColor = RenderColor
	local T_vRYColor = RenderColor
	local T_vSpdColor = RenderColor	
	if not (PPMCur == -1) then
		TDistance = getDistanceBetweenCoords3d(vX, vY, vZ, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur])
		TTime = TDistance*2/vSpd
	end
	
	vRX = getCarRoll(vehID)
	vRY = getCarPitch(vehID)
	if vRY > 180 then vRY = vRY-360 end
	if math.abs(vRX) > 90 then 
		if vRY > 90 then 
			vRY = math.abs(vRY) - 180 
		elseif vRY < -90 then
			vRY = (vRY + 180)*-1
		end
	end
	
	vRZ = 360-getCarHeading(vehID)
	deltaHeading = vRZ - PrevHdng
	PrevHdng = vRZ
	RenderLinesHorizontalRU(vRZ)
	
	if (IterTimer == 5) then 
		deltaSpd = (vSpd - PrevSpd)*2
		T_deltaSpdPosX = (CentralPosX - 175) + (deltaSpd)
		if T_deltaSpdPosX > CentralPosX-150 then T_deltaSpdPosX = CentralPosX - 150
		elseif T_deltaSpdPosX < CentralPosX - 200 then T_deltaSpdPosX = CentralPosX - 200
		end
		sampTextdrawSetPos(236, 210, 180)
		sampTextdrawSetPos(236, 210, 200)
		T_deltaSpdPosY = CentralPosY-115
		T_deltaSpdColor = RenderColor
		
	end
	if math.abs(vRX) > 100 then
		T_vRXPos = {242, 322}
	elseif math.abs(vRX) < 100 then
		T_vRXPos = {242, 322}
	end
	
	if (radZ < settings.maincfg.DangerAlt) or (vZ < settings.maincfg.DangerAlt) then
		if not AltStatus == 1 then
			AltStatus = 1
		else
		end
		if IsDangerAlt then
		else
			if radZ < 5 then--Для наземной стоянки
				IsAudioAvaliable = false
				AltStatus = 0
			else
				IsDangerAlt = true
				T_vZColor = 0xFFCC0000
				T_radZColor = 0xFFCC0000
				T_deltaZColor = 0xFFCC0000
				if IsAudioAvaliable and not (isCharInAnyHeli(PLAYER_PED)) then 
					setAudioStreamState(audio_pullup, as_action.PLAY)
					IsAudioAvaliable = false
					ResetAudioTimer()			
				end
			end
		end
		
	else		
		if not AltStatus == 2 then
			setAudioStreamState(audio_engineback, as_action.PLAY)
			AltStatus = 2
		end
		if IsDangerAlt then 
			IsDangerAlt = false 
			T_vZColor = RenderColor
			T_radZColor = RenderColor
			T_deltaZColor = RenderColor
		end
	end
	
	if (radZ < math.abs(deltaZ*2)) and (deltaZ < 0) and IsAudioAvaliable and not (isCharInAnyHeli(PLAYER_PED)) then
		setAudioStreamState(audio_pullup2, as_action.PLAY)
		IsAudioAvaliable = false
		ResetAudioTimer()
	end
	
	if vSpd < 40 and deltaZ < 0 and (radZ > 5) and not (isCharInAnyHeli(PLAYER_PED)) then--<60
		T_vSpdColor = 0xFFCC0000
		
		if (isKeyDown(keys.VK_W) and not(sampIsChatInputActive())) then
			if (getAudioStreamState(audio_maxG) == -1) and (getAudioStreamState(audio_power) == -1) and IsAudioAvaliable then
				setAudioStreamState(audio_maxG, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
			renderFontDrawText(Text_FontMain, "!Перегрузка!", CentralPosX-70, CentralPosY-20, 0xFFCC0000, false)
		elseif (getCarModel(vehID) ~= 520) then
			if (getAudioStreamState(audio_maxG) == -1) and (getAudioStreamState(audio_power) == -1) then
				setAudioStreamState(audio_power, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
			renderFontDrawText(Text_FontMain, "!Срыв!", CentralPosX-35, CentralPosY-20, 0xFFCC0000, false)
		end
		T_deltaSpdColor = 0xFFCC0000
	else
		sampTextdrawSetLetterSizeAndColor(237, 0.3, 1.0, RenderColor)
		T_vSpdColor = RenderColor
	end
	
	if vHP < 600 then
		if vHP < 300 then
			if IsAudioAvaliable then 
				setAudioStreamState(audio_catapult, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
		elseif vHP < 351 then
			if IsAudioAvaliable then 
				setAudioStreamState(audio_hydrofail, as_action.PLAY) 
				IsAudioAvaliable = false
				ResetAudioTimer()
			end
		else
			if IsAudioAvaliable then 
				setAudioStreamState(audio_systemfail, as_action.PLAY)
				IsAudioAvaliable = false	
				ResetAudioTimer()				
			end
		end
	else
		
	end
	
	if isCharInAnyHeli(PLAYER_PED) then
		if math.abs(vRX) > 50 and getAudioStreamState(audio_bigroll) == -1 and IsAudioAvaliable then
			setAudioStreamState(audio_bigroll, as_action.PLAY)
			IsAudioAvaliable = false
			ResetAudioTimer()
		end
	end
	local vModel = getCarModel(vehID)
	if DamageLevel < 4 then 
		render_text(Text_FontMain, string.format("%.0f", vSpd), CentralPosX-190, CentralPosY-145, T_vSpdColor, 1, 0xFF000000, false)
		
		local TxtSize = renderGetFontDrawTextLength(Text_FontLow, string.format("%.1f", deltaSpd))
		render_text(Text_FontMedium, string.format("%.1f", deltaSpd), T_deltaSpdPosX - (TxtSize/2), T_deltaSpdPosY, T_deltaSpdColor, 1, 0xFF000000, false)
		
		renderBegin(2)--deltaSpeed arrow
		renderColor(T_deltaSpdColor)
		renderVertex(T_deltaSpdPosX, T_deltaSpdPosY - 5)
		renderVertex(T_deltaSpdPosX, T_deltaSpdPosY - 1)
		renderEnd()
		if settings.maincfg.AvionicsMode == 4 then
			render_text(Text_FontMain, string.format("%.0f", vZ-landing_data.Runway.z), CentralPosX+150, CentralPosY-145, T_vZColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontMain, string.format("%.0f", vZ), CentralPosX+150, CentralPosY-145, T_vZColor, 1, 0xFF000000, false)
		end
		render_text(Text_FontLow, string.format("%.2f (м/с)", deltaZ), CentralPosX+260, CentralPosY, T_deltaZColor, 1, 0xFF000000, false)
		if radZ > 200 then
			render_text(Text_FontLow, "рад: беск.", CentralPosX+150, CentralPosY-120, T_radZColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("рад: %.0f (м)", ((radZ > 200) and "?" or radZ)), CentralPosX+150, CentralPosY-120, T_radZColor, 1, 0xFF000000, false)
		end
	end
	if DamageLevel < 3 then
		UpdateVHeightRU(deltaZ)
	end
	if DamageLevel < 2 then
		render_text(Text_FontLow, string.format("%.1f°", vRY), CentralPosX+175, CentralPosY-7, T_vRYColor, 1, 0xFF000000, false)
		render_text(Text_FontLow, string.format("Крен: %.0f°", vRX), CentralPosX-20, CentralPosY+250, T_vRXColor, 1, 0xFF000000, false)
		local vRZSize = renderGetFontDrawTextLength(Text_FontMedium, string.format("%.0f", vRZ))
		render_text(Text_FontMedium, string.format("%.0f", vRZ), CentralPosX-(vRZSize/2), CentralPosY-115, T_vRZColor, 1, 0xFF000000, false)
		if deltaHeading > 0.09 then--+52 -162
			render_text(Text_FontLow, string.format("%.2f (°/с)->", deltaHeading), CentralPosX+1+vRZSize, CentralPosY-110, RenderColor, 1, 0xFF000000, false)
		elseif deltaHeading < -0.09 then
			local TxtSize = renderGetFontDrawTextLength(Text_FontLow, string.format("%.2f (°/с)", deltaHeading))
			render_text(Text_FontLow, string.format("<-%.2f (°/с)", deltaHeading*-1), CentralPosX-5-vRZSize-TxtSize, CentralPosY-110, RenderColor, 1, 0xFF000000, false)
		end
	end
	if DamageLevel < 1 then
		if PPMCur > 0 then
			render_text(Text_FontLow, string.format("ППМ: %i [%.2f; %.2f; %.2f]", PPMCur, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur]), CentralPosX-70, CentralPosY+150, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("ДСТ: %.0f (м)", TDistance), CentralPosX-35, CentralPosY+165, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("tпдл: %.1f (сек)", TTime), CentralPosX-40, CentralPosY+180, RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("ППМ: %i [НЕ ЗАДАН]", PPMCur), CentralPosX-50, CentralPosY+150, RenderColor, 1, 0xFF000000, false)
		end
		if settings.maincfg.AvionicsMode == 0 then
			render_text(Text_FontLow, string.format("НАВ", PPMCur), CentralPosX+180, CentralPosY+55, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 1 then
			render_text(Text_FontLow, string.format("БВБ", PPMCur), CentralPosX+180, CentralPosY+55, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 2 then
			render_text(Text_FontLow, string.format("ЗМЛ", PPMCur), CentralPosX+180, CentralPosY+55, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 3 then
			render_text(Text_FontLow, string.format("ДВБ", PPMCur), CentralPosX+180, CentralPosY+55, RenderColor, 1, 0xFF000000, false)
		elseif settings.maincfg.AvionicsMode == 4 then
			render_text(Text_FontLow, string.format("ПОС", PPMCur), CentralPosX+180, CentralPosY+55, RenderColor, 1, 0xFF000000, false)
		end
	end
	if IsAutoPilot then
		renderFontDrawText(Text_FontMedium, string.format("Автопилот", TDistance), CentralPosX+130, CentralPosY-160, RenderColor, false)
		renderFontDrawText(Text_FontMedium, string.format("Автопилот", TDistance), CentralPosX-210, CentralPosY-160, RenderColor, false)
		if  not IsCameraMode then renderFontDrawText(Text_FontMain, string.format("Автопилот", TDistance), CentralPosX-50, CentralPosY, RenderColor, false) end
	end
	if IsCameraMode then
		if  IsNightVis then
			render_text(Text_FontLow, string.format("Канал: ИК", (Cam_Zoom-70)*-1), CentralPosX-260, CentralPosY+240, RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("Канал: Визуал.", (Cam_Zoom-70)*-1), CentralPosX-260, CentralPosY+240, RenderColor, 1, 0xFF000000, false)
		end
		if not (Cam_TarX == -999 and Cam_TarY == -999 and Cam_TarZ == -999) then
			render_text(Text_FontLow, string.format("Фикс. камера\n[%.2f; %.2f; %.2f]\n(ГЛОНАСС)", Cam_TarX, Cam_TarY, Cam_TarZ), CentralPosX-260, CentralPosY+190, RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLow, string.format("Своб. камера\n[%.2f; %.2f]\n(Отн. координаты)", Cam_PrevRotX, Cam_PrevRotY), CentralPosX-260, CentralPosY+190, RenderColor, 1, 0xFF000000, false)
		end
	end
end

function render_text(font, text, x, y, color, outline, outline_color, ignore_colortags)
    if outline > 0 then
        renderFontDrawText(font, text, x, y + outline, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x + outline, y + outline, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x + outline, y, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x + outline, y - outline, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x, y - outline, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x - outline, y - outline, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x - outline, y, outline_color, ignore_colortags)
        renderFontDrawText(font, text, x - outline, y + outline, outline_color, ignore_colortags)
    end
    renderFontDrawText(font, text, x, y, color, ignore_colortags)
end

function UpdatePlaneRTextLines2(vY, vR)
	OffcetY = vY*10
	PosY = CentralPosY+OffcetY+10
	local itt = 0
	if PosY < 750 and PosY > 300 then 
		renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+160, PosY, RenderColor, false) 
		renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-170, PosY, RenderColor, false) 
	end
	local ITRi = 40
	while ITRi < 6600  do
		PosY = CentralPosY+ITRi+OffcetY+20
		if PosY < 800 and PosY > 450 then 
			itt = itt - 5
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+150, PosY, RenderColor, false) 
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-160, PosY, RenderColor, false) 
		end
		ITRi = ITRi + 60
	end
	ITRi = -60
	itt = 0
	while ITRi > -6600 do
		PosY = CentralPosY+ITRi+OffcetY+20
		if PosY < 800 and PosY > 450 then 
			itt = itt + 5
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+150, PosY, RenderColor, false) 
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-160, PosY, RenderColor, false) 
		end
		ITRi = ITRi - 60
	end
end

function UpdatePlaneRTextLines(vY, vR)
	PosY = CentralPosY+OffcetY-10
	local itt = 0
	if PosY < 850 and PosY > 300 then 
		renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-200, PosY+7, RenderColor, false) 
		renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+210, PosY+7, RenderColor, false) 
	end
	local ITRi = 60
	while ITRi < 3300 do
		PosY = CentralPosY+ITRi+OffcetY-10
		if PosY < 850 and PosY > 300 then 
			itt = itt - 10
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-170, PosY+9, RenderColor, false) 
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+170, PosY+9, RenderColor, false) 
		end
		ITRi = ITRi + 60
	end
	ITRi = -60
	itt = 0
	while ITRi > -3300 do
		PosY = CentralPosY+ITRi+OffcetY-10
		if PosY < 850 and PosY > 300 then 
			itt = itt + 10
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-170, PosY+9, RenderColor, false) 
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+170, PosY+9, RenderColor, false) 
		end
		ITRi = ITRi - 60
	end
end

function UpdateSpeedVector(vehID)
	local vCX, vCY, vCZ = getCarCoordinates(vehID)
	local vX, vY, vZ = getCarSpeedVector(vehID)
	local spdVal = getCarSpeed(vehID)
	if spdVal < 10 then spdVal = 10 end
	local vOX, vOY, vOZ = getOffsetFromCarInWorldCoords(vehID, 0, spdVal, 0)
	local wX, wY = convert3DCoordsToScreen(vOX, vOY, vOZ)
	local sX, sY = convert3DCoordsToScreen(vCX+vX, vCY+vY, vCZ+vZ)
	
	if not  isPointOnScreen(vCX + vX, vCY + vY, vCZ + vZ, 1) then return end
	renderCircle(sX, sY, 5, RenderColor)
	renderBegin(2)
	renderColor(RenderColor)
	renderVertex(sX - 5, sY)
	renderVertex(sX - 17, sY)
	
	renderVertex(sX + 5, sY)
	renderVertex(sX + 17, sY)

	renderVertex(sX, sY - 5)
	renderVertex(sX, sY - 17)
	renderEnd()
	
	renderDrawTexture(hud_self, wX-12, wY-15, 25, 16, 180-getCarRoll(vehID), 0xFFFF0000)
	ShowTextOnRadar("[+]", vOX, vOY, vOZ)
	
end

function UpdatePPM(X, Y, Z, vehID)
	if Z < getGroundZFor3dCoord(X,Y,Z) then Z = getGroundZFor3dCoord(X,Y,Z) end
	
	local sX, sY = convert3DCoordsToScreen(X, Y, Z)
	local vX, vY, vZ = getCarSpeedVector(vehID)
	local vCX, vCY, vCZ = getCarCoordinates(vehID)
	local dist = getDistanceBetweenCoords2d(X, Y, vCX, vCY) - 500
	if not  isPointOnScreen(X, Y, Z, dist > 0 and dist or 1) then return end
	local angle =  getAngleBetween2dVectors(vCX-X, vCY-Y, vX, vY)
	if (angle > 90) then
		if Lang_Eng then
			renderSquare(sX, sY, 10, RenderColor)
		else
			renderCircle(sX, sY, 15, RenderColor)
		end
	end
end

function UpdateRotation(vehID)
	local rY = getCarRoll(vehID)
	renderDrawTexture(hud_self, CentralPosX-240, CentralPosY-20, 500, 30, 180-rY, RenderColor)
end

function UpdateLines2(vehID)
	local vY = getCarPitch(vehID)-2.5
	local vR = getCarRoll(vehID)
	local vH = getCarHeading(vehID)
	UpdatePlaneRTextLines2(vY, vR)
	
	if math.abs(vY) > 180 then vY =  vY - 360 end
	if math.abs(vR) > 90 then 
		if vY > 90 then 
			vY = 180 - vY
		end
	end
	OffcetY = vY*10
	local PosY
	
	PosY = CentralPosY+OffcetY+20
	if PosY < 850 and PosY > 300 then 
		renderDrawLine(CentralPosX+110, PosY, CentralPosX+150, PosY, 1, RenderColor)
		renderDrawLine(CentralPosX-110, PosY, CentralPosX-150, PosY, 1, RenderColor)
	end
	local ITRi = -12
	local long = 0
	while ITRi < 6600 do
		PosY = CentralPosY+ITRi+OffcetY+20
		if PosY < 850 and PosY > 400 and ITRi > 10 then 
			if long < 11 then
				if long == 5 then
					renderDrawLine(CentralPosX+120, PosY, CentralPosX+140, PosY, 1, RenderColor)
					renderDrawLine(CentralPosX-120, PosY, CentralPosX-140, PosY, 1, RenderColor)
				elseif long == 10 then
					renderDrawLine(CentralPosX+110, PosY, CentralPosX+140, PosY, 1, RenderColor)
					renderDrawLine(CentralPosX-110, PosY, CentralPosX-140, PosY, 1, RenderColor)
				long = 0
				else
					renderDrawLine(CentralPosX+130, PosY, CentralPosX+140, PosY, 1, RenderColor)
					renderDrawLine(CentralPosX-130, PosY, CentralPosX-140, PosY, 1, RenderColor)
				end
			else 
				long = 0
			end
		end
		ITRi = ITRi + 12
		long = long + 1
	end
	ITRi = 6
	long = 0
	while ITRi > -6600 do
		PosY = CentralPosY+ITRi+OffcetY+20
		if PosY < 850 and PosY > 400 and ITRi < -3 then 
			if long < 11 then
				if long == 5 then
					renderDrawLine(CentralPosX+120, PosY, CentralPosX+140, PosY, 1, RenderColor)
					renderDrawLine(CentralPosX-120, PosY, CentralPosX-140, PosY, 1, RenderColor)
				elseif long == 10 then
					renderDrawLine(CentralPosX+110, PosY, CentralPosX+140, PosY, 1, RenderColor)
					renderDrawLine(CentralPosX-110, PosY, CentralPosX-140, PosY, 1, RenderColor)
				long = 0
				else
					renderDrawLine(CentralPosX+130, PosY, CentralPosX+140, PosY, 1, RenderColor)
					renderDrawLine(CentralPosX-130, PosY, CentralPosX-140, PosY, 1, RenderColor)
				end
			else 
				long = 0
			end
		end
		ITRi = ITRi - 12
		long = long + 1
	end
end

function UpdateLines(vehID)
	local vY = getCarPitch(vehID)-2.5
	local vR = getCarRoll(vehID)
	local vHdng = 360 - getCarHeading(vehID)
	local vPX, vPY, vPZ = getCarCoordinates(vehID)
	
	local multiplyer = 1
	if math.abs(vY) > 180 then vY =  vY - 360 end
	if math.abs(vR) > 90 then 
		if vY > 90 then 
			vY = 180 - vY
		end
	end
	OffcetY = vY*10
	local PosY
	PosY = CentralPosY+OffcetY-10
	local itt = 0
	if PosY < 850 and PosY > 300 then 
		renderBegin(3)
		renderColor(RenderColor)
		renderVertex(CentralPosX-150, PosY+13)
		renderVertex(CentralPosX-150, PosY-2)
		renderVertex(CentralPosX-40, PosY-2)
		renderEnd()
		
		renderBegin(3)
		renderColor(RenderColor)
		renderVertex(CentralPosX+160, PosY+13)
		renderVertex(CentralPosX+160, PosY-2)
		renderVertex(CentralPosX+50, PosY-2)
		renderEnd()
		
		renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-160, PosY+2, RenderColor, false) 
		renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+170, PosY+2, RenderColor, false) 
	end
	local ITRi = 60
	while ITRi < 1860 do--3300 do
		PosY = CentralPosY+ITRi+OffcetY+60
		if PosY < 850 and PosY > 300 then 
			itt = itt - 10
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-160, PosY-7, RenderColor, false) 
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+160, PosY-7, RenderColor, false) 
			if PosY < 850 and PosY > 300 then 
				renderBegin(3)
				renderColor(RenderColor)
				renderVertex(CentralPosX-140, PosY-9)
				renderVertex(CentralPosX-140, PosY+4)
				renderVertex(CentralPosX-50, PosY-6)
				renderEnd()
				
				renderBegin(3)
				renderColor(RenderColor)
				renderVertex(CentralPosX+150, PosY-9)
				renderVertex(CentralPosX+150, PosY+4)
				renderVertex(CentralPosX+60, PosY-6)
				renderEnd()
			end
		end
		ITRi = ITRi + 150
	end
	ITRi = -60
	itt = 0
	while ITRi > -1020 do---3300 do
		PosY = CentralPosY+ITRi+OffcetY-60
		if PosY < 850 and PosY > 300 then 
			itt = itt + 10
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX-160, PosY-5, RenderColor, false) 
			renderFontDrawText(Text_FontLow, string.format("%i", itt), CentralPosX+160, PosY-5, RenderColor, false) 
			if PosY < 850 and PosY > 300 then 
				
				renderBegin(3)
				renderColor(RenderColor)
				renderVertex(CentralPosX-140, PosY+7)
				renderVertex(CentralPosX-140, PosY-8)
				renderVertex(CentralPosX-50, PosY+4)
				renderEnd()
				
				renderBegin(3)
				renderColor(RenderColor)
				renderVertex(CentralPosX+150, PosY+7)
				renderVertex(CentralPosX+150, PosY-8)
				renderVertex(CentralPosX+60, PosY+4)
				renderEnd()
			end
		end
		ITRi = ITRi - 120
	end
end

function UpdateLinesRU(vehID)
	local vY = getCarPitch(vehID)-2.5
	local vR = getCarRoll(vehID)
	
	if math.abs(vY) > 180 then vY =  vY - 360 end
	if vR < 0 then vR = 360+vR end
	vR = -1 * vR
	
	local posX1, posY1, posX2, posY2, posX3, posY3, posX4, posY4, posX5, posY5
	
	renderBegin(2)--Up line
  	renderColor(RenderColor)
  	renderVertex(CentralPosX, CentralPosY-70)
  	renderVertex(CentralPosX, CentralPosY-65)
  	renderEnd()
  	
  	renderBegin(2)--Speed line
  	renderVertex(CentralPosX-200, CentralPosY-121)
  	renderVertex(CentralPosX-150, CentralPosY-121)
	renderEnd()
	
	renderBegin(3)--Left line
  	renderColor(RenderColor)
  	
  	posX1, posY1 = UpdateLinesRU_CalcAnglePos(vR-180, 20)
  	posX2, posY2 = UpdateLinesRU_CalcAnglePos(vR-180, 40)
  	posX3, posY3 = UpdateLinesRU_CalcAnglePos(vR-190, 50)
  	posX4, posY4 = UpdateLinesRU_CalcAnglePos(vR-180, 60)
  	posX5, posY5 = UpdateLinesRU_CalcAnglePos(vR-180, 100)
  	renderVertex(posX5, posY5)
  	renderVertex(posX4, posY4)
  	renderVertex(posX3, posY3)
  	renderVertex(posX2, posY2)
  	renderVertex(posX1, posY1)
	renderEnd()
	
	renderBegin(2)--Central line
  	posX1, posY1 = UpdateLinesRU_CalcAnglePos(vR-90, 30)
  	posX2, posY2 = UpdateLinesRU_CalcAnglePos(vR-90, 60)
  	renderVertex(posX2, posY2)
  	renderVertex(posX1, posY1)
	renderEnd()
	
	renderBegin(3)--Right line

  	posX1, posY1 = UpdateLinesRU_CalcAnglePos(vR, 20)
  	posX2, posY2 = UpdateLinesRU_CalcAnglePos(vR, 40)
  	posX3, posY3 = UpdateLinesRU_CalcAnglePos(vR+10, 50)
  	posX4, posY4 = UpdateLinesRU_CalcAnglePos(vR, 60)
  	posX5, posY5 = UpdateLinesRU_CalcAnglePos(vR, 100)
  	renderVertex(posX5, posY5)
  	renderVertex(posX4, posY4)
  	renderVertex(posX3, posY3)
  	renderVertex(posX2, posY2)
  	renderVertex(posX1, posY1)
	
	renderEnd()
	
	renderBegin(1)
		renderVertex(CentralPosX, CentralPosY)
	renderEnd()
	
	renderBegin(2)--Angle of roll (static)
  	renderColor(RenderColor)
  	posX1, posY1 = UpdateLinesRU_CalcAnglePos(0, 110)
  	posX3, posY3 = UpdateLinesRU_CalcAnglePos(0, 115)
  	posX2, posY2 = UpdateLinesRU_CalcAnglePos(-3, 120)
  	renderVertex(posX1, posY1)
  	renderVertex(posX3, posY3)
  	renderFontDrawText(Text_FontLowest, "0", posX2, posY2, RenderColor, false)
  	
  	posX1, posY1 = UpdateLinesRU_CalcAnglePos(180, 115)
  	posX2, posY2 = UpdateLinesRU_CalcAnglePos(180, 120)
  	posX3, posY3 = UpdateLinesRU_CalcAnglePos(183, 127)
  	renderVertex(posX1, posY1)
  	renderVertex(posX2, posY2)
  	renderFontDrawText(Text_FontLowest, "0", posX3, posY3, RenderColor, false)
  	
  	for i = 00, 180, 15 do
  		posX1, posY1 = UpdateLinesRU_CalcAnglePos(i, 110)
  		posX3, posY3 = UpdateLinesRU_CalcAnglePos(i, 115)
  		posX4, posY4 = UpdateLinesRU_CalcAnglePos(i, 100)
  		posX5, posY5 = UpdateLinesRU_CalcAnglePos(i, 100)
  		posX2, posY2 = UpdateLinesRU_CalcAnglePos(i, 120)
  		if i > 90 then 
  			if 180 - i > 25 and (i/10) == math.floor(i/10) then 
  				renderFontDrawText(Text_FontLowest, string.format("%i", 180 - i), posX2-5, posY2, RenderColor, false) 
  			end
  			if 180 - i == 30 then
  				renderVertex(posX3, posY3)
  				renderVertex(posX5, posY5)
  			elseif 180 - i == 60 then
  				renderVertex(posX3, posY3)
  				renderVertex(posX4, posY4)
  			elseif 180 - i ~= 180 then
  				renderVertex(posX1, posY1)
  				renderVertex(posX3, posY3)
  			end
  		else
  			if i > 25 and (i/10) == math.floor(i/10) then 
  				renderFontDrawText(Text_FontLowest, string.format("%i", i * -1), posX2-5, posY2, RenderColor, false) 
  			end
  			if i == 30 then
  				renderVertex(posX3, posY3)
  				renderVertex(posX5, posY5)
  			elseif i == 60 then
  				renderVertex(posX3, posY3)
  				renderVertex(posX4, posY4)
  			elseif i == 90 then
  				renderVertex(posX1, posY1)
  				renderVertex(posX3, posY3)
  			else
  				renderVertex(posX1, posY1)
  				renderVertex(posX3, posY3)
  			end
  		end
  	end
	renderEnd()
	UpdateLines2RU(vehID)
end

function UpdateLines2RU(vehID)
	local vY = getCarPitch(vehID)-2.5
	local vR = getCarRoll(vehID)
	local vH = getCarHeading(vehID)
	local screenResX, screenResY = getScreenResolution()
	--AGTargetingRender(vehID, 0)-------------------------AG Targeting System
	
	if math.abs(vY) > 180 then vY =  vY - 360 end
	if math.abs(vR) > 90 then 
		if vY > 90 then 
			vY = 180 - vY
		elseif vY < -90 then
				vY = (vY + 180)*-1
		end
	end
	OffcetY = vY*10
	local PosY
	
	PosY = CentralPosY+OffcetY+20

	if PosY < screenResY*0.6 and PosY > screenResY*0.4 then 
		renderDrawLine(CentralPosX+120, PosY, CentralPosX+150, PosY, 1, RenderColor)
		renderDrawLine(CentralPosX-150, PosY, CentralPosX-120, PosY, 1, RenderColor)
	end

	local ITRi = -12
	local long = 0
	
	local oHeading
	local wPosX, wPosY, wPosZ
	local Angle
	local rHeading = -370
	
	for i = -90, 90, 10 do
		local posRoll = i - vY
		posX1 = CentralPosX + 140
		posY1 = CentralPosY - 8 - posRoll

		if (i/20) - math.floor(i/20) == 0 then
			posX2 = CentralPosX + 130
		else
			posX2 = CentralPosX + 135
		end
		
		if posY1 < screenResY * 0.4 then 
			local nPos = screenResY * 0.4 - posX1
			posY1 = screenResY * 0.6 - nPos
		elseif posY1 > screenResY * 0.6 then 
			local nPos = posY1 - screenResY * 0.6
			posY1 = screenResY * 0.4 + nPos
		end
		posY2 = posY1

		if posY1 > screenResY * 0.4 and posY1 < screenResY * 0.6 then
			renderBegin(2)
			renderColor(RenderColor)
			renderVertex(posX1, posY1)
			renderVertex(posX2, posY2)
			renderEnd()
			if (i/15) - math.floor(i/15) == 0 then 
				local txt = string.format("%i", i)
				local textSize = renderGetFontDrawTextLength(Text_FontLowest, txt)
				renderFontDrawText(Text_FontLowest, txt, posX1+10, posY1+5, RenderColor, false) 
			end
		end
	end
	
	renderBegin(4)
	
  	renderColor(RenderColor)
  	renderVertex(CentralPosX + 157, CentralPosY)
  	renderVertex(CentralPosX + 170, CentralPosY - 3)
  	renderVertex(CentralPosX + 170, CentralPosY + 3)
  	
  	renderVertex(CentralPosX, CentralPosY - 125)
  	renderVertex(CentralPosX + 3, CentralPosY - 115)
  	renderVertex(CentralPosX - 3, CentralPosY - 115)
	renderEnd()

	if PPMCur > 0 then
		RenderTargetLineHorizontalRU(vehID, PPMX[PPMCur], PPMY[PPMCur], PPMZ[PPMCur], 0xFFAA0000)
	end
end

function RenderTargetLineHorizontalRU(vehID, tPosX, tPosY, tPosZ, rColor)
	local vHeading = 360-getCarHeading(vehID)
	local posX1, posY1, posX2, posY2
	local vPosX, vPosY, vPosZ = getCarCoordinates(vehID)
	local dist = math.abs(getDistanceBetweenCoords3d(vPosX, vPosY, vPosZ, tPosX, tPosY, tPosZ))
	local wPosX, wPosY, wPosZ = getOffsetFromCarInWorldCoords(vehID, 0, dist, 0)
	local Angle = SPO_CheckAngle2(vPosX, vPosY, wPosX, wPosY, tPosX, tPosY)
	local rHeading = vHeading + Angle
	if rHeading > 360 then rHeading = math.abs(360 - rHeading) end
	local anglePitch = (tPosZ - vPosZ) * 0.1
	
	posX1 = CentralPosX + Angle
	
	posY1 = CentralPosY - 130
	posY2 = CentralPosY - 120
	
	if posX1 < CentralPosX - 180 then 
		local nPos = (CentralPosX - 180) - posX1
		posX1 = (CentralPosX + 180) - nPos
	elseif posX1 > CentralPosX + 180 then 
		local nPos = posX1 - (CentralPosX + 180)
		posX1 = (CentralPosX - 180) + nPos
	end
	posX2 = posX1
	if posX1 > CentralPosX - 140 and posX1 < CentralPosX + 140 then
		renderBegin(2)
  		renderColor(rColor)
  		renderVertex(posX1, posY1)
  		renderVertex(posX2, posY2)
  		renderVertex(CentralPosX + 135, CentralPosY - anglePitch)
  		renderVertex(CentralPosX + 150, CentralPosY - anglePitch)
		renderEnd()
		txt = string.format("%i", rHeading)
		local textSize = renderGetFontDrawTextLength(Text_FontLowest, txt)
		renderFontDrawText(Text_FontLowest, txt, posX1-(textSize/2), posY1 - 10, rColor, false)
		renderFontDrawText(Text_FontLowest, string.format("%i(м)", tPosZ - vPosZ), CentralPosX + 155, CentralPosY - 5 - anglePitch, rColor, false)
	end
	if math.abs(vHeading - rHeading) > 120 then
		if Angle < 180 then
			renderFontDrawText(Text_FontMain, ">", CentralPosX + 110, CentralPosY - 110, rColor, false)
		else
			renderFontDrawText(Text_FontMain, "<", CentralPosX - 130, CentralPosY - 110, rColor, false)
		end
	end
end

function RenderLinesHorizontalRU(vHdng)
	local posX1, posY1, posX2, posY2, posX3, posY3
	local posHdng
	
	for i = 0, 360, 15 do
		posHdng = i - vHdng
		posX1 = CentralPosX + posHdng

		posY1 = CentralPosY - 130
		if (i/30) - math.floor(i/30) == 0 then
			posY2 = CentralPosY - 120
			if i == 90 then posY2 = CentralPosY - 115
			elseif i == 180 then posY2 = CentralPosY - 115
			elseif i == 270 then posY2 = CentralPosY - 115
			elseif i == 360 then posY2 = CentralPosY - 115
			end
		else
			posY2 = CentralPosY - 125
		end
		
		if posX1 < CentralPosX - 180 then 
			local nPos = (CentralPosX - 180) - posX1
			posX1 = (CentralPosX + 180) - nPos
		elseif posX1 > CentralPosX + 180 then 
			local nPos = posX1 - (CentralPosX + 180)
			posX1 = (CentralPosX - 180) + nPos
		end
		posX2 = posX1
		if posX1 > CentralPosX - 140 and posX1 < CentralPosX + 140 then
			renderBegin(2)
  			renderColor(RenderColor)
  			renderVertex(posX1, posY1)
  			renderVertex(posX2, posY2)
  			
  			if (i/30) - math.floor(i/30) == 0 then 
  				local txt
  				if i == 90 then txt = "В"
  				elseif i == 180 then txt = "Ю"
  				elseif i == 270 then txt = "З"
  				elseif i == 360 then txt = "С"
  				else txt = string.format("%i", i)
  				end
  				local textSize = renderGetFontDrawTextLength(Text_FontLowest, txt)
  				renderFontDrawText(Text_FontLowest, txt, posX1-(textSize/2), posY1 - 10, RenderColor, false) 
  			end
      renderEnd()
		end
	end
end

function UpdatePlaneRTextLines2RU(vY, vR)
	PosY = CentralPosY+OffcetY+10
	local itt = 0
	local screenResX, screenResY = getScreenResolution()
	if PosY < screenResY*0.6 and PosY > screenResY*0.4 then 
		renderFontDrawText(Text_FontLowest, string.format("%i", itt), CentralPosX+160, PosY, RenderColor, false) 
	end
	local ITRi = 40
	while ITRi < 6600  do
		PosY = CentralPosY+ITRi+OffcetY+20
		if PosY < screenResY*0.6 and PosY > screenResY*0.4 then 
			itt = itt - 5
			renderFontDrawText(Text_FontLowest, string.format("%i", itt), CentralPosX+150, PosY, RenderColor, false) 
		end
		ITRi = ITRi + 60
	end
	ITRi = -60
	itt = 0
	while ITRi > -6600 do
		PosY = CentralPosY+ITRi+OffcetY+20
		if PosY < screenResY*0.6 and PosY > screenResY*0.4 then 
			itt = itt + 5
			renderFontDrawText(Text_FontLowest, string.format("%i", itt), CentralPosX+150, PosY, RenderColor, false) 
		end
		ITRi = ITRi - 60
	end
end

function UpdateLinesRU_CalcAnglePos(angle, radius)
	local wX, wY
	wX = CentralPosX + radius * math.cos(math.rad(angle))
	wY = CentralPosY + radius * math.sin(math.rad(angle))
	return wX, wY
end

function UpdateLinesRU_CalcAnglePosCent(angle, radius, cPosX, cPosY)
	local wX, wY
	wX = cPosX + radius * math.cos(math.rad(angle))
	wY = cPosY + radius * math.sin(math.rad(angle))
	return wX, wY
end
function UpdateLinesRU_CalcAnglePos2(angle, radius, cPosX, cPosY)
	local wX, wY
	wX = cPosX + radius * math.cos(math.rad(angle))
	wY = cPosY + radius * math.atan(math.rad(angle))
	return wX, wY
end

function UpdateVHeight(hSpd)
	if hSpd > 20 then
		if hSpd > 50 then
			renderDrawTexture(hud_out3, CentralPosX+210, CentralPosY-50, 30, 40, 0, RenderColor)
		else
			renderDrawTexture(hud_out2, CentralPosX+210, CentralPosY-50, 30, 40, 0, RenderColor)
		end
	elseif hSpd > 0 then
		renderDrawTexture(hud_out1, CentralPosX+210, CentralPosY-50, 30, 40, 0, RenderColor)
	elseif hSpd > -20 then
			renderDrawTexture(hud_out1, CentralPosX+210, CentralPosY, 30, 40, 180, RenderColor)
	elseif hSpd > - 50 then
		renderDrawTexture(hud_out2, CentralPosX+210, CentralPosY, 30, 40, 180, RenderColor)
	else
		renderDrawTexture(hud_out3, CentralPosX+210, CentralPosY, 30, 40, 180, RenderColor)
	end
end

function UpdateVHeightRU(hSpd)
	local posX1, posY1, posX2, posY2, posX3, posY3, posX4, posY4
	for i = 90, 270, 30 do
		posX1, posY1 = UpdateLinesRU_CalcAnglePosCent(i, 30, CentralPosX + 250, CentralPosY + 10)
		posX2, posY2 = UpdateLinesRU_CalcAnglePosCent(i, 33, CentralPosX + 250, CentralPosY + 10)
		posX3, posY3 = UpdateLinesRU_CalcAnglePosCent(i, 45, CentralPosX + 250, CentralPosY + 10)
		renderBegin(2)
  		renderColor(RenderColor)
  		renderVertex(posX1, posY1)
  		renderVertex(posX2, posY2)
  		local val = (i-180)/10
  		if val == 0 then
  			renderFontDrawText(Text_FontLowest, string.format("%i", val), posX3, posY3, RenderColor, false)
  		else
  			renderFontDrawText(Text_FontLowest, string.format("%i", (val*2)-(val*0.3)), posX3, posY3, RenderColor, false)
  		end
		renderEnd()
	end
	local iSpd
	if math.abs(hSpd) > 15 then 
		if hSpd > 0 then iSpd = 15
		else iSpd = -15 
		end
	else
		iSpd = hSpd
	end
	posX1, posY1 = UpdateLinesRU_CalcAnglePosCent((iSpd*6)+180, 30, CentralPosX + 250, CentralPosY + 10)
	renderBegin(2)
  	renderVertex(posX1, posY1)
  	renderVertex(CentralPosX + 250, CentralPosY + 10)
	renderEnd()
end

function UpdateAFT(vehID)
	local GStatus = getPlaneUndercarriagePosition(vehID)
	if GStatus > 0 then
		renderDrawTexture(hud_aft, CentralPosX-280, CentralPosY-50, 50, 15, 0, RenderColor)
	else
		
	end
end

function UpdateGEAR(vehID)
	local GStatus = getPlaneUndercarriagePosition(vehID)
	if GStatus > 0 then 
		
	else
		if Lang_Eng then 
			renderFontDrawText(Text_FontMedium, "Gear Down", CentralPosX + 235, CentralPosY - 55, RenderColor, false) 
		else
			renderFontDrawText(Text_FontLow, "Шасси выпущ.", CentralPosX - 40, CentralPosY + 50, RenderColor, false) 
		end
	end
end

function UpdateRadio()
	if not(settings.maincfg.IsRadioEnabled) then
		local RC = getRadioChannel()
		if not(RC == 12) then
			local memory = require 'memory'
			setRadioChannel(12)
		end
	end
end

function UpdateTimers()
	if (os.clock() - AudioTimer) > AudioMax then
		AudioTimer = os.clock()--socket.gettime()
		IsAudioAvaliable = true
	else
	end
end

function MainMenu_CMD()
	MainWindow.v = not MainWindow.v
	imgui.ShowCursor = MainWindow.v
	imgui.Process = MainWindow.v
end
function EditFP_CMD()

end

function ResetAudioTimer()
	AudioTimer = os.clock()
end


--------------------------------------------------------------------------------------------#region TARGET RENDERING SYSTEM
function CheckTargets(vehID)
	if IsRadarEnabled then 
		GetAllVehPos(vehID)	
		GetAllPedPos(vehID)
	end
end

function GetAllVehPos(vehID)
	local AllVeh = getAllVehicles()
	local data = GetVehicleData(vehID)
	for i, v in ipairs(AllVeh) do
		GetVehPos(data, v)
	end
end

function GetAllPedPos(vehID)
	local AllPed = getAllChars()
	local data = GetCharData(PLAYER_PED)
	for i, v in ipairs(AllPed) do
		GetCharPos(data, v)
	end
end

function GetVehicleData(vehID)
	local PPosX, PPosY, PPosZ = getCarCoordinates(vehID)
	local VPosX, VPosY, VPosZ = getCarSpeedVector(vehID)
	VPosX = VPosX-PPosX
	VPosY = VPosY-PPosY
	VPosZ = VPosZ-PPosZ
	local data = 
	{
		position = {
			x = PPosX, 
			y = PPosY, 
			z = PPosZ
		},
		speedVector = {
			x = VPosX,
			y = VPosY,
			z = VPosZ
		},
		roll = getCarRoll(vehID),
		pitch = getCarPitch(vehID),
		heading = getCarHeading(vehID)
	}
	return data
end

function GetCharData(charID)
	local PPosX, PPosY, PPosZ
	local VPosX, VPosY, VPosZ
	if  isCharInAnyCar(charID) then
		local CharCar = storeCarCharIsInNoSave(PLAYER_PED)
		PPosX, PPosY, PPosZ = getCarCoordinates(CharCar)
		VPosX, VPosY, VPosZ = getCarSpeedVector(CharCar)
	else
		PPosX, PPosY, PPosZ = getCharCoordinates(charID)
		VPosX, VPosY, VPosZ = getCharSpeed(charID)
	end
	VPosX = VPosX-PPosX
	VPosY = VPosY-PPosY
	VPosZ = VPosZ-PPosZ
	local data = 
	{
		id = charID,
		position = {
			x = PPosX, 
			y = PPosY, 
			z = PPosZ
		},
		speedVector = {
			x = VPosX,
			y = VPosY,
			z = VPosZ
		},
	}
	return data
end

function IsPlayersVehicle(vehid)
	local playerVeh = storeCarCharIsInNoSave(PLAYER_PED)
	if playerVeh == vehid then return true
	else return false
	end
end

function GetCharPos(playerData, charID)
	if isCharInAnyCar(charID) then return end
	if settings.maincfg.AvionicsMode == 2 and settings.maincfg.IsShowInfantry then
		local posX, posY, posZ = getCharCoordinates(charID)
		if  not isPointOnScreen(posX, posY, posZ, 3) then return end
		if IsTargetNoCollision(
				playerData.position.x,
				playerData.position.y,
				playerData.position.z,
				posX,
				posY,
				posZ)
		and getDistanceBetweenCoords3d(
				playerData.position.x,
				playerData.position.y,
				playerData.position.z,
				posX,
				posY,
				posZ) < 230
		then
			local isPlayerOK, playerID = sampGetPlayerIdByCharHandle(charID)
			if isPlayerOK then 
				TriangleRendering(playerID, posX, posY, posZ, RenderColor)
			else
				TriangleRendering(posX, posY, posZ, RenderColor)
			end
		end
	end
end

function GetVehPos(playerData, vehicle)
	if not doesVehicleExist(vehicle) then return end
	if IsPlayersVehicle(vehicle) then return end
	if vehicle == vehID then return end
	local cvID, modelID
	cvID = sampGetVehicleIdByCarHandle(vehicle)
	PosX,PosY,PosZ = getCarCoordinates(vehicle)
	RotX = getCarRoll(vehicle)
	RotY = getCarPitch(vehicle)
	RotZ = getCarHeading(vehicle)
	modelID = getCarModel(vehicle)
	if settings.maincfg.AvionicsMode == 0 then
	
	elseif settings.maincfg.AvionicsMode == 1 then
		if not IsRenderNeededAA(modelID) then return end
		if IsTargetAspectOK(
							vehicle, 
							playerData.speedVector.x, 
							playerData.speedVector.y, 
							PosX, 
							PosY) 
			and IsTargetNoCollision(
							playerData.position.x, 
							playerData.position.y, 
							playerData.position.z, 
							PosX, 
							PosY, 
							PosZ) 
			then
			ObjectRendering(PosX, PosY, PosZ, RenderColor)
			ShowTextOnRadar("[T]", PosX, PosY, PosZ)
		end
	elseif settings.maincfg.AvionicsMode == 2 then
		if not IsRenderNeededAG(modelID) then return end
		if IsTargetAspectOK(
							vehicle, 
							playerData.speedVector.x, 
							playerData.speedVector.y, 
							PosX, 
							PosY) 
			and IsTargetNoCollision(
							playerData.position.x, 
							playerData.position.y, 
							playerData.position.z, 
							PosX, 
							PosY, 
							PosZ) 
			then
			ObjectRendering(PosX, PosY, PosZ, RenderColor)
			ShowTextOnRadar("[T]", PosX, PosY, PosZ)
		end
	end
end

function IsRenderNeededAA(modelID)
	if isThisModelAPlane(modelID) or isThisModelAHeli(modelID) then
		return true
	else
		return false
	end
end

function IsRenderNeededAG(modelID)
	if isThisModelACar(modelID) or isThisModelABoat(modelID) then
		return true
	else 
		return false
	end
end

function IsTargetAspectOK(vehID, PosX, PosY, TPosX, TPosY)
	local angle =  getAngleBetween2dVectors(PosX, PosY, TPosX, TPosY)
	if (angle < 179) and isCarOnScreen(vehID) then
		return true
	else 
		return false
	end
end

function IsTargetNoCollision(PPosX, PPosY, PPosZ, TPosX, TPosY, TPosZ)
	local IsClear = isLineOfSightClear(PPosX, PPosY, PPosZ, TPosX, TPosY, TPosZ, true, false, false, true, false)
	if IsClear then--IsRes then 
		return true
	else
		return false
	end
end

function ObjectRendering(PosX, PosY, PosZ, Color)
	local sX, sY = convert3DCoordsToScreen(PosX, PosY, PosZ)
	if Lang_Eng then
		renderRomb(sX, sY, 10, Color)
	else
		renderCircle(sX, sY, 10, Color)
	end
end

function TriangleRendering(PosX, PosY, PosZ, Color)
	local sX, sY = convert3DCoordsToScreen(PosX, PosY, PosZ)
	renderTriangle(sX, sY, 5, Color)
end

function TriangleRendering(elementNumber, PosX, PosY, PosZ, Color)
	local sX, sY = convert3DCoordsToScreen(PosX, PosY, PosZ)
	renderFontDrawText(Text_FontLowest, string.format("%d", elementNumber), sX - 3, sY + 5, Color, false)
	renderTriangle(sX, sY, 3, Color)
end

function TargetRendering(PosX, PosY, PosZ)

end

function renderCircle(screenX, screenY, radius, color)
	renderBegin(3)--deltaSpeed arrow
	renderColor(color)

	for j = -25, 359, 25 do
		local tX, tY = calcRadiusPos({x=screenX, y=screenY}, j, radius)
		renderVertex(tX, tY)
	end
	renderEnd()
end

function renderTriangle(screenX, screenY, size, color)
	renderBegin(3)
	renderColor(color)
	
	renderVertex(screenX - size, screenY - size)
	renderVertex(screenX, screenY + size)
	renderVertex(screenX + size, screenY - size)
	renderVertex(screenX - size, screenY - size)
	
	renderEnd()
end

function renderSquare(screenX, screenY, size, color)
	renderBegin(3)
	renderColor(color)
	renderVertex(screenX - size, screenY - size)
	renderVertex(screenX - size, screenY + size)
	renderVertex(screenX + size, screenY + size)
	renderVertex(screenX + size, screenY - size)
	renderVertex(screenX - size, screenY - size)
	
	renderEnd()
end

function renderRomb(screenX, screenY, size, color)
	renderBegin(3)
	renderColor(color)
	renderVertex(screenX - size, screenY)
	renderVertex(screenX, screenY + size)
	renderVertex(screenX + size, screenY)
	renderVertex(screenX, screenY - size)
	renderVertex(screenX - size, screenY)
	
	renderEnd()
end

function calcRadiusPos(pos, angle, radius)
	local wX, wY
	wX = pos.x + radius * math.cos(math.rad(angle))
	wY = pos.y + radius * math.sin(math.rad(angle))
	return wX, wY
end

---------------------------------------------------------------------------------------------#region AG TARGETING SYSTEM

function AGTargetingRender(vehID, bombCruizeSpeed)
	if not settings.maincfg.IsBallisticBombRender then return end
	local AZ = 360 - getCarHeading(vehID)
	local bombSpeed = getCarSpeed(vehID)
	if Lang_Eng then
		bombSpeed = bombSpeed * settings.maincfg.BombBallisticEN--bombSpeed * 1.210
	else
		bombSpeed = bombSpeed * settings.maincfg.BombBallisticRU--bombSpeed * 1.395--1.395RUS--1.45
	end
	bombCruizeSpeed = bombSpeed --* 1.7
	
	local bombPitch = getCarPitch(vehID)
	if bombPitch > 180 then bombPitch = bombPitch-360 end
	if math.abs(bombPitch) > 90 then 
		if bombPitch > 90 then 
			bombPitch = math.abs(bombPitch) - 180 
		else 
			if bombPitch < -90 then
				bombPitch = (bombPitch + 180)*-1
			end
		end
	end
	local dropPitch = bombPitch
	
	local posX, posY, posZ = getCarCoordinates(vehID)
	local spdVecX, spdVecY, spdVecZ = getCarSpeedVector(vehID)
	
	spdVecX = posX + spdVecX
	spdVecY = posY + spdVecY
	spdVecZ = posZ + spdVecZ
	
	local targetX, targetY, targetZ = posX, posY, posZ
	local i = 0
	local V0x, projectionXt
	
	local lineColor = RenderColor
	
	local lineX, lineY, lineZ = posX, posY, posZ
	while (targetZ > getGroundZFor3dCoord(targetX, targetY, targetZ+0.5)+1 and targetZ > -20 and i < 400) do
		i = i + 0.1
		bombPitch = math.atan2(bombSpeed, bombCruizeSpeed)
		bombSpeed = bombSpeed - 9.81
		targetZ = posZ + ((bombSpeed * math.sin(math.rad(-dropPitch)) - ((9.81 * math.pow(i, 2))/2)))
		
		V0x = math.cos(math.rad(dropPitch)) * bombCruizeSpeed--dropPitch
		projectionXt = V0x * i
		
		targetX = posX + math.sin(math.rad(AZ)) * projectionXt
 		targetY = posY + math.cos(math.rad(AZ)) * projectionXt
		
		local dist = getDistanceBetweenCoords2d(posX, posY, targetX, targetY) - 500
		
		if (i > 1.5) then
			local isVisiblePoint = isLineOfSightClear(posx, posY, posZ, targetX, targetY, targetZ, true, false, false, false, false)
			if (not isVisiblePoint) then 
				lineColor = 0xFFAAAAAA--0xFFAAAAAA 
			elseif bombCruizeSpeed > 0.5 and isPointOnScreen(targetX, targetY, targetZ, dist > 0 and dist or 5) then
				local sX, sY = convert3DCoordsToScreen(lineX, lineY, lineZ)
				local tX, tY = convert3DCoordsToScreen(targetX, targetY, targetZ)
				lineColor = RenderColor
				renderDrawLine(tX, tY, sX, sY, 1, RenderColor) 
			else
				lineColor = 0xFFFF0000
			end
		end
		lineX, lineY, lineZ = targetX, targetY, targetZ
	end
	local distance = getDistanceBetweenCoords3d(posX, posY, posZ, targetX, targetY, targetZ) * 0.001
	render_text(Text_FontLow, string.format("Дальность(пуск):%.2fкм", distance), CentralPosX-80, CentralPosY+210, RenderColor, 1, 0xFF000000, false)
	
	if not isPointOnScreen(targetX,targetY, targetZ, distance > 500 and distance - 500 or 5) then return end
	
	ObjectRendering(targetX, targetY, targetZ, lineColor)
end

function AGTargetingRender_Gun(vehID)
	if not settings.maincfg.IsBallisticGunRender then return end
	local rightPosition = {x, y, z}
	local leftPosition = {x, y, z}
	local rightPositionEnd = {x, y, z}
	local leftPositionEnd = {x, y, z}
	local vehiclePosition = {x, y, z}
	vehiclePosition.x, vehiclePosition.y, vehiclePosition.z = getOffsetFromCarInWorldCoords(vehID, 0, 20, 0)
	
	local additionalPos = {x = 1.5, y = 0}
	
	rightPosition.x, rightPosition.y, rightPosition.z = getOffsetFromCarInWorldCoords(vehID, 0, 250, 0)
	local isCollision, collisionInfo = processLineOfSight(
		vehiclePosition.x, 
		vehiclePosition.y, 
		vehiclePosition.z, 
		rightPosition.x, 
		rightPosition.y, 
		rightPosition.z, 
		true, 
		true, 
		false, 
		true, 
		false)
	if isCollision then
		local distance = getDistanceBetweenCoords3d(vehiclePosition.x, vehiclePosition.y, vehiclePosition.z, collisionInfo.pos[1], collisionInfo.pos[2], collisionInfo.pos[3])
		if distance > 80 then
			render_text(Text_FontMain, string.format("ПР", collisionInfo.entityType), CentralPosX - 15, CentralPosY + 200, RenderColor, 1, 0xFF000000, false)
			if IsAudioAvaliable and (os.clock() - AudioLaunchAuthorizedTime) > 20 then 
				setAudioStreamState(audio_launch, as_action.PLAY)
				IsAudioAvaliable = false
				AudioLaunchAuthorizedTime = os.clock()
				ResetAudioTimer()				
			end
		else
			render_text(Text_FontMain, string.format("ОТВ", collisionInfo.entityType), CentralPosX - 20, CentralPosY + 200, RenderColor, 1, 0xFF000000, false)
		end
		render_text(Text_FontMedium, string.format("дст: %.3d (м)", distance), CentralPosX - 30, CentralPosY + 230, distance > 80 and RenderColor or 0xFFFF0000, 1, 0xFF000000, false)
	end
	AGRenderBallisticHistory(vehID, vehiclePosition)

	rightPosition.x, rightPosition.y, rightPosition.z = getOffsetFromCarInWorldCoords(vehID, additionalPos.x + 0.7, 30, 0)
	leftPosition.x, leftPosition.y, leftPosition.z = getOffsetFromCarInWorldCoords(vehID, -additionalPos.x - 0.7, 30, 0)

	for i = 50, 120, 10 do
		if (additionalPos.x > 0.4) then 
			additionalPos.x = math.cos(additionalPos.y) - (0.009 * i)
			additionalPos.y = additionalPos.y < 1 and additionalPos.y + (0.005 * i) or 0.01
		end
		
		rightPositionEnd.x, rightPositionEnd.y, rightPositionEnd.z = getOffsetFromCarInWorldCoords(vehID, additionalPos.x, i, 0)
		leftPositionEnd.x, leftPositionEnd.y, leftPositionEnd.z = getOffsetFromCarInWorldCoords(vehID, -additionalPos.x, i, 0)
		
		AGRenderLine(rightPosition, rightPositionEnd, vehiclePosition, RenderColor)
		AGRenderLine(leftPosition, leftPositionEnd, vehiclePosition, RenderColor)
		
		rightPosition.x = rightPositionEnd.x
		rightPosition.y = rightPositionEnd.y
		rightPosition.z = rightPositionEnd.z
		leftPosition.x = leftPositionEnd.x
		leftPosition.y = leftPositionEnd.y
		leftPosition.z = leftPositionEnd.z
			
	end
end

function AGRenderBallisticHistory(vehID, viewerPos)
	for i = 1, 4 do
		AGRenderLine(BallisticHistory[i], BallisticHistory[i + 1], viewerPos, RenderColor)
	end
	BallisticHistory[1].x = BallisticHistory[2].x
	BallisticHistory[1].y = BallisticHistory[2].y
	BallisticHistory[1].z = BallisticHistory[2].z
	
	BallisticHistory[2].x = BallisticHistory[3].x
	BallisticHistory[2].y = BallisticHistory[3].y
	BallisticHistory[2].z = BallisticHistory[3].z
	
	BallisticHistory[3].x = BallisticHistory[4].x
	BallisticHistory[3].y = BallisticHistory[4].y
	BallisticHistory[3].z = BallisticHistory[4].z
	
	BallisticHistory[4].x = BallisticHistory[5].x
	BallisticHistory[4].y = BallisticHistory[5].y
	BallisticHistory[4].z = BallisticHistory[5].z
	
	BallisticHistory[5].x, BallisticHistory[5].y, BallisticHistory[5].z = getOffsetFromCarInWorldCoords(vehID, 0, 121, 0)
end

function AGRenderLine(startPosition, endPosition, viewerPos, color)
	if (not isPointOnScreen(startPosition.x, startPosition.y, startPosition.z)) then return end
	if (not isPointOnScreen(endPosition.x, endPosition.y, endPosition.z)) then return end
	if (processLineOfSight(
		viewerPos.x, 
		viewerPos.y, 
		viewerPos.z, 
		endPosition.x, 
		endPosition.y, 
		endPosition.z, 
		true, 
		true, 
		false, 
		true, 
		false)) 
	then 
		return
	end
	local sX1, sY1 = convert3DCoordsToScreen(startPosition.x, startPosition.y, startPosition.z)
	local sX2, sY2 = convert3DCoordsToScreen(endPosition.x, endPosition.y, endPosition.z)
	renderDrawLine(sX1, sY1, sX2, sY2, 1, color)
end

---------------------------------------------------------------------------------------------#region CAMERA

function TogglePlaneCamera()
	local vehID = storeCarCharIsInNoSave(PLAYER_PED)
	
	if IsCameraMode then
		Cam_ReleaseCamera()
		IsCameraMode = false
		settings.maincfg.IsHUDEnabled = true
		Cam_TarX = -999
		Cam_TarY = -999
		Cam_TarZ = -999
	else
		Cam_AnimateCamera(vehID)
		IsCameraMode = true
		settings.maincfg.IsHUDEnabled = false
		Cam_Zoom = 70
	end
end

function Cam_AnimateCamera(vid)
	Cam_RenderCameraHUD()
end

function Cam_AttachCamera(vid, RotX, RotY, RotZ)
	local mmX, mmY = getPcMouseMovement()
	if not Cam_IsOnceAttached then 
		restoreCamera()
		attachCameraToVehicle(vid, 0, 0, -2, RotX, RotY, RotZ, 0, 1) 
		Cam_PrevRotX = RotX
		Cam_PrevRotY = RotZ
		Cam_IsOnceAttached = true 
	else
		if Cam_TarX == -999 and Cam_TarY == -999 and Cam_TarZ == -999 then
			if not (math.abs(mmX) < 1) or not (math.abs(mmY) < 1) then
				mmX = mmX/10
				mmY = mmY/10
    
				Cam_PrevRotX = Cam_PrevRotX+mmX
				Cam_PrevRotY = Cam_PrevRotY+mmY
    
				attachCameraToVehicle(vid, 0, 0, -2, Cam_PrevRotX, 90, Cam_PrevRotY, 1, 0)
			end
		else
			local psX, psY, psZ = getOffsetFromCarInWorldCoords(vid, 0, 0, -2)

			local pAngX = getAngleBetween2dVectors(psX, vsX, psX, Cam_TarX)
			local pAngY = getAngleBetween2dVectors(psY, vsY, psY, Cam_TarY)
			local pAngZ = getAngleBetween2dVectors(psZ, vsZ, psZ, Cam_TarZ)

			setFixedCameraPosition(psX, psY, psZ, -85, 90+getCarRoll(vid), 0)
			pointCameraAtPoint(Cam_TarX, Cam_TarY, Cam_TarZ, 2)
			loadScene(Cam_TarX, Cam_TarY, Cam_TarZ)
			
		end
		UpdateRotation(vid)
	end
end

function Cam_RenderCameraHUD()
	renderSquare(CentralPosX, CentralPosY, 100, RenderColor)
end

function Cam_UpdateCamera(vid)
	if not cameraIsVectorMoveRunning() then
		CheckTargetLock(vid)
		Cam_AttachCamera(vid, 0,180,-45)
		Cam_RenderCameraHUD()
		CheckCameraZoom2()
	end
end

function Cam_ReleaseCamera()
	setFixedCameraPosition(0,0,0,0,0,0)
	restoreCamera()
	Cam_IsOnceAttached = false
end

function Cam_CalcMovement()
	local mX, mY = getPcMouseMovement()
	mX = mX/-100
	mY = mY/100
	
	if mX > 360 then mX = 360 
		elseif mX < -360 then mX = -360
	end
	if mY > 90 then mY = 90
		elseif mY < -90 then mY = -90
	end
	Cam_PrevRotX = Cam_PrevRotX+mX
	Cam_PrevRotY = Cam_PrevRotY+mY
	if Cam_PrevRotX > 180 then Cam_PrevRotX = 180 
		elseif Cam_PrevRotX < -180 then Cam_PrevRotX = -180
	end
	if Cam_PrevRotY > 180 then Cam_PrevRotY = 180
		elseif Cam_PrevRotY < -180 then Cam_PrevRotY = -180
	end
	sampAddChatMessage(string.format(GetLocalizationMessage(126), Cam_PrevRotX, Cam_PrevRotY) ,0xFFFFFFFF)--{00A2FF}V{FFFFFF}ir{00A2FF}P{FFFFFF}i{00A2FF}L {FFFFFF}Avionics: Unfixed: %d 90 %d
	return Cam_PrevRotX, 90, Cam_PrevRotY
end

function Cam_RotateCamera(X, Y)
	setCameraPositionUnfixed(X, Y)
	sampAddChatMessage(string.format(GetLocalizationMessage(127), X, Y) ,0xFFFFFFFF)--{00A2FF}V{FFFFFF}ir{00A2FF}P{FFFFFF}i{00A2FF}L {FFFFFF}Avionics: Unfixed: %d %d
end

function CheckTargetLock(vid)
	if isKeyJustPressed(keys.VK_LBUTTON) and not(sampIsChatInputActive()) then 

		local sww, shh = getScreenResolution()
		local PPosX, PPosY, PPosZ = convertScreenCoordsToWorld3D(sww/2-40, shh/2-10, 5)
		local tPosX, tPosY, tPosZ = convertScreenCoordsToWorld3D(sww/2-40, shh/2-10, 2000)
		local RayRes, colPoint = processLineOfSight(PPosX, PPosY, PPosZ, tPosX, tPosY, tPosZ, true, true, true, true, false, true, false, true, false, true, false)
		if RayRes then
			if Cam_TarX == -999 and Cam_TarY == -999 and Cam_TarZ == -999 then
				Cam_TarX = colPoint.pos[1]
				Cam_TarY = colPoint.pos[2]
				Cam_TarZ = colPoint.pos[3]
				sampAddChatMessage(string.format(GetLocalizationMessage(128), Cam_TarX, Cam_TarY, Cam_TarZ) ,0xFFFFFFFF)--{00A2FF}V{FFFFFF}ir{00A2FF}P{FFFFFF}i{00A2FF}L {FFFFFF}Avionics: Камера зафиксирована на координатах: [%.2f;%.2f;%.2f]
			else
				Cam_IsOnceAttached = false
				Cam_TarX = -999
				Cam_TarY = -999
				Cam_TarZ = -999
			end
		else
			sampAddChatMessage(GetLocalizationMessage(129) ,0xFFFFFFFF)
		end
	elseif isKeyJustPressed(keys.VK_RBUTTON) and not(sampIsChatInputActive()) then 
		IsNightVis = not IsNightVis
		if IsNightVis then
			setInfraredVision(true)
		else
			setInfraredVision(false)
		end
	elseif isKeyJustPressed(keys.VK_MBUTTON) and not(sampIsChatInputActive()) then 
		Cam_IsOnceAttached = false
		Cam_TarX = -999
		Cam_TarY = -999
		Cam_TarZ = -999
	end
end

function CheckCameraZoom2()

	local IsChanged = false
	local delta = getMousewheelDelta()
	
	if math.abs(delta) > 0 then
		delta = delta*-10
		if Cam_Zoom+delta > 9 and Cam_Zoom+delta < 71 then Cam_Zoom = Cam_Zoom+delta IsChanged = true end
	else
		if isKeyJustPressed(keys.VK_OEM_PLUS) and not(sampIsChatInputActive()) then
			if Cam_Zoom-10 > 9 then IsChanged = true Cam_Zoom = Cam_Zoom-10 IsChanged = true end
		elseif isKeyJustPressed(keys.VK_OEM_MINUS) and not(sampIsChatInputActive()) then
			if Cam_Zoom+10 < 71 then IsChanged = true Cam_Zoom = Cam_Zoom+10 IsChanged = true  end
		end
	end
	
	local fov = getCameraFov()
	if IsChanged then 
		cameraSetLerpFov(fov, Cam_Zoom, settings.maincfg.ZoomFix, false)-------на 10 бывает loading, безопасное значение >100
		cameraPersistFov(true)
	end
	render_text(Text_FontLow, string.format("%s\n%s%d", GetLocalizationMessage(130), GetLocalizationMessage(131), (Cam_Zoom-70)*-1), CentralPosX-260, CentralPosY+150, RenderColor, 1, 0xFF000000, false)--Camera mode\nZoom: %i
end
---------------------------------------------------------------------------------------------#region MAGNETO

function ToggleHeliWinch()
	local vehID = storeCarCharIsInNoSave(PLAYER_PED)
	
	IsMagneto = not IsMagneto
	if IsMagneto then 
		attachWinchToHeli(vehID, true)
		ApplyPVOMove()
	else
		releaseEntityFromWinch(vehID)
		attachWinchToHeli(vehID, false)
		BanPVOMove()
	end
end

function ApplyPVOMove()
	local model
	for i,v in ipairs(getAllObjects()) do
		model = getObjectModel(v)
		if model == -1684 or model == -1671 then
			winchCanPickObjectUp(v, true)
			local r, ox, oy, oz = getObjectCoordinates(v)
			ObjectRendering(ox, oy, oz, 0xFF0000FF)
			print(v)
		end
	end
end

function BanPVOMove()
	local model
	for i,v in ipairs(getAllObjects()) do
		model = getObjectModel(v)
		if model == -1684 or model == -1671 then
			winchCanPickObjectUp(v, false)
		end
	end
end
---------------------------------------------------------------------------------------------#region TEXTDRAW GETINFO
function UpdateServerTDs(vehID)
	UpdateMarkers(vehID)
end

-------------------------------------------------------------------------------------#region MISSILE WARNING SYSTEM Система предупреждения о пуске

function SPOCheck(vehid)
	SPO_FindAndCheckObjects(vehid)
end

function SPO_FindAndCheckObjects(vehid)
	if not(settings.maincfg.IsSpoEnabled) then return end
	local objs = getAllObjects()
	local objModel
	local PosX, PosY, PosZ
	local vPosX, vPosY, vPosZ = getCarCoordinates(vehid)
	local vHeading = 360 - getCarHeading(vehid)
	local dist
	for i, v in ipairs(objs) do
		objModel = getObjectModel(v)
		if not (doesObjectExist(v)) then return end
		if SPO_IsMissile(objModel) and not isObjectAttached(v) then
			res, PosX, PosY, PosZ = getObjectCoordinates(v)
			oHeading = 360-getObjectHeading(v)
			dist = math.abs(getDistanceBetweenCoords3d(PosX, PosY, PosZ, vPosX, vPosY, vPosZ))
			if dist > 5 and dist < 700 then
				local spdVal = getCarSpeed(vehid)
				local wPosX, wPosY, wPosZ = getOffsetFromCarInWorldCoords(vehid, 0, dist, 0)
				local Angle = SPO_CheckAngle2(vPosX, vPosY, wPosX, wPosY, PosX, PosY)
				local rHeading = vHeading + Angle
				if rHeading > 360 then rHeading = math.abs(360 - rHeading) end
				SPO_PlaySound(Angle, vPosZ, PosZ, dist)
				ShowTextOnRadar("!M!", PosX, PosY, PosZ)
				
				 
				if Angle > 0 and Angle < 180 then
					if Lang_Eng then
						render_text(Text_FontLow, string.format("MISSILE: %.0f [%.0f] (DST: %.0f)", Angle, rHeading, dist), CentralPosX+62, CentralPosY-225, 0xFF000000, 1, RenderColor, false)
					else
						render_text(Text_FontLow, string.format("ПУСК: %.0f [%.0f] (Дист: %.0f)", Angle, rHeading, dist), CentralPosX+22, CentralPosY-180, 0xFF000000, 1, RenderColor, false)
					end
				else
					if Lang_Eng then
						render_text(Text_FontLow, string.format("MISSILE: %.0f [%.0f] (DST: %.0f)", Angle, rHeading, dist), CentralPosX-182, CentralPosY-225, 0xFF000000, 1, RenderColor, false)
					else
						render_text(Text_FontLow, string.format("ПУСК: %.0f [%.0f] (Дист: %.0f)", Angle, rHeading, dist), CentralPosX-192, CentralPosY-180, 0xFF000000, 1, RenderColor, false)
					end
				end
				if isObjectOnScreen(v) then
					SPO_RenderMissle(PosX, PosY, PosZ)
				end
			end
		end
	end
end

function SPO_IsMissile(objModel)
	if objModel == 345 then
		return true
	elseif objModel == -1225 then
		return true
	elseif objModel == -1230 then
		return true
	elseif objModel == -1232 then
		return true
	elseif objModel == -1238 then
		return true
	elseif objModel == -1328 then
		return true
	elseif objModel == -1615 then
		return true
	elseif objModel == -1872 then
		return true
	elseif objModel == -1315 then
		return true
	else 
		return false
	end
end

function SPO_CheckAngle2(vPosX, vPosY, wPosX, wPosY, rPosX, rPosY)
	local angXY1 = getHeadingFromVector2d(wPosX-vPosX, wPosY-vPosY)
	local angXY2 = getHeadingFromVector2d(rPosX-vPosX, rPosY-vPosY)
	local ResX = angXY1-angXY2
	if ResX < 0 then ResX = 360 + ResX end
	if ResX > 360 then ResX =  ResX - 180 end
	return ResX
end

function SPO_PlaySound(angle, vheight, mheight, dist)
	if not(settings.maincfg.IsSpoEnabled) then return end
	if IsAudioAvaliable then
		if settings.maincfg.IsAutoFlares and dist < 200 then SPO_DropFlares() end
		ResetAudioTimer()
		IsAudioAvaliable = false
		if (angle < 30 or angle > 330) then
			if vheight > mheight then
				--Впереди-ниже
				setAudioStreamState(audio_misfd, as_action.PLAY)
			else
				--Впереди выше
				setAudioStreamState(audio_misfu, as_action.PLAY)
			end
		elseif angle > 44 and angle < 135 then
			if vheight > mheight then
				--Справа ниже
				setAudioStreamState(audio_misrd, as_action.PLAY)
			else
				--Справа выше
				setAudioStreamState(audio_misru, as_action.PLAY)
			end
		elseif angle > 134 and angle < 225 then
			if vheight > mheight then 
				--Сзади ниже
				setAudioStreamState(audio_misbd, as_action.PLAY)
			else
				--Сзади выше
				setAudioStreamState(audio_misbu, as_action.PLAY)
			end
		elseif angle > 224 and angle < 316 then
			if vheight > mheight then
				--Слева ниже
				setAudioStreamState(audio_misld, as_action.PLAY)
			else
				--Слева выше
				setAudioStreamState(audio_mislu, as_action.PLAY)
			end
		else
		end
	end
end

function SPO_PlayThreatSound()
	if not(settings.maincfg.IsSpoEnabled) then return end
	if getAudioStreamState(audio_threat) == -1 then
		setAudioStreamState(audio_threat, as_action.PLAY)
	end
end

function SPO_RenderMissle(mPosX, mPosY, mPosZ)
	if not(settings.maincfg.IsSpoEnabled) then return end
	ObjectRendering(mPosX, mPosY, mPosZ, 0xFFFF0000)
end

function SPO_DropFlares()
	if not SPO_IsAutoFlaresKeyNeeded then
		SPO_IsAutoFlaresKeyNeeded = true
		setGameKeyState(18, 64)
	end
end

function sampev.onSendVehicleSync(data)
	if SPO_IsAutoFlaresKeyNeeded then
		SPO_IsAutoFlaresKeyNeeded = false
	end
end


----------------------------------------------------------------#region MODES Режимы

function UpdateStatusModed(vehID)
	if settings.maincfg.AvionicsMode == 0 then--0 - Навигация 1 - БВБ 2 - Земля 3 - ДВБ 4 - Посадка
		IsRadarEnabled = false
		if not(vehTarget == -1) then restoreTargetPlane() end
	elseif settings.maincfg.AvionicsMode == 1 then--БВБ
		UpdateTargets(vehID)
		IsRadarEnabled = true
	elseif settings.maincfg.AvionicsMode == 2 then--Земля
		if not(vehTarget == -1) then restoreTargetPlane() end
		IsRadarEnabled = true
		AGTargetingRender(vehID, bombCruizeSpeed)---Поддержка отрисовки
		AGTargetingRender_Gun(vehID)--Отрисовка трассеров
	elseif settings.maincfg.AvionicsMode == 3 then--ДВБ
		if not(vehTarget == -1) then restoreTargetPlane() end
		UpdateServerTDs(vehID)
		IsRadarEnabled = true
	elseif settings.maincfg.AvionicsMode == 4 then--ПОС
		if not(vehTarget == -1) then restoreTargetPlane() end
		IsRadarEnabled = false
	end
end

function AvionicsModeBindings(vehID)
	if isKeyJustPressed(settings.maincfg.PrevModeKey) and not(sampIsChatInputActive()) then
		AvionicsPrevMode()
	elseif isKeyJustPressed(settings.maincfg.NextModeKey) and not(sampIsChatInputActive()) then
		AvionicsNextMode()
	end
end

function AvionicsOtherBindings(vehID)
	if isKeyJustPressed(settings.maincfg.OpenMenuKey) and not(sampIsChatInputActive()) then
		MainMenu_CMD()
	end
end

function AvionicsNextMode()
	if settings.maincfg.AvionicsMode < 4 then
		settings.maincfg.AvionicsMode = settings.maincfg.AvionicsMode + 1
	else
		settings.maincfg.AvionicsMode = 0
	end
end

function AvionicsPrevMode()
	if settings.maincfg.AvionicsMode > 0 then
		settings.maincfg.AvionicsMode = settings.maincfg.AvionicsMode - 1
	else
		settings.maincfg.AvionicsMode = 4
	end
end

----------------------------------------------------------------#region BVR MODE Режим БВБ

function UpdateTargets(vehID)
	if vehTarget == -1 then
		getTargetPlane(vehID)
	else
		if doesVehicleExist(vehTarget) then
			RenderTargetPlane(vehID)
			TargetPlaneBinds()
		else
			restoreTargetPlane()
		end
	end
end

function getTargetPlane(vehID)
	local nVeh = getNearCarToCenter(radarSize)
	if not(doesVehicleExist(nVeh)) then return false end
	local nModel = getCarModel(nVeh)
	if isThisModelAPlane(nModel) or isThisModelAHeli(nModel) then
		local tPX, tPY, tPZ = getCarCoordinates(nVeh)
		local mPX, mPY, mPZ = getCarCoordinates(vehID)
		local IsClear = isLineOfSightClear(mPX, mPY, mPZ, tPX, tPY, tPZ, true, false, false, true, false)
		
		if IsClear then
			vehTarget = nVeh
			return true
		end
	else
		return false
	end
end

function getNearCarToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, car in ipairs(getAllVehicles()) do
		if not (doesVehicleExist(car)) then return end
        if isCarOnScreen(car) and getDriverOfCar(car) ~= playerPed then
            local carX, carY, carZ = getCarCoordinates(car)
            local cX, cY = convert3DCoordsToScreen(carX, carY, carZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, car})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end

function restoreTargetPlane()
	vehTarget = -1
end

function TargetPlaneBinds()
	if isKeyJustPressed(settings.maincfg.DropLockKey) and not(sampIsChatInputActive()) then 
		restoreTargetPlane()
	end
end

function RenderTargetPlane(vehID)
	if not(doesVehicleExist(vehTarget)) then return end
	local tModel = getCarModel(vehTarget)
	local tName = getNameOfVehicleModel(tModel)
	local tPX, tPY, tPZ = getCarCoordinates(vehTarget)
	local mPX, mPY, mPZ = getCarCoordinates(vehID)
	
	local tSpd = getCarSpeed(vehTarget)*2
	local mSpd = getCarSpeed(vehID)*2
	local tvX, tvY, tvZ = getCarSpeedVector(vehTarget)
	
	local tDst = math.abs(getDistanceBetweenCoords3d(mPX, mPY, mPZ, tPX, tPY, tPZ))
	
	local tOX, tOY, tOZ
	if tSpd < tDst then
		tOX, tOY, tOZ = getOffsetFromCarInWorldCoords(vehTarget, 0, tDst, 0)
	else
		local fSpd = tDst*0.75
		tOX, tOY, tOZ = getOffsetFromCarInWorldCoords(vehTarget, 0, tDst, 0)
	end
	local mOX, mOY, mOZ = getOffsetFromCarInWorldCoords(vehID, 0, tDst-10, 0)
	
	local WVX, WVY = convert3DCoordsToScreen(tOX, tOY, tOZ)
	local WX, WY = convert3DCoordsToScreen(tPX, tPY, tPZ)
	local WvecX, WvecY = convert3DCoordsToScreen(tvX+tPX, tvY+tPY, tvZ+tPZ)
	
	local tRZ = 360 - getCarHeading(vehTarget)
	local tAngle = SPO_CheckAngle2(mPX, mPY, mOX, mOY, tPX, tPY)
	local mAngle = SPO_CheckAngle2(tPX, tPY, tOX, tOY, mPX, mPY)
	local mRZ = 360 - getCarHeading(vehID)
	
	local rHeading = tAngle + mRZ
	if rHeading > 360 then rHeading = math.abs(360 - rHeading) end
	
	local tHeading = mAngle + tRZ
	if tHeading > 360 then tHeading = math.abs(360 - tHeading) end
	
	local cPX, cPY, cPZ = getActiveCameraCoordinates()
	local clPX, clPY, clPZ = getActiveCameraPointAt()
	local cAngle = SPO_CheckAngle2(cPX, cPY, clPX, clPY, tPX, tPY)
	
	local oRZ = rHeading - mRZ
	local toRZ = math.abs(tHeading - tRZ)
	
	local finalTargetHeading = mRZ + oRZ
	
	if toRZ > 320 or toRZ < 40 then 
		SPO_PlayThreatSound()
	end
	
	local mRoll = getCarRoll(vehTarget)
	local IsRes, colPoint = processLineOfSight(mPX, mPY, mPZ, tPX, tPY, tPZ, true, false, false, true, false, false, true, false)
		
	if not (IsRes) or (colPoint.entityType == 4) then--IsClear then
		if IsRes then
			local cObject = getObjectPointerHandle(colPoint.entity)
			local cModel = getObjectModel(cObject)
			if not((cModel == -1101) or (cModel == -1102) or isObjectAttached(cObject)) then
				restoreTargetPlane()
				return
			end
		elseif isCarOnScreen(vehTarget) then
			if Lang_Eng then
				renderDrawTexture(hud_lock, WX-25, WY-25, 50, 50, 0, RenderColor)
				renderRomb(WX, WY, 8, RenderColor)
				renderDrawTexture(hud_self, WVX, WVY, 15, 5, 180-mRoll, RenderColor)
				renderRomb(WVX, WVX, 8, RenderColor)
				renderDrawTexture(hud_vvec, WvecX, WvecY, 15, 15, 180, RenderColor)
				renderRomb(WvecX, WvecX, 8, RenderColor)
			
				render_text(Text_FontLow, string.format("%s\nSpd:%.0f\nAlt:%.0f\nDst%.1f", tName, tSpd, tPZ, tDst), WX, WY+50, RenderColor, 1, 0xFF000000, false)
			else
				renderCircle(WX, WY, 1, RenderColor)
				render_text(Text_FontLow, string.format("%s\nVц:%.0f\nHц:%.0f\nДист%.1f", tName, tSpd, tPZ, tDst), WX, WY+50, RenderColor, 1, 0xFF000000, false)
				renderDrawTexture(hud_self, WVX, WVY, 15, 5, 180-mRoll, RenderColor)
				renderDrawTexture(hud_vvec, WvecX, WvecY, 15, 15, 180, RenderColor)
			end
		end
		RenderTargetLineHorizontalRU(vehID, tPX, tPY, tPZ, 0xFFBB0000)
		if Lang_Eng then
			render_text(Text_FontLow, string.format("TRG: %s", tName), CentralPosX-260, CentralPosY+70, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("Roll: %.0f (deg)", mRoll), CentralPosX-260, CentralPosY+90, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("IT: %.0f (sec)", ((tDst*2)/(mSpd-tSpd))), CentralPosX-260, CentralPosY+110, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("Dst: %.1f (m)", tDst), CentralPosX-260, CentralPosY+130, RenderColor, 1, 0xFF000000, false)
			
			render_text(Text_FontMedium, string.format("%.0f", tSpd), CentralPosX-265, CentralPosY-103, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontMedium, string.format("%.0f", tPZ), CentralPosX+265, CentralPosY-103, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontMedium, string.format("%.0f [%.0f]", finalTargetHeading, toRZ), CentralPosX-17, CentralPosY-222, RenderColor, 1, 0xFF000000, false)--tHdng, tRZ
			
			if oRZ > 0 then
				renderFontDrawText(Text_FontMedium, string.format("%.0f->", math.abs(oRZ)), CentralPosX-2, CentralPosY-173, RenderColor, false)
			else
				renderFontDrawText(Text_FontMedium, string.format("<-%.0f", math.abs(oRZ)), CentralPosX-2, CentralPosY-173, RenderColor, false)
			end
		else
			render_text(Text_FontLow, string.format("Цель: %s", tName), CentralPosX-260, CentralPosY+70, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("Крен: %.0f°", mRoll), CentralPosX-260, CentralPosY+90, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("tсбл: %.0f (с)", ((tDst*2)/(mSpd-tSpd))), CentralPosX-260, CentralPosY+110, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontLow, string.format("Дист: %.1f (м)", tDst), CentralPosX-260, CentralPosY+130, RenderColor, 1, 0xFF000000, false)
			
			render_text(Text_FontMedium, string.format("%.0f", tSpd), CentralPosX-190, CentralPosY-160, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontMedium, string.format("%.0f", tPZ), CentralPosX+150, CentralPosY-160, RenderColor, 1, 0xFF000000, false)
			render_text(Text_FontMedium, string.format("%.0f [%.0f]", finalTargetHeading, toRZ), CentralPosX-20, CentralPosY-160, RenderColor, 1, 0xFF000000, false)--tHdng, tRZ
			
			if oRZ > 0 then
				local TxtSize = renderGetFontDrawTextLength(Text_FontMedium, string.format("%.0f°->", math.abs(oRZ)))
				renderFontDrawText(Text_FontMedium, string.format("%.0f°->", math.abs(oRZ)), CentralPosX+65-(TxtSize/2), CentralPosY-160, RenderColor, false)
			else
				local TxtSize = renderGetFontDrawTextLength(Text_FontMedium, string.format("<-%.0f°", math.abs(oRZ)))
				renderFontDrawText(Text_FontMedium, string.format("<-%.0f°", math.abs(oRZ)), CentralPosX-45-(TxtSize/2), CentralPosY-160, RenderColor, false)
			end
		end
		
		ShowTextOnRadar(string.format("%s[%.0f]", tName, tPZ), tPX, tPY, tPZ)
		ShowTextOnRadar("-(v)-", tvX+tPX, tvY+tPY, tvZ+tPZ)
		ShowTextOnRadar("-(w)-", tOX, tOY, tOZ)
		
		if cAngle < 90 or cAngle > 270 then 
			local InterceptVect = SliceLine(CentralPosX+8, CentralPosY-3, WVX, WVY, tDst*0.0005)
			renderDrawLine(CentralPosX+8, CentralPosY-3, InterceptVect.x, InterceptVect.y, 1, RenderColor) 
		elseif tAngle < 180 then 
			renderDrawLine(CentralPosX+8, CentralPosY-3, CentralPosX+(tDst*0.5), CentralPosY+(tDst*0.5), 1, RenderColor) 
		else
			renderDrawLine(CentralPosX+8, CentralPosY-3, CentralPosX-(tDst*0.5), CentralPosY+(tDst*0.5), 1, RenderColor) 
		end
	else
		restoreTargetPlane()
	end
end

----------------------------------------------------------------------------------------------#region LRF MODE Режим ДВБ
local LRFTarget = { ID = -999, x = 0, y = 0, z = 0 }
local TDinfo = { target = -999, alt = -999, dist = -999, talt = 0, tdist = 0}

function SetTargetPlayerId(playerid)
	ClearLRFTargetPlayer()
	if not sampIsPlayerConnected(playerid) then 
		return
	end
	MarkId = playerid
end

function OnUpdateTargetPlayerCoordinates(marker)
	if MarkId == -1 then return end
	if not sampIsPlayerConnected(MarkId) then 
		ClearLRFTargetPlayer()
		return
	end
	if marker.playerId ~= MarkId then return end
	if not marker.active then return end
	print("Target: ", marker, marker.playerId, marker.coords)
	print("Target marker found: ", marker.coords.x, marker.coords.y, marker.coords.z)
	GlobalTarget = {x = marker.coords.x, y = marker.coords.y, z = marker.coords.z}
end

function ClearLRFTargetPlayer()
	MarkId = -1
	GlobalTarget = nil
end

function OnRenderLRFTargetPlayer()
	if (GlobalTarget == nil) then return end
	local vehID = storeCarCharIsInNoSave(PLAYER_PED)
	if vehID == nil then 
		print("[OnRenderLRFPlayer]: Cannot get current vehicle id")
		return
	end
	RenderTargetLineHorizontalRU(vehID, GlobalTarget.x, GlobalTarget.y, GlobalTarget.z, 0xFF8855FF)
end

function splitstr (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end


function GetLockedPos(vehID)
	if sampTextdrawIsExists(LRFTarget.ID) and not(TDinfo.talt == nil or TDinfo.tdist == nil) then
		local posX, posY = sampTextdrawGetPos(LRFTarget.ID)
		LRFTarget.x, LRFTarget.y = ConvertRadarToWorld2D(posX, posY, TDinfo.tdist, vehID)

		LRFTarget.z = TDinfo.talt
		ShowTextOnRadar(string.format("<%.0f>", LRFTarget.z), LRFTarget.x, LRFTarget.y, LRFTarget.z)
	else
	end
end

function ConvertRadarToWorld2D(radarX, radarY, dist, vehID)
	--428 - Конец
	local ResX, ResY = 0, 0
	local sX, sY = getScreenResolution()
	local wCentX = sX * 0.503--494
	local wMinX = sX * 0.384
	local wMaxX = sX * 0.604
	local wMinY = sY * 0.953
	local wMaxY = sY * 0.8
	
	radarX, radarY = ConvertTextDrawCoordinatesToScreen(radarX, radarY, sX, sY)
	
	local diffX, diffY
	if radarX > wCentX then
		diffX = CalcProp(wCentX, wMaxX, radarX)
	else
		diffX = -CalcProp(wCentX, wMinX, radarX)
	end
	diffY = CalcProp(wMinY, wMaxY, radarY)
	
	local dX, dY
	dX = CalcProc(0, 900, diffX)
	dY = CalcProc(0, 900, diffY)
	
	
	ResX, ResY, _ = getOffsetFromCarInWorldCoords(vehID, dX, dY, 0)

	renderFontDrawText(Text_FontLow, string.format("[X: %.0f Y: %.0f]", ResX, ResY), radarX, radarY, 0xFFFF0000)
	return ResX, ResY
end

function CalcProp(min, max, val)
	return (val - min)/(max - min)
end

function CalcProc(minVal, maxVal, proc)
	return ((maxVal-minVal)*proc)+minVal
end

function ConvertTextDrawCoordinatesToScreen(X, Y, SX, SY)
	local rX = CentralPosX+((X-315) * 2.75)
	local rY = Y * 2.4--2.42
	return rX, rY
end

function keyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end


function UpdateMarkers(vehID)
	if #LongRageMarkers > 0 then
		local px, py, pz = getCarCoordinates(vehID)
		for i = 1, #LongRageMarkers do
			if not(LongRageMarkers[i] == nil) then
				local dist = getDistanceBetweenCoords2d(px, py, LongRageMarkers[i].coords.x, LongRageMarkers[i].coords.y)
				local isOnScreen = isPointOnScreen(LongRageMarkers[i].coords.x, LongRageMarkers[i].coords.y, LongRageMarkers[i].coords.z, 100)
				if  dist < 3000 and dist > 150 and math.abs(pz - LongRageMarkers[i].coords.z) < 500 and isOnScreen then -- >380 not >100
					RenderLongRageMarker(LongRageMarkers[i].coords.x, LongRageMarkers[i].coords.y, LongRageMarkers[i].coords.z, dist)
				end
			end
		end
	end
end

function sampev.onMarkersSync(markers)
	if settings.maincfg.AvionicsMode == 3 then
		ClearMarkersData()
		for i = 1, #markers do
			OnUpdateTargetPlayerCoordinates(markers[i])
			AddMarkersData(markers[i])
		end
	end
end

function ClearMarkersData()
	for i = 1, #LongRageMarkers do
		LongRageMarkers[i] = nil
	end
end
function AddMarkersData(marker)
	if marker.active then
		table.insert(LongRageMarkers, {playerid = marker.playerId, isActiveMarker = marker.active, coords = {x = marker.coords.x, y = marker.coords.y, z = marker.coords.z}})
	end
end
function RenderLongRageMarker(x, y, z, dist)
	local WX, WY = convert3DCoordsToScreen(x, y, z)
	renderRomb(WX, WY, 8, 0xFF11FF11)
	renderFontDrawText(Text_FontLowest, string.format("[%d]", dist), WX-10, WY+10, 0xFF11FF11)
end

--------------------------------------------------------------------------------------#region MINIMAP Мини-карта
function ShowIconOnRadar(hud_name, x, y)
	
end

function ShowTextOnRadar(text, x, y, z)

	local rdX, rdY = TransformRealWorldPointToRadarSpace(x, y, z)
	if IsPointInsideRadar(rdX, rdY) then
		local srX, srY = TransformRadarPointToScreenSpace(rdX, rdY)
		local textSize = { x = renderGetFontDrawTextLength(Text_FontLowest, text), y = renderGetFontDrawHeight(Text_FontLowest) }
		if textSize.x > 30 then
			render_text(Text_FontLowest, text, srX - (textSize.x * 1.5), srY - textSize.y, RenderColor, 1, 0xFF000000, false)
		elseif textSize.x > 15 then
			render_text(Text_FontLowest, text, srX - (textSize.x * 3), srY - (textSize.y * 1.5), RenderColor, 1, 0xFF000000, false)
		else
			render_text(Text_FontLowest, text, srX - (textSize.x * 5), srY - (textSize.y * 1.5), RenderColor, 1, 0xFF000000, false)
		end
	end
end

local ffi = require('ffi')
ffi.cdef('struct CVector2D {float x, y;}')
local CRadar_TransformRealWorldPointToRadarSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583530)
local CRadar_TransformRadarPointToScreenSpace = ffi.cast('void (__cdecl*)(struct CVector2D*, struct CVector2D*)', 0x583480)
local CRadar_IsPointInsideRadar = ffi.cast('bool (__cdecl*)(struct CVector2D*)', 0x584D40)

function TransformRealWorldPointToRadarSpace(x, y)
    local RetVal = ffi.new('struct CVector2D', {0, 0})
    CRadar_TransformRealWorldPointToRadarSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
    return RetVal.x, RetVal.y
end

function TransformRadarPointToScreenSpace(x, y)
    local RetVal = ffi.new('struct CVector2D', {0, 0})
    CRadar_TransformRadarPointToScreenSpace(RetVal, ffi.new('struct CVector2D', {x, y}))
    return RetVal.x, RetVal.y
end

function IsPointInsideRadar(x, y)
    return CRadar_IsPointInsideRadar(ffi.new('struct CVector2D', {x, y}))
end

function SliceLine(x1, y1, x2, y2, percentSize)
	local dX = x2 - x1
	local dY = y2 - y1
	local preX = dX * percentSize
	local preY = dY * percentSize
	local res = { x = x1 + preX, y = y1 + preY }
	return res
end


---------------------------------------------------------------


-------------------------------------------------------#region LND MODE Режим ПОС
function NextAirport()
	if landing_data.Airport == "LSIA" then
		LoadLVIA_CMD()
	elseif landing_data.Airport == "LVIA" then
		LoadSFIA_CMD()
	elseif landing_data.Airport == "SFIA" then
		LoadLSIA_CMD()
	end
end

function PrevAirport()
	if landing_data.Airport == "LSIA" then
		LoadSFIA_CMD()
	elseif landing_data.Airport == "LVIA" then
		LoadLSIA_CMD()
	elseif landing_data.Airport == "SFIA" then
		LoadLVIA_CMD()
	end
end
function LoadLSIA_CMD()
	landing_data = {Airport = "LSIA", Course = 90, Approach={x = 634, y = -2593.30, z = 100}, Glidepath = {x = 947, y = -2593.30, z = 64}, BPRM = {x = 1260, y = -2593.30, z = 44}, Runway = { x = 1573.10, y = -2593.30, z = 12.5 }}--{x = 1514.42, y = -2593.24, z = 14.26}}
	landing_dist = {Full = getDistanceBetweenCoords2d(landing_data.Approach.x, landing_data.Approach.y, landing_data.Runway.x, landing_data.Runway.y), Approach = getDistanceBetweenCoords2d(landing_data.Approach.x, landing_data.Approach.y, landing_data.Glidepath.x, landing_data.Glidepath.y), Glidepath = getDistanceBetweenCoords2d(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.BPRM.x, landing_data.BPRM.y), Land = getDistanceBetweenCoords2d(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.Runway.x, landing_data.Runway.y)}
	print("LND DIST: ", landing_dist)
end

function LoadLVIA_CMD()
	landing_data = {Airport = "LVIA", Course = 180, Approach={x = 1477.5, y = 2700, z = 100}, Glidepath = {x = 1477.5, y = 2387, z = 75}, BPRM = {x = 1477.5, y = 2074, z = 44}, Runway = {x = 1477.5, y = 1678.10, z = 9.80}}
	landing_dist = {Full = getDistanceBetweenCoords2d(landing_data.Approach.x, landing_data.Approach.y, landing_data.Runway.x, landing_data.Runway.y), Approach = getDistanceBetweenCoords2d(landing_data.Approach.x, landing_data.Approach.y, landing_data.Glidepath.x, landing_data.Glidepath.y), Glidepath = getDistanceBetweenCoords2d(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.BPRM.x, landing_data.BPRM.y), Land = getDistanceBetweenCoords2d(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.Runway.x, landing_data.Runway.y)}
	print("LND DIST: ", landing_dist)
end

function LoadSFIA_CMD()
	landing_data = {Airport = "SFIA", Course = 225, Approach={x = -496.30, y = 994, z = 100}, Glidepath = {x = -783.80, y = 709, z = 64}, BPRM = {x = -1020.20, y = 472.5, z = 34}, Runway = {x = -1134.80, y = 357.90, z = 13.20}}
	landing_dist = {Full = getDistanceBetweenCoords2d(landing_data.Approach.x, landing_data.Approach.y, landing_data.Runway.x, landing_data.Runway.y), Approach = getDistanceBetweenCoords2d(landing_data.Approach.x, landing_data.Approach.y, landing_data.Glidepath.x, landing_data.Glidepath.y), Glidepath = getDistanceBetweenCoords2d(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.BPRM.x, landing_data.BPRM.y), Land = getDistanceBetweenCoords2d(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.Runway.x, landing_data.Runway.y)}
	print("LND DIST: ", landing_dist)
end

function LoadFile_CMD(arg)
	if #arg < 1 then sampAddChatMessage(GetLocalizationMessage(132), 0xFFFFFF) end--Синтаксис: /ldfp [filename] - загрузить план полёта
	local path = string.format("%s\\resource\\avionics\\flightplan\\%s.safp", getWorkingDirectory(), arg)
	local f=io.open(path,"r")
	if f~=nil then 
		io.close(f) 
	else 
		sampAddChatMessage(string.format(GetLocalizationMessage(133), arg), 0xFFFFFF)--
		return 
	end
	local wpData = safp.Load(path)
	print("Loading flight plan:\n\"", path, "\"")
	
	for i = 1, #safp.Waypoints do
		-- print("Adding WPT from file: ", safp.Waypoints[i].pos.x, safp.Waypoints[i].pos.y, safp.Waypoints[i].pos.z)
		AddPPM_CMD({safp.Waypoints[i].pos.x, safp.Waypoints[i].pos.y, safp.Waypoints[i].pos.z})--string.format("%.2f %.2f %.2f", safp.Waypoints[i].pos.x, safp.Waypoints[i].pos.y, safp.Waypoints[i].pos.z))
	end
end

function SaveFile_CMD(arg)
	if #arg < 1 then sampAddChatMessage(GetLocalizationMessage(134), 0xFFFFFF) end--Синтаксис: /svfp [filename] - сохранить план полёта
	local path = string.format("%s\\resource\\avionics\\flightplan\\%s.safp", getWorkingDirectory(), arg)
	local data = {number, x, y, z}
	for i = 1, #PPMX do
		table.insert(data, { number = i, x = PPMX[i], y = PPMY[i], z = PPMZ[i] })
	end
	local result = safp.Save(path, data)
	if not result then 
		sampAddChatMessage(string.format(GetLocalizationMessage(135), arg), 0xFFFFFF) --{FF0000}[Avionics]: {FFFFFF}невозможно сохранить план полёта ( %s )
	else
		sampAddChatMessage(string.format(GetLocalizationMessage(136), arg), 0xFFFFFF) --{00A2FF}[Avionics] {FFFFFF}план полёта успешно сохранён ( %s )
	end
end

function StartLND()
	
end

function UpdateLines_LND(vehID)
	local vY = getCarPitch(vehID)-2.5
	local vR = getCarRoll(vehID)
	local vHdng = 360 - getCarHeading(vehID)
	local vPX, vPY, vPZ = getCarCoordinates(vehID)
	local GlideDist = getDistanceBetweenCoords2d(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.Runway.x, landing_data.Runway.y)
	
	local multiplyer = 1
	if math.abs(vY) > 180 then vY =  vY - 360 end
	if math.abs(vR) > 90 then 
		if vY > 90 then 
			vY = 180 - vY
		else 
			if vY < -90 then
				vY = (vY + 180)*-1
			end
		end
	end
	OffcetY = vY*10
	local PosY
	
	PosY = CentralPosY+OffcetY*multiplyer-10
	if PosY < 850 and PosY > 300 then renderDrawTexture(hud_pithh, CentralPosX-290, PosY, 600, 30, 0, RenderColor) end
	local ITRi = 60
	while ITRi < 3300 do
		PosY = CentralPosY+ITRi+OffcetY*multiplyer-10
		if PosY < 850 and PosY > 300 then renderDrawTexture(hud_pithn, CentralPosX-240, PosY, 500, 30, 0, RenderColor) end
		ITRi = ITRi + 60
	end
	ITRi = -60
	while ITRi > -3300 do
		PosY = CentralPosY+ITRi+OffcetY*multiplyer-10
		if PosY < 850 and PosY > 300 then renderDrawTexture(hud_pithp, CentralPosX-240, PosY, 500, 30, 0, RenderColor) end
		ITRi = ITRi - 60
	end
	UpdatePlaneRTextLines(vY, vR)
	
	
	local Distance = getDistanceBetweenCoords2d(vPX, vPY, landing_data.Runway.x, landing_data.Runway.y)
	
	render_text(Text_FontLow, string.format("ICAO: %s", landing_data.Airport), CentralPosX-260, CentralPosY+70, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, string.format("LENG: %.0f", landing_dist.Full), CentralPosX-260, CentralPosY+130, RenderColor, 1, 0xFF000000, false)
	
	local hDiff = math.abs(vHdng - landing_data.Course)
	if Distance > landing_dist.Full or  hDiff > 30 then
		UpdateLines_LND_Approach(vehID, vPX, vPY, vPZ)
	else
		UpdateLines_LND_Landing(vehID, vPX, vPY, vPZ, vRoll, GlideDist, vHdng, hDiff)
	end
end

function UpdateLines_LND_Approach(vehID, vPX, vPY, vPZ)
	local tDst = getDistanceBetweenCoords2d(vPX, vPY, landing_data.Approach.x, landing_data.Approach.y)
	local mOX, mOY, mOZ = getOffsetFromCarInWorldCoords(vehID, 0, tDst, 0)
	local tAngle = SPO_CheckAngle2(vPX, vPY, mOX, mOY, landing_data.Approach.x, landing_data.Approach.y)
	local vRZ = 360 - getCarHeading(vehID)
	
	local tHdng = tAngle + vRZ
	if tHdng > 360 then tHdng = math.abs(360 - tHdng) end
	render_text(Text_FontLow, string.format("DST: %.0f (m)", tDst), CentralPosX-260, CentralPosY+90, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, string.format("H(appr): %.0f", landing_data.Approach.z), CentralPosX-260, CentralPosY+110, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, "Approach", CentralPosX-260, CentralPosY+150, RenderColor, 1, 0xFF000000, false)
	
	render_text(Text_FontMedium, string.format("%.0f", tHdng), CentralPosX-7, CentralPosY-222, RenderColor, 1, 0xFF000000, false)
	
	if tAngle > 180 and tAngle < 360 then
		local renderAngle = 360 - tAngle
		render_text(Text_FontMedium, string.format("<--%.0f", renderAngle), CentralPosX-77, CentralPosY-202, RenderColor, 1, 0xFF000000, false)
	else
		render_text(Text_FontMedium, string.format("%.0f-->", tAngle), CentralPosX+57, CentralPosY-202, RenderColor, 1, 0xFF000000, false)
	end
	
	
	if isPointOnScreen(landing_data.Approach.x, landing_data.Approach.y, landing_data.Approach.z, 100) then
		local wX, wY = convert3DCoordsToScreen(landing_data.Approach.x, landing_data.Approach.y, landing_data.Approach.z)
		renderSquare(wX, wY, 10, RenderColor)
		render_text(Text_FontLow, string.format("%s", landing_data.Airport), wX-13, wY-30, RenderColor, 1, 0xFF000000, false)
		
		local wX1, wY1 = convert3DCoordsToScreen(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.Glidepath.z)
		renderSquare(wX1, wY1, 10, RenderColor)
		renderDrawLine(wX, wY, wX1, wY1, 1, RenderColor)
	end
end

function UpdateLines_LND_Landing(vehID, vPX, vPY, vPZ, vRoll, vRZ, hDiff)
	local CurDist = getDistanceBetweenCoords2d(vPX, vPY, landing_data.Runway.x, landing_data.Runway.y)
	render_text(Text_FontLow, string.format("DST: %.0f (m)", CurDist), CentralPosX-260, CentralPosY+90, RenderColor, 1, 0xFF000000, false)
	local mOX, mOY, mOZ = getOffsetFromCarInWorldCoords(vehID, 0, CurDist, 0)
	local lAngle = SPO_CheckAngle2(vPX, vPY, mOX, mOY, landing_data.Runway.x, landing_data.Runway.y)
	local vRZ = 360 - getCarHeading(vehID)
	
	local tHdng = lAngle + vRZ
	local CurProc = CalcProp(landing_dist.Land, 0, CurDist)
	
	
	if tHdng > 360 then tHdng = math.abs(360 - tHdng) end
	render_text(Text_FontMedium, string.format("%.0f", tHdng), CentralPosX-7, CentralPosY-222, RenderColor, 1, 0xFF000000, false)
	
	if hDiff > 5 and CurProc > 0.6 and (vPZ - landing_data.Runway.z) > 15 then
		renderFontDrawText(Text_FontMain, "!GO AROUND!", CentralPosX-65, CentralPosY-30, 0xFFCC0000, false)
	end	
	if lAngle > 180 and lAngle < 360 then
		local renderAngle = 360 - lAngle
		render_text(Text_FontMedium, string.format("<--%.0f", renderAngle), CentralPosX-77, CentralPosY-202, RenderColor, 1, 0xFF000000, false)
	else
		render_text(Text_FontMedium, string.format("%.0f-->", lAngle), CentralPosX+57, CentralPosY-202, RenderColor, 1, 0xFF000000, false)
	end

	
	local GlideHeight = CalcProc(landing_data.BPRM.z, landing_data.Runway.z, CurProc)
	if vPZ > GlideHeight then
		render_text(Text_FontMedium, string.format("%.0f (ASL) UPPER", GlideHeight), CentralPosX+265, CentralPosY-103, RenderColor, 1, 0xFF000000, false)
	else
		render_text(Text_FontMedium, string.format("%.0f (ASL) LOWER", GlideHeight), CentralPosX+265, CentralPosY-103, RenderColor, 1, 0xFF000000, false)
	end
	render_text(Text_FontLow, string.format("Hdif: %.0f", vPZ-GlideHeight), CentralPosX-260, CentralPosY+110, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, "Glidepath", CentralPosX-260, CentralPosY+150, RenderColor, 1, 0xFF000000, false)

	if isPointOnScreen(landing_data.Runway.x, landing_data.Runway.y, landing_data.Runway.z, 1) then
		local wX, wY = convert3DCoordsToScreen(landing_data.Runway.x, landing_data.Runway.y, landing_data.Runway.z)
		local wX1, wY1 = convert3DCoordsToScreen(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.BPRM.z)
		if CurProc < 0.05 then
			renderSquare(wX1, wY1, 10, RenderColor)
			renderDrawLine(wX, wY, wX1, wY1, 1, RenderColor)
		end
		if CurProc < 1 then
			renderSquare(wX, wY, 10, RenderColor)
			
		end
	elseif CurProc < 0.7 then
		local wX1, wY1 = convert3DCoordsToScreen(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.BPRM.z)
		local wX2, wY2 = convert3DCoordsToScreen(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.Glidepath.z)
		renderDrawLine(wX1, wY1, wX2, wY2, 1, RenderColor)
		renderSquare(wX1, wY1, 10, RenderColor)
		renderSquare(wX2, wY2, 10, RenderColor)
	end
end


function UpdateLines_LND_RU(vehID)
	local vY = getCarPitch(vehID)-2.5
	local vR = getCarRoll(vehID)
	local vHdng = 360 - getCarHeading(vehID)
	local vPX, vPY, vPZ = getCarCoordinates(vehID)
	local GlideDist = getDistanceBetweenCoords2d(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.Runway.x, landing_data.Runway.y)
	
	UpdateLinesRU(vehID)
	
	
	local Distance = getDistanceBetweenCoords2d(vPX, vPY, landing_data.Runway.x, landing_data.Runway.y)
	
	render_text(Text_FontLow, string.format("ICAO: %s", landing_data.Airport), CentralPosX+180, CentralPosY+100, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, string.format("Длина глиссады: %.0f", landing_dist.Full), CentralPosX+180, CentralPosY+120, RenderColor, 1, 0xFF000000, false)
	
	local hDiff = math.abs(vHdng - landing_data.Course)
	if Distance > landing_dist.Full or  hDiff > 30 then
		UpdateLines_LND_Approach_RU(vehID, vPX, vPY, vPZ)
	else
		UpdateLines_LND_Landing_RU(vehID, vPX, vPY, vPZ, vRoll, GlideDist, vHdng, hDiff)
	end
end

function UpdateLines_LND_Approach_RU(vehID, vPX, vPY, vPZ)
	local tDst = getDistanceBetweenCoords2d(vPX, vPY, landing_data.Approach.x, landing_data.Approach.y)
	local mOX, mOY, mOZ = getOffsetFromCarInWorldCoords(vehID, 0, tDst, 0)
	local tAngle = SPO_CheckAngle2(vPX, vPY, mOX, mOY, landing_data.Approach.x, landing_data.Approach.y)
	local vRZ = 360 - getCarHeading(vehID)
	
	local tHdng = tAngle + vRZ
	if tHdng > 360 then tHdng = math.abs(360 - tHdng) end
	render_text(Text_FontLow, string.format("Дистанция: %.0f (м)", tDst), CentralPosX+180, CentralPosY+140, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, string.format("h подхода: %.0f", landing_data.Approach.z), CentralPosX+180, CentralPosY+160, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, "Подход", CentralPosX+180, CentralPosY+80, RenderColor, 1, 0xFF000000, false)
	
	render_text(Text_FontMedium, string.format("%.0f", tHdng), CentralPosX-7, CentralPosY-162, RenderColor, 1, 0xFF000000, false)
	
	if tAngle > 180 and tAngle < 360 then
		local renderAngle = 360 - tAngle
		render_text(Text_FontMedium, string.format("<--%.0f", renderAngle), CentralPosX-57, CentralPosY-162, RenderColor, 1, 0xFF000000, false)
	else
		render_text(Text_FontMedium, string.format("%.0f-->", tAngle), CentralPosX+27, CentralPosY-162, RenderColor, 1, 0xFF000000, false)
	end
	
	
	if isPointOnScreen(landing_data.Approach.x, landing_data.Approach.y, landing_data.Approach.z, 100) then
		local wX, wY = convert3DCoordsToScreen(landing_data.Approach.x, landing_data.Approach.y, landing_data.Approach.z)
		renderSquare(wX, wY, 10, RenderColor)
		render_text(Text_FontLow, string.format("%s", landing_data.Airport), wX-13, wY-30, RenderColor, 1, 0xFF000000, false)
	
		local wX1, wY1 = convert3DCoordsToScreen(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.Glidepath.z)
		renderSquare(wX1, wY1, 10, RenderColor)
		renderDrawLine(wX, wY, wX1, wY1, 1, RenderColor)
	end
	
	RenderTargetLineHorizontalRU(vehID, landing_data.Approach.x, landing_data.Approach.y, landing_data.Approach.z, 0xFF0000AA)
end

function UpdateLines_LND_Landing_RU(vehID, vPX, vPY, vPZ, vRoll, vRZ, hDiff)
	local CurDist = getDistanceBetweenCoords2d(vPX, vPY, landing_data.Runway.x, landing_data.Runway.y)
	render_text(Text_FontLow, string.format("Дальность: %.0f (м)", CurDist), CentralPosX+180, CentralPosY+140, RenderColor, 1, 0xFF000000, false)
	local mOX, mOY, mOZ = getOffsetFromCarInWorldCoords(vehID, 0, CurDist, 0)
	local lAngle = SPO_CheckAngle2(vPX, vPY, mOX, mOY, landing_data.Runway.x, landing_data.Runway.y)
	local vRZ = 360 - getCarHeading(vehID)
	
	local tHdng = lAngle + vRZ
	local CurProc = CalcProp(landing_dist.Land, 0, CurDist)
	
	
	if tHdng > 360 then tHdng = math.abs(360 - tHdng) end
	render_text(Text_FontMedium, string.format("%.0f", tHdng), CentralPosX-7, CentralPosY-162, RenderColor, 1, 0xFF000000, false)
	
	if hDiff > 5 and CurProc > 0.6 and (vPZ - landing_data.Runway.z) > 15 then
		renderFontDrawText(Text_FontMain, "!ЗАПРЕТ ПОСАДКИ!", CentralPosX-95, CentralPosY-30, 0xFFCC0000, false)
	end	
	if lAngle > 180 and lAngle < 360 then
		local renderAngle = 360 - lAngle
		render_text(Text_FontMedium, string.format("<--%.0f", renderAngle), CentralPosX-57, CentralPosY-162, RenderColor, 1, 0xFF000000, false)
	else
		render_text(Text_FontMedium, string.format("%.0f-->", lAngle), CentralPosX+27, CentralPosY-162, RenderColor, 1, 0xFF000000, false)
	end

	
	local GlideHeight = CalcProc(landing_data.BPRM.z, landing_data.Runway.z, CurProc)
	if vPZ > GlideHeight then
		render_text(Text_FontMedium, string.format("%.0f (УМ) ВЫШЕ", vPZ-GlideHeight), CentralPosX+180, CentralPosY-140, RenderColor, 1, 0xFF000000, false)
	else
		render_text(Text_FontMedium, string.format("%.0f (УМ) НИЖЕ", vPZ-GlideHeight), CentralPosX+180, CentralPosY-140, RenderColor, 1, 0xFF000000, false)
	end
	render_text(Text_FontLow, string.format("Превышение: %.0f", vPZ-GlideHeight), CentralPosX+180, CentralPosY+160, RenderColor, 1, 0xFF000000, false)
	render_text(Text_FontLow, "Глиссада", CentralPosX+180, CentralPosY+80, RenderColor, 1, 0xFF000000, false)

	if isPointOnScreen(landing_data.Runway.x, landing_data.Runway.y, landing_data.Runway.z, 1) then
		local wX, wY = convert3DCoordsToScreen(landing_data.Runway.x, landing_data.Runway.y, landing_data.Runway.z)
		local wX1, wY1 = convert3DCoordsToScreen(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.BPRM.z)
		if CurProc < 0.05 then
			renderSquare(wX1, wY1, 10, RenderColor)
			renderDrawLine(wX, wY, wX1, wY1, 1, RenderColor)
		end
		if CurProc < 1 then
			renderSquare(wX, wY, 10, RenderColor)
		end
	elseif CurProc < 0.7 then
		local wX1, wY1 = convert3DCoordsToScreen(landing_data.BPRM.x, landing_data.BPRM.y, landing_data.BPRM.z)
		local wX2, wY2 = convert3DCoordsToScreen(landing_data.Glidepath.x, landing_data.Glidepath.y, landing_data.Glidepath.z)
		renderDrawLine(wX1, wY1, wX2, wY2, 1, RenderColor)
		renderSquare(wX1, wY1, 10, RenderColor)
		renderSquare(wX2, wY2, 10, RenderColor)
	end
	
	RenderTargetLineHorizontalRU(vehID, landing_data.Runway.x, landing_data.Runway.y, landing_data.Runway.z, 0xFF0000AA)
end

----------------------------------------------------------------------#region SAMPFUNCS-free зависимости сампфанкс
function sampev.onSendCommand(command)
	print("command: ", command)
	local isAvionicsCommand = CommandRegisteredSwitch(command)
	if isAvionicsCommand then return false end
end

function CommandRegisteredSwitch(cmd)
	local cmd, args = GetArgs(cmd)
	if cmd == nil or args == nil then return false end
	print("args (count: " .. #args .. ")")
	if cmd == "/setppm" then SetPPM_CMD(args) return true
	elseif cmd == "/setwpt" then SetPPM_CMD(args) return true
	elseif cmd == "/swavionics" then MainMenu_CMD(args) return true
	elseif cmd == "/swav" then MainMenu_CMD(args) return true
	elseif cmd == "/avionix" then MainMenu_CMD(args) return true
	elseif cmd == "/sweditfp" then EditFP_CMD(args) return true
	elseif cmd == "/swcam" then TogglePlaneCamera(args) return true
	elseif cmd == "/swmag" then ToggleHeliWinch(args) return true
	elseif cmd == "/swtdid" then ShowTDIDs(args) return true
	elseif cmd == "/addwpt" then AddPPM_CMD(args) return true
	elseif cmd == "/addnextwpt" then AddNextPPM_CMD(args) return true
	elseif cmd == "/delwpt" then DelPPM_CMD(args) return true
	elseif cmd == "/clearwpt" then ClrPPM_CMD(args) return true
	elseif cmd == "/addppm" then AddPPM_CMD(args) return true
	elseif cmd == "/addnextppm" then AddNextPPM_CMD(args) return true
	elseif cmd == "/delppm" then DelPPM_CMD(args) return true
	elseif cmd == "/clearppm" then ClrPPM_CMD(args) return true
	elseif cmd == "/autopilot" then AutoPilot_CMD(args) return true
	elseif cmd == "/swapt" then AutoPilot_CMD(args) return true
	elseif cmd == "/swapto" then AutoPilotOff_CMD(args) return true
	elseif cmd == "/wptcam" then CamToPPM_CMD(args) return true
	elseif cmd == "/ppmcam" then CamToPPM_CMD(args) return true
	elseif cmd == "/tarcam" then CamToPPM_CMD(args) return true
	elseif cmd == "/tarwpt" then TargetToPPM_CMD(args) return true
	elseif cmd == "/tarppm" then TargetToPPM_CMD(args) return true
	elseif cmd == "/markwpt" then MarkerToPPM_CMD(args) return true
	elseif cmd == "/markppm" then MarkerToPPM_CMD(args) return true
	elseif cmd == "/blipwpt" then SAMarkerToPPM_CMD(args) return true
	elseif cmd == "/blipppm" then SAMarkerToPPM_CMD(args) return true
	elseif cmd == "/idppm" then PlayerIdToPPM_CMD(args) return true
	elseif cmd == "/idwpt" then PlayerIdToPPM_CMD(args) return true
	elseif cmd == "/racewpt" then RaceToPPM_CMD(args) return true
	elseif cmd == "/raceppm" then RaceToPPM_CMD(args) return true
	elseif cmd == "/vehwpt" then VehicleToPPM_CMD(args) return true
	elseif cmd == "/vehppm" then VehicleToPPM_CMD(args) return true
	elseif cmd == "/swamode" then AvionicsMode_CMD(args) return true
	elseif cmd == "/swam" then AvionicsMode_CMD(args[1]) return true
	elseif cmd == "/swazoom" then SetZoomFix_CMD(args) return true
	elseif cmd == "/swaz" then SetZoomFix_CMD(args) return true
	elseif cmd == "/lsia" then LoadLSIA_CMD(args) return true
	elseif cmd == "/lvia" then LoadLVIA_CMD(args) return true
	elseif cmd == "/sfia" then LoadSFIA_CMD(args) return true
	elseif cmd == "/safp" then 
		if #args > 0 then
			LoadFile_CMD(args[1]) 
		end
		return true
	elseif cmd == "/ldfp" then 
		if #args > 0 then
			LoadFile_CMD(args[1]) 
		end
		return true
	elseif cmd == "/ldfl" then 
		if #args > 0 then
			LoadFile_CMD(args[1]) 
		end
		return true
	elseif cmd == "/svfp" then 
		if #args > 0 then
			SaveFile_CMD(args[1]) 
		end
		return true
	elseif cmd == "/svfl" then 
		if #args > 0 then
			SaveFile_CMD(args[1]) 
		end
		return true
	elseif cmd == "/savefp" then 
		if #args > 0 then
			SaveFile_CMD(args[1]) 
		end
		return true
	end
	return false
end

function GetArgs(arg)
	local args = {}
	local cmd = ""
	local res = {}
	for str in string.gmatch(arg, "([^".." ".."]+)") do
		table.insert(args, str)
	end
	if #args > 0 then
		cmd = args[1]
	end
	if #args > 1 then
		for i = 2, #args do
			table.insert(res, args[i])
		end
	end
	print("getArgs [ " .. cmd .. " ] ; [ " .. #res .. " ]")
	return cmd, res
end

-------------------------------------------------------------------#region samp markers

function SearchMarker(posX, posY, posZ, radius, isRace)
    local ret_posX = 0.0
    local ret_posY = 0.0
    local ret_posZ = 0.0
    local isFind = false

    for id = 0, 31 do
        local MarkerStruct = 0
        if isRace then MarkerStruct = 0xC7F168 + id * 56
        else MarkerStruct = 0xC7DD88 + id * 160 end
        local MarkerPosX = representIntAsFloat(readMemory(MarkerStruct + 0, 4, false))
        local MarkerPosY = representIntAsFloat(readMemory(MarkerStruct + 4, 4, false))
        local MarkerPosZ = representIntAsFloat(readMemory(MarkerStruct + 8, 4, false))

        if MarkerPosX ~= 0.0 or MarkerPosY ~= 0.0 or MarkerPosZ ~= 0.0 then
            if getDistanceBetweenCoords3d(MarkerPosX, MarkerPosY, MarkerPosZ, posX, posY, posZ) < radius then
                ret_posX = MarkerPosX
                ret_posY = MarkerPosY
                ret_posZ = MarkerPosZ
                isFind = true
                radius = getDistanceBetweenCoords3d(MarkerPosX, MarkerPosY, MarkerPosZ, posX, posY, posZ)
            end
        end
    end

    return isFind, ret_posX, ret_posY, ret_posZ
end
