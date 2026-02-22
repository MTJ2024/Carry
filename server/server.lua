local function debugPrint(msg)
	print('[SY_Carry:Server] ' .. tostring(msg))
end

debugPrint('Server script loading...')

local ESX = nil
local initOk, initErr = pcall(function()
	ESX = exports["es_extended"]:getSharedObject()
end)
if not initOk then
	debugPrint('ERROR: ESX init failed: ' .. tostring(initErr))
else
	debugPrint('ESX loaded OK')
end

RegisterServerEvent('SY_Carry_anim1:server:Sync')
AddEventHandler('SY_Carry_anim1:server:Sync', function(target, animationLib,animationLib2, animation, animation2, distans, distans2, height,targetSrc,length,spin,controlFlagSrc,controlFlagTarget,animFlagTarget)
	debugPrint('anim1:Sync from ' .. tostring(source) .. ' target=' .. tostring(targetSrc))
	if target ~= -1  then
	    TriggerClientEvent('SY_Carry_anim1:SyncTarget', targetSrc, source, animationLib2, animation2, distans, distans2, height, length,spin,controlFlagTarget,animFlagTarget)
	end
end)

RegisterServerEvent('SY_Carry_anim2:server:Sync')
AddEventHandler('SY_Carry_anim2:server:Sync', function(target, animationLib, animation, animation2, distans, distans2, height,targetSrc,length,spin,controlFlagSrc,controlFlagTarget,animFlagTarget)
	debugPrint('anim2:Sync from ' .. tostring(source) .. ' target=' .. tostring(targetSrc))
	if target ~= -1  then
	    TriggerClientEvent('SY_Carry_anim2:SyncTarget', targetSrc, source, animationLib, animation2, distans, distans2, height, length,spin,controlFlagTarget,animFlagTarget)
	    TriggerClientEvent('SY_Carry_anim2:Sync', source, animationLib, animation,length,controlFlagSrc,animFlagTarget)
	end
end)

RegisterServerEvent('SY_Carry:onhandanim')
AddEventHandler('SY_Carry:onhandanim', function(target)
	debugPrint('onhandanim from ' .. tostring(source) .. ' target=' .. tostring(target))
	local ok, err = pcall(function()
		local targetPlayer = ESX.GetPlayerFromId(target)
		TriggerClientEvent('SY_Carry:onhandanimcarry', targetPlayer.source, source)
	end)
	if not ok then
		debugPrint('ERROR in onhandanim: ' .. tostring(err))
	end
end)

RegisterServerEvent('SY_Carry_Anim:stop')
AddEventHandler('SY_Carry_Anim:stop', function(targetSrc)
	debugPrint('Anim:stop from ' .. tostring(source) .. ' target=' .. tostring(targetSrc))
	TriggerClientEvent('SY_Carry_Anim:client:stop', targetSrc)
end)

---------[REQUEST]---------
RegisterServerEvent("SY_animations:animrequest")
AddEventHandler("SY_animations:animrequest", function(target,reqstcarryanim)
	debugPrint('animrequest from ' .. tostring(source) .. ' to ' .. tostring(target) .. ' type=' .. tostring(reqstcarryanim))
	local revicer = source 
	TriggerClientEvent("SY_animations:reciverrequest", target, revicer,reqstcarryanim)
end)

RegisterServerEvent("SY_animations:animationaccepted") 
AddEventHandler("SY_animations:animationaccepted", function(target,reqstcarryanim)
	debugPrint('animationaccepted from ' .. tostring(source) .. ' target=' .. tostring(target))
	local player2 = source
	TriggerClientEvent("SY_animations:playsharedsource", target,reqstcarryanim, player2) 
end)

RegisterServerEvent("SY_animations:animationdenied") 
AddEventHandler("SY_animations:animationdenied", function(source)
	debugPrint('animationdenied from ' .. tostring(source))
	local ok, err = pcall(function()
		local xPlayer = ESX.GetPlayerFromId(source)
		Notify("Your Request Has Been Denied",'error',true,source)
	end)
	if not ok then
		debugPrint('ERROR in animationdenied: ' .. tostring(err))
	end
end)

debugPrint('Server script loaded OK')
