--[[ Version Checker ]] --
local version = "120"

local function SendDiscord(color, name, message, footer)
    local content = {
        {
            ["color"] = color,
            ["title"] = " " .. name .. " ",
            ["description"] = message,
            ["footer"] = {
                ["text"] = " " .. footer .. " ",
            },
        }
    }
    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 
    'POST', json.encode({
        username = DISCORD_NAME, 
        embeds = content, 
        avatar_url = DISCORD_IMAGE
    }), { ['Content-Type'] = 'application/json '})
end

local GITHUB_COMPANY = "Republic-of-San-Andreas"
local GITHUB_RESOURCE = "RoSA-VersionChecker"
local GITHUB_VERSION_FILE = "Certifications"

local function GithubPush()
    PerformHttpRequest("https://raw.githubusercontent.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."/main/"..GITHUB_VERSION_FILE..".txt", function(err, text, headers)
        if (tonumber(version) > tonumber(text)) then
            print(" ")
            print("---------- ROSA CERTIFICATIONS ----------")
            print("RoSA-Certifications is using a Development Build! Please download stable!")
            print("Curent Version: " .. version .. " Latest Version: " .. text)
            print("https://github.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."")
            print("-----------------------------------------")
            print(" ")
            SendDiscord(5242880, "ROSA CERTIFICATIONS | Update Checker", "RoSA-Certifications is using a Development Build! Please download stable!\nCurent Version: " .. version .. " Latest Version: " .. text .. "\nhttps://github.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."", "Script created by: https://rosa.lanzaned.com/fivem")
        elseif (tonumber(version) == tonumber(text)) then
            print(" ")
            print("---------- ROSA CERTIFICATIONS ----------")
            print("RoSA-Certifications is up to date and ready to go!")
            print("Running on Version: " .. version)
            print("https://github.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."")
            print("-----------------------------------------")
            print(" ")
            SendDiscord(20480, "ROSA CERTIFICATIONS | Update Checker", "RoSA-Bar is up to date and ready to go!\nRunning on Version: " .. version .. "\nhttps://github.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."", "Script created by: https://rosa.lanzaned.com/fivem")
        elseif (tonumber(version) < tonumber(text)) then
            print(" ")
            print("---------- ROSA CERTIFICATIONS ----------")
            print("RoSA-Certifications is not up to date! Please update!")
            print("Curent Version: " .. version .. " Latest Version: " .. text)
            print("https://github.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."")
            print("-----------------------------------------")
            print(" ")
            SendDiscord(5242880, "ROSA CERTIFICATIONS | Update Checker", "RoSA-Bar is not up to date! Please update!\nCurent Version: " .. version .. " Latest Version: " .. text .. "\nhttps://github.com/"..GITHUB_COMPANY.."/"..GITHUB_RESOURCE.."", "Script created by: https://rosa.lanzaned.com/fivem")
        end
    end, "GET", "", {})
end

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        GithubPush()
    end
end)