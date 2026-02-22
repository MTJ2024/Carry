--[[
    MTJ_Carry — Konfiguration
    (c) 2024 MTJ2024 — Alle Rechte vorbehalten
    https://github.com/MTJ2024/Carry

    PLAGIATSCHUTZ: Dieses Script ist urheberrechtlich geschuetzt.
    Unbefugtes Kopieren oder Verbreiten ist untersagt.
]]

Config = {}

Config = {
    Time        = 0.3,
    command     = 'carry',
    acceptkey   = 38,   -- E-Taste (INPUT_PICKUP) — gleich auf QWERTZ & QWERTY
    declinekey  = 73,   -- X-Taste (INPUT_VEH_DUCK) — gleich auf QWERTZ & QWERTY
}

Notify = function(text, msgtype, IsServer, src)
    if IsServer then
        TriggerClientEvent('MTJ_Carry:notify', src or source, text, msgtype)
    else
        SendNUIMessage({
            message  = 'showNotify',
            text     = text,
            msgtype  = msgtype or 'info',
            duration = 5000
        })
    end
end