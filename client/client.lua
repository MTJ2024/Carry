--[[
    MTJ_Carry — Client-Script
    (c) 2024 MTJ2024 — Alle Rechte vorbehalten
    https://github.com/MTJ2024/Carry

    PLAGIATSCHUTZ: Dieses Script ist urheberrechtlich geschuetzt.
    Unbefugtes Kopieren oder Verbreiten ist untersagt.
]]

local MTJ_COPYRIGHT = {
    name    = 'MTJ_Carry',
    version = '2.0',
    author  = 'MTJ2024',
    github  = 'https://github.com/MTJ2024/Carry',
}

local function debugPrint(msg)
	print('[MTJ_Carry] ' .. tostring(msg))
end

-- Copyright-Banner im F8-Konsolenfenster
print('^3══════════════════════════════════════════════════^0')
print('^5  ' .. MTJ_COPYRIGHT.name .. ' v' .. MTJ_COPYRIGHT.version .. '^0')
print('^2  (c) 2024 ' .. MTJ_COPYRIGHT.author .. ' — Alle Rechte vorbehalten^0')
print('^4  ' .. MTJ_COPYRIGHT.github .. '^0')
print('^3══════════════════════════════════════════════════^0')

-- Plagiatschutz: Resource-Name pruefen
local currentName = GetCurrentResourceName()
if currentName ~= 'MTJ_Carry' and currentName ~= 'Carry' then
    debugPrint('^1WARNUNG: Resource umbenannt zu "' .. currentName .. '"!^0')
    debugPrint('^1Original: MTJ_Carry von MTJ2024 — https://github.com/MTJ2024/Carry^0')
end

debugPrint('Client-Script wird geladen...')

local ESX = nil
local initOk, initErr = pcall(function()
	ESX = exports["es_extended"]:getSharedObject()
end)
if not initOk then
	debugPrint('FEHLER: ESX Init fehlgeschlagen: ' .. tostring(initErr))
	debugPrint('Stelle sicher, dass es_extended vor MTJ_Carry gestartet wird!')
else
	debugPrint('ESX geladen')
end

local PlayerData              = {}
local carryingBackInProgress  = false
local accepted = false
local carryActive = true

-- Sicherheit: NUI-Fokus freigeben wenn Resource stoppt
AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		debugPrint('Resource stoppt — NUI-Fokus wird freigegeben')
		SetNuiFocus(false, false)
	end
end)

-- Eingebauter Benachrichtigungs-Empfaenger (vom Server)
RegisterNetEvent('MTJ_Carry:notify')
AddEventHandler('MTJ_Carry:notify', function(text, msgtype)
	debugPrint('Benachrichtigung: ' .. tostring(msgtype) .. ' — ' .. tostring(text))
	SendNUIMessage({
		message  = 'showNotify',
		text     = text,
		msgtype  = msgtype or 'info',
		duration = 5000
	})
end)

-----[ANFRAGE]-------
RegisterNetEvent("MTJ_Carry:senderrequest")
AddEventHandler("MTJ_Carry:senderrequest", function(CarryTypeChoosed)
	debugPrint('Anfrage gestartet, Typ=' .. tostring(CarryTypeChoosed))
	local reqstcarryanim = CarryTypeChoosed
	CreateThread(function()
		while true do
			Wait(0)
			if reqstcarryanim ~= nil then
				if not ESX or not ESX.Game then
					debugPrint('FEHLER: ESX.Game nicht verfuegbar')
					break
				end
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 2.5 then
					ESX.ShowHelpNotification("~INPUT_PICKUP~ Interaktion vorschlagen \n~INPUT_VEH_DUCK~ Abbrechen")
					target_id = GetPlayerPed(closestPlayer)
					playerX, playerY, playerZ = table.unpack(GetEntityCoords(target_id))
					DrawMarker(0, playerX, playerY, playerZ+1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 232, 168, 73, 70, true, true, 2, true, false, false, false)
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent("MTJ_Carry:animrequest", GetPlayerServerId(closestPlayer), reqstcarryanim)
						Notify("Anfrage gesendet", 'success')
						debugPrint('Anfrage an Spieler gesendet')
						break
					end
					if IsControlJustPressed(0, 73) then
						ClearPedTasks(PlayerPedId())
						Wait(200)
						debugPrint('Anfrage vom Spieler abgebrochen')
						break
					end
				else
					Notify("Niemand in der Naehe", 'error')
					debugPrint('Kein Spieler in der Naehe')
					break
				end
			end
		end
		debugPrint('Anfrage-Schleife beendet')
	end)
end)

