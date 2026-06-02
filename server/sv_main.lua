local QBCore = exports['qb-core']:GetCoreObject()

local function IsMDTEnabled()
    if not MDT or MDT.ENABLED ~= true then
        return false
    end

    local resourceName = MDT.RESOURCE or "vx_mdt"
    return GetResourceState(resourceName) == "started"
end

local function HAS_JOB_ACCESS(Player)
    if not Player then return false end

    local job = Player.PlayerData.job or {}
    local jobName = tostring(job.name or ""):lower()
    local grade = job.grade or {}
    local gradeLevel = tonumber(grade.level) or 0

    if not JOB or not JOB.ALLOWED_JOBS then
        return false
    end

    local minGrade = JOB.ALLOWED_JOBS[jobName]

    if minGrade and gradeLevel >= minGrade then
        return true
    end

    return false
end

local function safeDecodeArray(raw)
    if type(raw) == "table" then
        return raw
    end

    if not raw or raw == "" then
        return {}
    end

    local ok, decoded = pcall(json.decode, raw)

    if not ok or type(decoded) ~= "table" then
        return {}
    end

    return decoded
end

local function notify(source, message, msgType)
    TriggerClientEvent("QBCore:Notify", source, message, msgType or "primary")
end

local function getPlayerFromTargetId(targetId)
    return QBCore.Functions.GetPlayer(tonumber(targetId))
end

local function getCitizenIdFromTargetId(targetId)
    local Player = getPlayerFromTargetId(targetId)

    if not Player then
        return nil, nil
    end

    return Player.PlayerData.citizenid, Player
end

local function getProfileDepartmentType(Player)
    if not Player then return nil end

    local job = Player.PlayerData.job or {}
    local jobName = tostring(job.name or ""):lower()
    local jobType = tostring(job.type or ""):lower()

    if jobType == "leo" then
        return "law"
    end

    if jobType == "ems" or jobType == "fire" then
        return "ems"
    end

    if jobName == "doj" or jobName == "judge" or jobType == "government" then
        return "judge"
    end

    return nil
end

local function getProfileIdentifierAndDepartment(targetId)
    local Player = getPlayerFromTargetId(targetId)

    if not Player then
        return nil, nil, nil
    end

    local identifier = Player.PlayerData.citizenid
    local depType = getProfileDepartmentType(Player)

    return identifier, depType, Player
end

local function getStaffDepartmentId(Player)
    if not Player then return nil end

    local job = Player.PlayerData.job or {}
    local jobName = tostring(job.name or ""):lower()

    if not DEPARTMENT_IDS then
        return nil
    end

    return DEPARTMENT_IDS[jobName]
end

local function hasTag(tags, title, color)
    for i = 1, #tags do
        local tag = tags[i]

        if type(tag) == "table"
            and tostring(tag.title or "") == tostring(title)
            and string.upper(tostring(tag.color or "")) == string.upper(tostring(color or "")) then
            return true
        end
    end

    return false
end

