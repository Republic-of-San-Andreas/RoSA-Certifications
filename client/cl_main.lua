local QBCore = exports['qb-core']:GetCoreObject()

local isOpen = false

local function closeTablet()
    if not isOpen then return end

    isOpen = false
    ExecuteCommand("e c")
    SetNuiFocus(false, false)

    SendNUIMessage({
        type = "closeUI"
    })
end

RegisterNetEvent("RoSA-Certifications:Client:RequestPlayerList", function(mode)
    TriggerServerEvent("RoSA-Certifications:Server:RequestPlayerList", mode or "certificates")
end)

RegisterNetEvent("RoSA-Certifications:Client:openUIWithLicenses", function(data)
    isOpen = true
    SendNUIMessage(data)
    SetNuiFocus(true, true)
end)

RegisterNetEvent("RoSA-Certifications:Client:OpenUI", function(players, mode)
    isOpen = true
    ExecuteCommand("e tablet")

    local callbackName = mode == "awards"
        and "RoSA-Certifications:Callback:GetAwardList"
        or "RoSA-Certifications:Callback:GetLicenseList"

    QBCore.Functions.TriggerCallback(callbackName, function(data)
        SendNUIMessage({
            type = "openUI",
            mode = mode or "certificates",
            players = players or {},
            optionList = data or {}
        })

        SetNuiFocus(true, true)
    end)
end)

RegisterNUICallback("SubmitSelection", function(data, cb)
    if not data then
        if cb then cb(false) end
        return
    end

    TriggerServerEvent(
        "RoSA-Certifications:Server:SubmitSelection",
        data.mode or "certificates",
        data.targetId,
        data.options or {}
    )

    if cb then cb(true) end
end)

RegisterNUICallback("closeUI", function(_, cb)
    closeTablet()
    if cb then cb(true) end
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    closeTablet()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
end)