RegisterNetEvent("MTJ_Carry:receiverequest")
AddEventHandler("MTJ_Carry:receiverequest", function(sender, reqstcarryanim)
    debugPrint('Trage-Anfrage erhalten, Typ=' .. tostring(reqstcarryanim))
    isRequestAnim = true
    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)

    -- Anfrage-Dialog im NUI anzeigen (kein Cursor noetig — Tastatur)
    SendNUIMessage({message = 'showcarryrequest'})

    local waiting = 0
    CreateThread(function()
        while isRequestAnim do
            Wait(0)
            -- Tasten reservieren damit andere Systeme sie nicht verbrauchen
            DisableControlAction(0, Config.acceptkey, true)
            DisableControlAction(0, Config.declinekey, true)

            if IsDisabledControlJustPressed(0, Config.acceptkey) then
                debugPrint('Annehmen-Taste gedrueckt (Control ' .. Config.acceptkey .. ')')
                SendNUIMessage({message = 'hidecarryrequest'})
                Notify("Anfrage angenommen", 'success')
                if not ESX or not ESX.Game then
                    debugPrint('FEHLER: ESX.Game nicht verfuegbar fuer Annahme')
                    isRequestAnim = false
                    break
                end
                local target, distance = ESX.Game.GetClosestPlayer()
                if(distance ~= -1 and distance < 3) then
                    TriggerServerEvent("MTJ_Carry:animationaccepted", sender, reqstcarryanim)
                    accepted = true
                    isRequestAnim = false
                else
                    Notify("Niemand nah genug.", 'info')
                    debugPrint('Annahme fehlgeschlagen: niemand nah genug')
                end
            elseif IsDisabledControlJustPressed(0, Config.declinekey) then
                debugPrint('Ablehnen-Taste gedrueckt (Control ' .. Config.declinekey .. ')')
                SendNUIMessage({message = 'hidecarryrequest'})
                Notify("Anfrage abgelehnt.", 'error')
                if ESX and ESX.Game then
                    local target = ESX.Game.GetClosestPlayer()
                    local targetServerId = GetPlayerServerId(target)
                    TriggerServerEvent("MTJ_Carry:animationdenied", targetServerId)
                end
                isRequestAnim = false
            end
        end
        debugPrint('Empfaenger-Schleife beendet')
    end)
    CreateThread(function()
        while isRequestAnim do
            Wait(100)
            waiting = waiting + 1
            if waiting > 100 then
                isRequestAnim = false
                SendNUIMessage({message = 'hidecarryrequest'})
                Notify("Anfrage abgelaufen", 'info')
                debugPrint('Anfrage nach Timeout abgelaufen')
            end
        end
    end)
end)

