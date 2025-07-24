local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("RoSA-Certifications:Client:RequestPlayerList", function()
    TriggerServerEvent("RoSA-Certifications:Server:RequestPlayerList")
end)

RegisterNetEvent("RoSA-Certifications:Client:openUIWithLicenses", function(data)
    SendNUIMessage(data)
end)

RegisterNUICallback("SubmitSelection", function(data)
    TriggerServerEvent("RoSA-Certifications:Server:SetPlayerMetadata", data.targetId, data.options)
end)

RegisterNUICallback("closeUI", function()
    ExecuteCommand("e c")
    SetNuiFocus(false, false)
end)

RegisterNetEvent("RoSA-Certifications:Client:OpenUI", function(players)
    ExecuteCommand("e tablet")

    QBCore.Functions.TriggerCallback("RoSA-Certifications:Callback:GetLicenseList", function(data)
        SendNUIMessage({
            type = "openUI",
            players = players,
            licenseList = data
        })

        SetNuiFocus(true, true)
    end)
end)