local QBCore = exports['qb-core']:GetCoreObject()

local function HAS_JOB_ACCESS(Player)
    if not Player then return end
    if JOB.ALLOWED_JOBS[Player.PlayerData.job.name] and Player.PlayerData.job.grade.level >= JOB.ALLOWED_JOBS[Player.PlayerData.job.name] then
        return true
    end
    return false
end

RegisterNetEvent("RoSA-Certifications:Server:RequestPlayerList", function()
    local src = source
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(tonumber(id))
        if player then
            local job = player.PlayerData.job.type
            if job == "leo" or job == "ems" or job == "fire" then
                local metadata = player.PlayerData.metadata or {}
                local firstname = player.PlayerData.charinfo.firstname or "Unknown"
                local lastname = player.PlayerData.charinfo.lastname or "Unknown"
                local callsign = metadata.callsign or "000"
                table.insert(players, {
                    id = tonumber(id),
                    name = string.format("(%d) | [%s] %s %s", id, callsign, firstname, lastname),
                    job = job,
                    licenses = metadata.licences or {}
                })
            end
        end
    end

    TriggerClientEvent("RoSA-Certifications:Client:OpenUI", src, players)
end)

QBCore.Functions.CreateCallback("RoSA-Certifications:Callback:GetLicenseList", function(source, cb, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    cb(LICENSE_NAMES)
end)

-- Grant/Revoke Logic
RegisterNetEvent("RoSA-Certifications:Server:SetPlayerMetadata", function(targetId, options)
    local src = source
    local SearchedPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if not SearchedPlayer then return TriggerClientEvent('QBCore:Notify', src, "Player not found", "error") end

    local licenseTable = SearchedPlayer.PlayerData.metadata["licences"] or {}
    local granted, revoked, invalid = {}, {}, {}

    for key, value in pairs(options) do
        local license = LICENSE_NAMES[key] and LICENSE_NAMES[key].id
        if license then
            if value and not licenseTable[license] then
                licenseTable[license] = true
                table.insert(granted, license)
            elseif not value and licenseTable[license] then
                licenseTable[license] = nil
                table.insert(revoked, license)
            end
        else
            table.insert(invalid, key)
            print("Invalid license key:", key)
        end
    end

    SearchedPlayer.Functions.SetMetaData("licences", licenseTable)

    local sourceName = GetPlayerName(src)
    local targetName = GetPlayerName(SearchedPlayer.PlayerData.source)

    if #granted > 0 then
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source,
            ("You received: %s"):format(table.concat(granted, ", ")), "success")
        TriggerClientEvent('QBCore:Notify', src, ("Granted: %s"):format(table.concat(granted, ", ")), "success")
    end
    if #revoked > 0 then
        TriggerClientEvent('QBCore:Notify', SearchedPlayer.PlayerData.source,
            ("Revoked: %s"):format(table.concat(revoked, ", ")), "error")
        TriggerClientEvent('QBCore:Notify', src, ("Revoked: %s"):format(table.concat(revoked, ", ")), "error")
    end
    if #invalid > 0 then
        TriggerClientEvent('QBCore:Notify', src, ("Invalid: %s"):format(table.concat(invalid, ", ")), "error")
    end

    SendLicenseLogToDiscord(sourceName, targetName, targetId, granted, revoked)
end)

-- Discord Logging
function SendLicenseLogToDiscord(modBy, tgtName, tgtId, granted, revoked)
    if not DISCORD_WEBHOOK_LOG then return end

    local embed = { {
        ["color"] = 3447003,
        ["title"] = "License Modification",
        ["description"] = string.format("Modified by: **%s**\nTarget: **%s [%d]**", modBy, tgtName, tgtId),
        ["fields"] = {},
        ["footer"] = { ["text"] = "License Logger" },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
    } }

    if #granted > 0 then
        table.insert(embed[1].fields, { name = "✅ Granted", value = table.concat(granted, ", "), inline = true })
    end
    if #revoked > 0 then
        table.insert(embed[1].fields, { name = "❌ Revoked", value = table.concat(revoked, ", "), inline = true })
    end

    PerformHttpRequest(DISCORD_WEBHOOK_LOG, function() end, "POST", json.encode({
        username = "License Logger",
        embeds = embed
    }), { ["Content-Type"] = "application/json" })
end


if not ITEM.USE_ITEM then
    QBCore.Commands.Add(COMMAND.COMMAND_NAME, COMMAND.COMMAND_DESCRIPTION, {}, false, function(source, args)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end
        if HAS_JOB_ACCESS(Player) then
            TriggerClientEvent("RoSA-Certifications:Client:RequestPlayerList", src)
        else
            TriggerClientEvent('QBCore:Notify', src, "You are not a supervisor or a member of the Unified Police Department!", "error")
        end
    end, 'user')
else
    QBCore.Functions.CreateUseableItem(ITEM.ITEM_NAME, function(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end
        if ITEM.USE_JOB_PROTECTION then
            if HAS_JOB_ACCESS(Player) then
                TriggerClientEvent("RoSA-Certifications:Client:RequestPlayerList", src)
            end
        else
            TriggerClientEvent("RoSA-Certifications:Client:RequestPlayerList", src)
        end
    end)
end