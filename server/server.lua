--[[
    MTJ_Carry — Server-Script
    (c) 2024 MTJ2024 — Alle Rechte vorbehalten
]]

local function debugPrint(msg)
	print('[MTJ_Carry:Server] ' .. tostring(msg))
end

debugPrint('Server-Script wird geladen...')

local ESX = nil
local initOk, initErr = pcall(function()
	ESX = exports["es_extended"]:getSharedObject()
end)
if not initOk then
	debugPrint('FEHLER: ESX Init fehlgeschlagen: ' .. tostring(initErr))
else
	debugPrint('ESX geladen')
end

RegisterServerEvent('MTJ_Carry:anim1:Sync')
AddEventHandler('MTJ_Carry:anim1:Sync', function(target, animationLib, animationLib2, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget)
	debugPrint('anim1:Sync von ' .. tostring(source) .. ' Ziel=' .. tostring(targetSrc))
	if target ~= -1 then
	    TriggerClientEvent('MTJ_Carry:anim1:SyncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget)
	end
end)

RegisterServerEvent('MTJ_Carry:anim2:Sync')
AddEventHandler('MTJ_Carry:anim2:Sync', function(target, animationLib, animation, animation2, distans, distans2, height, targetSrc, length, spin, controlFlagSrc, controlFlagTarget, animFlagTarget)
	debugPrint('anim2:Sync von ' .. tostring(source) .. ' Ziel=' .. tostring(targetSrc))
	if target ~= -1 then
	    TriggerClientEvent('MTJ_Carry:anim2:SyncTarget', targetSrc, source, animationLib, animation2, distans, distans2, height, length, spin, controlFlagTarget, animFlagTarget)
	    TriggerClientEvent('MTJ_Carry:anim2:Play', source, animationLib, animation, length, controlFlagSrc, animFlagTarget)
	end
end)

RegisterServerEvent('MTJ_Carry:onhandanim')
AddEventHandler('MTJ_Carry:onhandanim', function(target)
	debugPrint('onhandanim von ' .. tostring(source) .. ' Ziel=' .. tostring(target))
	local ok, err = pcall(function()
		local targetPlayer = ESX.GetPlayerFromId(target)
		TriggerClientEvent('MTJ_Carry:onhandanimcarry', targetPlayer.source, source)
	end)
	if not ok then
		debugPrint('FEHLER in onhandanim: ' .. tostring(err))
	end
end)

RegisterServerEvent('MTJ_Carry:anim:stop')
AddEventHandler('MTJ_Carry:anim:stop', function(targetSrc)
	debugPrint('Anim:stop von ' .. tostring(source) .. ' Ziel=' .. tostring(targetSrc))
	TriggerClientEvent('MTJ_Carry:anim:clientstop', targetSrc)
end)

---------[ANFRAGE]---------
RegisterServerEvent("MTJ_Carry:animrequest")
AddEventHandler("MTJ_Carry:animrequest", function(target, reqstcarryanim)
	debugPrint('Anfrage von ' .. tostring(source) .. ' an ' .. tostring(target) .. ' Typ=' .. tostring(reqstcarryanim))
	local sender = source
	TriggerClientEvent("MTJ_Carry:receiverequest", target, sender, reqstcarryanim)
end)

RegisterServerEvent("MTJ_Carry:animationaccepted")
AddEventHandler("MTJ_Carry:animationaccepted", function(target, reqstcarryanim)
	debugPrint('Animation angenommen von ' .. tostring(source) .. ' Ziel=' .. tostring(target))
	local player2 = source
	TriggerClientEvent("MTJ_Carry:playsharedsource", target, reqstcarryanim, player2)
end)

RegisterServerEvent("MTJ_Carry:animationdenied")
AddEventHandler("MTJ_Carry:animationdenied", function(source)
	debugPrint('Animation abgelehnt von ' .. tostring(source))
	local ok, err = pcall(function()
		local xPlayer = ESX.GetPlayerFromId(source)
		Notify("Deine Anfrage wurde abgelehnt", 'error', true, source)
	end)
	if not ok then
		debugPrint('FEHLER in animationdenied: ' .. tostring(err))
	end
end)

debugPrint('Server-Script geladen')