local function removeTag(tags, title, color)
    local filtered = {}

    for i = 1, #tags do
        local tag = tags[i]

        local isMatch = type(tag) == "table"
            and tostring(tag.title or "") == tostring(title)
            and string.upper(tostring(tag.color or "")) == string.upper(tostring(color or ""))

        if not isMatch then
            filtered[#filtered + 1] = tag
        end
    end

    return filtered
end

local function sendDiscordLog(title, color, description, fields)
    if not DISCORD_WEBHOOK_LOG or DISCORD_WEBHOOK_LOG == "" then return end

    local embed = {{
        color = color or 3447003,
        title = title or "Personnel Modification",
        description = description or "No description provided",
        fields = fields or {},
        footer = {
            text = "RoSA Personnel Logger"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}

    PerformHttpRequest(DISCORD_WEBHOOK_LOG, function() end, "POST", json.encode({
        username = "RoSA Personnel Logger",
        embeds = embed
    }), {
        ["Content-Type"] = "application/json"
    })
end

local function SendLicenseLogToDiscord(modBy, tgtName, tgtId, granted, revoked)
    local fields = {}

    if #granted > 0 then
        fields[#fields + 1] = {
            name = "✅ Granted",
            value = table.concat(granted, ", "),
            inline = true
        }
    end

    if #revoked > 0 then
        fields[#fields + 1] = {
            name = "❌ Revoked",
            value = table.concat(revoked, ", "),
            inline = true
        }
    end

    if #fields < 1 then
        return
    end

    sendDiscordLog(
        "Certificate Modification",
        3447003,
        string.format(
            "Modified by: **%s**\nTarget: **%s [%s]**",
            modBy or "Unknown",
            tgtName or "Unknown",
            tostring(tgtId or "N/A")
        ),
        fields
    )
end

local function SendAwardLogToDiscord(modBy, tgtName, tgtId, granted, revoked)
    local fields = {}

    if #granted > 0 then
        fields[#fields + 1] = {
            name = "🏅 Granted",
            value = table.concat(granted, ", "),
            inline = true
        }
    end

    if #revoked > 0 then
        fields[#fields + 1] = {
            name = "🗑️ Revoked",
            value = table.concat(revoked, ", "),
            inline = true
        }
    end

    if #fields < 1 then
        return
    end

    sendDiscordLog(
        "Award Modification",
        10181046,
        string.format(
            "Modified by: **%s**\nTarget: **%s [%s]**",
            modBy or "Unknown",
            tgtName or "Unknown",
            tostring(tgtId or "N/A")
        ),
        fields
    )
end

local function getPlayerAwards(identifier, depType)
    if not IsMDTEnabled() then
        return {}
    end

    if not identifier or not depType then
        return {}
    end

    local row = MySQL.single.await([[
        SELECT tags
        FROM vx_mdt_profile_records
        WHERE identifier = ? AND dep_type = ?
        LIMIT 1
    ]], {
        identifier,
        depType
    })

    if not row then
        return {}
    end

    return safeDecodeArray(row.tags)
end

local function BuildOnlinePlayerList()
    local players = {}

    for _, id in ipairs(GetPlayers()) do
        local player = QBCore.Functions.GetPlayer(tonumber(id))

        if player then
            local playerData = player.PlayerData or {}
            local job = playerData.job or {}
            local jobType = tostring(job.type or ""):lower()
            local metadata = playerData.metadata or {}
            local charinfo = playerData.charinfo or {}

            local firstname = charinfo.firstname or "Unknown"
            local lastname = charinfo.lastname or "Unknown"
            local callsign = metadata.callsign or "000"
            local identifier = playerData.citizenid
            local depType = getProfileDepartmentType(player)
            local awards = getPlayerAwards(identifier, depType)

            if jobType == "leo" or jobType == "ems" or jobType == "fire" then
                players[#players + 1] = {
                    id = tonumber(id),
                    name = string.format("(%d) | [%s] %s %s", tonumber(id), callsign, firstname, lastname),
                    job = jobType,
                    licenses = metadata.licences or {},
                    awards = awards
                }
            elseif jobType == "government" then
                players[#players + 1] = {
                    id = tonumber(id),
                    name = string.format("(%d) | %s %s", tonumber(id), firstname, lastname),
                    job = jobType,
                    licenses = metadata.licences or {},
                    awards = awards
                }
            end
        end
    end

    return players
end

local function getMDTStaffCertificates(citizenId, Player)
    if not IsMDTEnabled() then
        return {}, nil
    end

    local departmentId = getStaffDepartmentId(Player)

    if not departmentId then
        return nil, nil, "Target does not have a valid MDT staff department"
    end

    local row = MySQL.single.await([[
        SELECT identifier, department_id, certificates
        FROM vx_mdt_staff
        WHERE identifier = ? AND department_id = ?
        LIMIT 1
    ]], {
        citizenId,
        departmentId
    })

    if not row then
        return nil, nil, ("No MDT staff record found for %s (department %s)"):format(citizenId, departmentId)
    end

    return safeDecodeArray(row.certificates), departmentId, nil
end

local function saveMDTStaffCertificates(citizenId, departmentId, certificates)
    if not IsMDTEnabled() then
        return true
    end

    local updated = MySQL.update.await([[
        UPDATE vx_mdt_staff
        SET certificates = ?
        WHERE identifier = ? AND department_id = ?
    ]], {
        json.encode(certificates),
        citizenId,
        departmentId
    })

    return updated and updated > 0
end

function HandleCertificateSelection(src, targetId, options)
    local citizenId, SearchedPlayer = getCitizenIdFromTargetId(targetId)

    if not citizenId or not SearchedPlayer then
        return notify(src, "Player not found", "error")
    end

    local playerData = SearchedPlayer.PlayerData or {}
    local metadata = playerData.metadata or {}
    local metadataLicences = metadata.licences or {}

    local staffCertificates, departmentId, mdtError = getMDTStaffCertificates(citizenId, SearchedPlayer)

    if mdtError then
        return notify(src, mdtError, "error")
    end

    staffCertificates = staffCertificates or {}

    local granted, revoked, invalid = {}, {}, {}

    for key, selected in pairs(options or {}) do
        local cert = LICENSE_NAMES and LICENSE_NAMES[key] or nil

        if cert and cert.id then
            local certId = cert.id
            local certLabel = cert.label or cert.id
            local certTitle = cert.title or certLabel
            local certColor = cert.color or "#22C55E"

            if selected then
                if not metadataLicences[certId] then
                    metadataLicences[certId] = true
                    granted[#granted + 1] = certLabel
                end

                if IsMDTEnabled() and not hasTag(staffCertificates, certTitle, certColor) then
                    staffCertificates[#staffCertificates + 1] = {
                        title = certTitle,
                        color = certColor
                    }
                end
            else
                if metadataLicences[certId] then
                    metadataLicences[certId] = nil
                    revoked[#revoked + 1] = certLabel
                end

                if IsMDTEnabled() then
                    staffCertificates = removeTag(staffCertificates, certTitle, certColor)
                end
            end
        else
            invalid[#invalid + 1] = tostring(key)
            print(("[RoSA-Certifications] Invalid certificate key: %s"):format(tostring(key)))
        end
    end

    SearchedPlayer.Functions.SetMetaData("licences", metadataLicences)

    if IsMDTEnabled() then
        local saved = saveMDTStaffCertificates(citizenId, departmentId, staffCertificates)

        if not saved then
            return notify(src, "Failed to update MDT certificates", "error")
        end
    end

    local sourceName = GetPlayerName(src) or ("Player %s"):format(src)
    local targetName = GetPlayerName(SearchedPlayer.PlayerData.source) or citizenId

    if #granted > 0 then
        notify(SearchedPlayer.PlayerData.source, ("You received: %s"):format(table.concat(granted, ", ")), "success")
        notify(src, ("Granted: %s"):format(table.concat(granted, ", ")), "success")
    end

    if #revoked > 0 then
        notify(SearchedPlayer.PlayerData.source, ("Revoked: %s"):format(table.concat(revoked, ", ")), "error")
        notify(src, ("Revoked: %s"):format(table.concat(revoked, ", ")), "error")
    end

    if #invalid > 0 then
        notify(src, ("Invalid: %s"):format(table.concat(invalid, ", ")), "error")
    end

    if #granted < 1 and #revoked < 1 and #invalid < 1 then
        notify(src, "No certificate changes were made.", "primary")
    end

    SendLicenseLogToDiscord(sourceName, targetName, targetId, granted, revoked)
end

function HandleAwardSelection(src, targetId, options)
    if not IsMDTEnabled() then
        return notify(src, "Awards require MDT integration to be enabled.", "error")
    end

    local identifier, depType, SearchedPlayer = getProfileIdentifierAndDepartment(targetId)

    if not identifier or not SearchedPlayer then
        return notify(src, "Target not found", "error")
    end

    if not depType then
        return notify(src, "Target does not have a valid MDT department type", "error")
    end

    local row = MySQL.single.await([[
        SELECT identifier, dep_type, tags
        FROM vx_mdt_profile_records
        WHERE identifier = ? AND dep_type = ?
        LIMIT 1
    ]], {
        identifier,
        depType
    })

    if not row then
        return notify(src, ("No MDT profile found for %s (%s)"):format(identifier, depType), "error")
    end

    local tags = safeDecodeArray(row.tags)
    local granted, revoked, invalid = {}, {}, {}

    for key, selected in pairs(options or {}) do
        local award = AWARD_NAMES and AWARD_NAMES[key] or nil

        if award then
            local title = award.title or award.id or award.label
            local color = award.color or "#F59E0B"

            if selected then
                if not hasTag(tags, title, color) then
                    tags[#tags + 1] = {
                        title = title,
                        color = color
                    }

                    granted[#granted + 1] = title
                end
            else
                local before = #tags
                tags = removeTag(tags, title, color)

                if #tags < before then
                    revoked[#revoked + 1] = title
                end
            end
        else
            invalid[#invalid + 1] = tostring(key)
            print(("[RoSA-Certifications] Invalid award key: %s"):format(tostring(key)))
        end
    end

    local updated = MySQL.update.await([[
        UPDATE vx_mdt_profile_records
        SET tags = ?
        WHERE identifier = ? AND dep_type = ?
    ]], {
        json.encode(tags),
        identifier,
        depType
    })

    if not updated or updated < 1 then
        return notify(src, "Failed to update awards", "error")
    end

    local sourceName = GetPlayerName(src) or ("Player %s"):format(src)
    local targetName = GetPlayerName(SearchedPlayer.PlayerData.source) or identifier

    if #granted > 0 then
        notify(src, ("Granted awards: %s"):format(table.concat(granted, ", ")), "success")
        notify(SearchedPlayer.PlayerData.source, ("You received awards: %s"):format(table.concat(granted, ", ")), "success")
    end

    if #revoked > 0 then
        notify(src, ("Revoked awards: %s"):format(table.concat(revoked, ", ")), "error")
        notify(SearchedPlayer.PlayerData.source, ("Awards revoked: %s"):format(table.concat(revoked, ", ")), "error")
    end

    if #invalid > 0 then
        notify(src, ("Invalid: %s"):format(table.concat(invalid, ", ")), "error")
    end

    if #granted < 1 and #revoked < 1 and #invalid < 1 then
        notify(src, "No award changes were made.", "primary")
    end

    SendAwardLogToDiscord(sourceName, targetName, targetId, granted, revoked)
end

RegisterNetEvent("RoSA-Certifications:Server:RequestPlayerList", function(mode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if not HAS_JOB_ACCESS(Player) then
        return notify(src, "You are not authorized to manage personnel certifications.", "error")
    end

    mode = tostring(mode or "certificates"):lower()

    if mode == "awards" and not IsMDTEnabled() then
        return notify(src, "Awards require MDT integration to be enabled.", "error")
    end

    local players = BuildOnlinePlayerList()

    TriggerClientEvent("RoSA-Certifications:Client:OpenUI", src, players, mode)
end)

QBCore.Functions.CreateCallback("RoSA-Certifications:Callback:GetLicenseList", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return cb({})
    end

    cb(LICENSE_NAMES or {})
end)

QBCore.Functions.CreateCallback("RoSA-Certifications:Callback:GetAwardList", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return cb({})
    end

    if not IsMDTEnabled() then
        return cb({})
    end

    cb(AWARD_NAMES or {})
end)

RegisterNetEvent("RoSA-Certifications:Server:SubmitSelection", function(mode, targetId, options)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if not HAS_JOB_ACCESS(Player) then
        return notify(src, "You do not have permission to modify personnel records.", "error")
    end

    mode = tostring(mode or "certificates"):lower()

    if mode == "awards" then
        HandleAwardSelection(src, targetId, options)
    elseif mode == "certificates" then
        HandleCertificateSelection(src, targetId, options)
    else
        notify(src, "Invalid mode", "error")
    end
end)

-- Backwards compatibility for old client flow.
RegisterNetEvent("RoSA-Certifications:Server:SetPlayerMetadata", function(targetId, options)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    if not HAS_JOB_ACCESS(Player) then
        return notify(src, "You do not have permission to modify personnel records.", "error")
    end

    HandleCertificateSelection(src, targetId, options)
end)

if not ITEM.USE_ITEM then
    QBCore.Commands.Add(COMMAND.COMMAND_NAME, COMMAND.COMMAND_DESCRIPTION, {
        {
            name = "mode",
            help = "certificates or awards"
        }
    }, false, function(source, args)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)

        if not Player then return end

        if not HAS_JOB_ACCESS(Player) then
            return notify(src, "You are not authorized to manage personnel certifications.", "error")
        end

        local mode = tostring(args[1] or "certificates"):lower()

        if mode ~= "certificates" and mode ~= "awards" then
            mode = "certificates"
        end

        if mode == "awards" and not IsMDTEnabled() then
            return notify(src, "Awards require MDT integration to be enabled.", "error")
        end

        TriggerClientEvent("RoSA-Certifications:Client:RequestPlayerList", src, mode)
    end, "user")
else
    QBCore.Functions.CreateUseableItem(ITEM.ITEM_NAME, function(source)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)

        if not Player then return end

        if ITEM.USE_JOB_PROTECTION then
            if not HAS_JOB_ACCESS(Player) then
                return notify(src, "You are not authorized to use this tablet.", "error")
            end
        end

        TriggerClientEvent("RoSA-Certifications:Client:RequestPlayerList", src, "certificates")
    end)
end