RegisterNetEvent("MTJ_Carry:playsharedsource")
AddEventHandler("MTJ_Carry:playsharedsource", function(reqstcarryanim, player)
	debugPrint('Animation starten, Typ=' .. tostring(reqstcarryanim))
	local animType = reqstcarryanim
	if animType == "type1" then
		carryingBackInProgress = true
		local closestPlayer = GetClosestPlayer(3)
		target = player
		if closestPlayer ~= nil then
			TriggerServerEvent('MTJ_Carry:anim1:Sync', closestPlayer, 'missfinale_c2mcs_1','nm', 'fin_c2_mcs_1_camman', 'firemans_carry', 0.15, 0.27, 0.63, target, 100000, 0.0, 49, 33, 1)
			isCarry = true
		end
	elseif animType == "type2" then
		carryingBackInProgress = true
        Citizen.Wait(100)
        local dict = "anim@heists@box_carry@"
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(100)
        end
		targetplayer = player
        TriggerServerEvent('MTJ_Carry:onhandanim', targetplayer)
        TaskPlayAnim(PlayerPedId(), dict, "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
    elseif animType == "type3" then
        carryingBackInProgress = true
		local closestPlayer = GetClosestPlayer(3)
		target = player
		if closestPlayer ~= nil then
			TriggerServerEvent('MTJ_Carry:anim2:Sync', closestPlayer, 'anim@arena@celeb@flat@paired@no_props@', 'piggyback_c_player_a', 'piggyback_c_player_b', -0.07, 0.0, 0.45, target, 100000, 0.0, 49, 33, 1)
		end
	end
end)

-----[ENDE ANFRAGE]-------

RegisterCommand(Config.command, function(source, args)
	debugPrint('Befehl /carry ausgefuehrt')
	local ok, err = pcall(function()
		if carryActive then
			if carryingBackInProgress == true then
				debugPrint('Tragen wird gestoppt...')
				local closestPlayer = GetClosestPlayer(3)
				target = GetPlayerServerId(closestPlayer)
				TriggerServerEvent("MTJ_Carry:anim:stop", target)
				Wait(1000)
				TriggerEvent('MTJ_Carry:anim:clientstop')
				carryingBackInProgress = false
				local accepted = false
			else
				debugPrint('Trage-Menue wird geoeffnet (NUI Fokus AN)')
				SetNuiFocus(true, true)
				SendNUIMessage({
					message	= "showtypes"
				})
			end
		end
	end)
	if not ok then
		debugPrint('FEHLER im /carry Befehl: ' .. tostring(err))
		SetNuiFocus(false, false)
		SendNUIMessage({message = "hide"})
	end
end)

RegisterNUICallback("closetypeselect", function(a, cb)
    debugPrint('NUI: Menue geschlossen')
    SetNuiFocus(false, false)
    SendNUIMessage({message = "hide"})
    cb('ok')
end)

RegisterNUICallback("selecttype", function(a, cb)
    debugPrint('NUI: Typ gewaehlt = ' .. tostring(a.carrytype))
    CarryTypeChoosed = tostring(a.carrytype)
    SetNuiFocus(false, false)
	if CarryTypeChoosed == "type1" or CarryTypeChoosed == "type2" or CarryTypeChoosed == "type3" then
		if not carryingBackInProgress then
			debugPrint('Anfrage wird gestartet fuer ' .. CarryTypeChoosed)
			TriggerEvent("MTJ_Carry:senderrequest", CarryTypeChoosed)
		else
			debugPrint('Tragen laeuft bereits, wird ignoriert')
		end
	else
		debugPrint('Unbekannter Trage-Typ: ' .. CarryTypeChoosed)
	end
	cb('ok')
end)

--------[ANIMATIONS]--------

function LoadAnimationDictionary(animationD)
	while(not HasAnimDictLoaded(animationD)) do
		RequestAnimDict(animationD)
		Citizen.Wait(1)
	end
end

RegisterNetEvent('MTJ_Carry:onhandanimcarry')
AddEventHandler('MTJ_Carry:onhandanimcarry', function(target)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	local lPed = PlayerPedId()
	LoadAnimationDictionary("amb@code_human_in_car_idles@generic@ps@base")
	TaskPlayAnim(lPed, "amb@code_human_in_car_idles@generic@ps@base", "base", 8.0, -8, -1, 33, 0, 0, 40, 0)
	AttachEntityToEntity(PlayerPedId(), targetPed, 9816, 0.015, 0.38, 0.11, 0.9, 0.30, 90.0, false, false, false, false, 2, false)
end)

RegisterNetEvent('MTJ_Carry:anim2:SyncTarget')
AddEventHandler('MTJ_Carry:anim2:SyncTarget', function(target, animationLib, animation2, distans, distans2, height, length, spin, controlFlag)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	RequestAnimDict(animationLib)
	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
end)

RegisterNetEvent('MTJ_Carry:anim1:SyncTarget')
AddEventHandler('MTJ_Carry:anim1:SyncTarget', function(target, animationLib, animation2, distans, distans2, height, length, spin, controlFlag)
	local playerPed = PlayerPedId()
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	RequestAnimDict(animationLib)
	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	if spin == nil then spin = 180.0 end
	AttachEntityToEntity(PlayerPedId(), targetPed, 0, distans2, distans, height, 0.5, 0.5, spin, false, false, false, false, 2, false)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation2, 8.0, -8.0, length, controlFlag, 0, false, false, false)
end)

RegisterNetEvent('MTJ_Carry:anim2:Play')
AddEventHandler('MTJ_Carry:anim2:Play', function(animationLib, animation, length, controlFlag, animFlag)
	local playerPed = PlayerPedId()
	RequestAnimDict(animationLib)
	while not HasAnimDictLoaded(animationLib) do
		Citizen.Wait(10)
	end
	Wait(500)
	if controlFlag == nil then controlFlag = 0 end
	TaskPlayAnim(playerPed, animationLib, animation, 8.0, -8.0, length, controlFlag, 0, false, false, false)
	Citizen.Wait(length)
end)

RegisterNetEvent('MTJ_Carry:anim:clientstop')
AddEventHandler('MTJ_Carry:anim:clientstop', function()
	debugPrint('Trage-Animation gestoppt')
	carryingBackInProgress = false
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(PlayerPedId(), true, false)
end)

function GetPlayers()
	local players = {}
	for i = 0, 255 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end
	return players
end

function GetClosestPlayer(radius)
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)
	for index, value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	if closestDistance <= radius then
		return closestPlayer
	else
		return nil
	end
end

debugPrint('Client-Script geladen — Befehl: /' .. Config.command)
