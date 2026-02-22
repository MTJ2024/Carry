Config = {}

Config = {
    Time        = 0.3,
    command     = 'carry',
    acceptkey   = 246 ,
    declinekey  = 182 ,
    requestmessage = "Y to accept, L to refuse",
}

Notify = function(text, msgtype, IsServer, src)
    if IsServer then
        TriggerClientEvent('SY_Carry:notify', src or source, text, msgtype)
    else
        SendNUIMessage({
            message  = 'showNotify',
            text     = text,
            msgtype  = msgtype or 'info',
            duration = 5000
        })
    end
end