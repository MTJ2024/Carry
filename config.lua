Config = {}

Config = {
    Time        = 0.3,
    command     = 'carry',
    acceptkey   = 246 ,
    declinekey  = 182 ,
    requestmessage = "Y to accept, L to refuse",
}

Notify = function(text,msgtype,IsServer,src)
    local ok, err = pcall(function()
        if IsServer then
            TriggerClientEvent('SY_Notify:Alert', source, "CARRY", text, 5000, msgtype )
        else
            exports['SY_Notify']:Alert("Carry", text, 5000, msgtype)
        end
    end)
    if not ok then
        print('[SY_Carry] Notify error (SY_Notify not available?): ' .. tostring(err))
        if not IsServer then
            pcall(function()
                if ESX and ESX.ShowNotification then
                    ESX.ShowNotification(text)
                end
            end)
        end
    end
end