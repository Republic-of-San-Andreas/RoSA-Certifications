-- [[ Github Update Configuration ]] --
DISCORD_WEBHOOK = ""
DISCORD_NAME = "RoSA - CERTIFICATIONS"
DISCORD_IMAGE = "https://cdn.discordapp.com/attachments/1026175982509506650/1026176123928842270/Lanzaned.png"

-- [[ Submission Logs ]] --
DISCORD_WEBHOOK_LOG = ""

ITEM = {
    USE_ITEM = false,
    -- If you wish to use item then set above to true!
    ITEM_NAME = "tablet",
    USE_JOB_PROTECTION = true -- Only allow registered jobs to access this system!
}

COMMAND = {
    COMMAND_NAME = "licenses",
    COMMAND_DESCRIPTION = "Open the Certification UI",
}

MDT = {
    ENABLED = true, -- true = sync to vx_mdt, false = only use QBCore metadata
    RESOURCE = "vx_mdt"
}

JOB = {
    -- Format: [jobName] = minimum required grade
    ALLOWED_JOBS = {
        doj = 18,
        dps = 4,
        trooper = 0,
        police = 5,
        sheriff = 5,
        firedept = 4,
        saems = 3
    }
}

DEPARTMENT_IDS = {
    police = 1,
    sheriff = 5,
    dps = 2,
    trooper = 2,

    saems = 4,
    firedept = 6,

    doj = 3,
    judge = 3
}

-- LICENSE_NAMES = {
--     -- opt1 = { id = "service_taser", label = "Coil C9", required = { "leo", "ems" } },
--     -- opt2 = { id = "service_pistol", label = "Service Pistol", required = { "leo", "ems" } },
--     -- opt4 = { id = "service_shotgun", label = "Tactical Shotgun", required = "leo" },
--     -- opt5 = { id = "service_rifle", label = "Carbine Rifle", required = "leo" },
--     -- opt7 = { id = "service_sniper", label = "COMING SOON!", required = "" },
--     -- opt8 = { id = "service_pdw", label = "COMING SOON!", required = "" },
--     -- opt9 = { id = "service_40mm", label = "40mm Beanbag Launcher", required = "leo" },
--     -- opt10 = { id = "swat", label = "Flashbang", required = "leo" },
--     -- opt11 = { id = "bar", label = "BAR", required = "government"}
-- }
LICENSE_NAMES = {
    opt1 = { id = "service_taser", label = "COIL C9", title = "COIL C9", color = "#22c55e", required = { "leo", "ems" } },
    opt2 = { id = "service_pistol", label = "Duty Pistol", title = "Duty Pistol", color = "#22c55e", required = { "leo", "ems" } },
    opt4 = { id = "service_shotgun", label = "Tactical Shotgun", title = "Tactical Shotgun", color = "#eab308", required = "leo" },
    opt5 = { id = "service_rifle", label = "Carbine Rifle", title = "Carbine Rifle", color = "#f97316", required = "leo" },
    opt9 = { id = "service_40mm", label = "40mm Beanbag Launcher", title = "40mm Beanbag Launcher", color = "#8b5cf6", required = "leo" },
    opt10 = { id = "swat", label = "Flashbang", title = "Flashbang", color = "#8b5cf6", required = "leo" },
    opt11 = { id = "bar", label = "BAR", title = "BAR", color = "#22c55e", required = "government" }
}

AWARD_NAMES = {
    award1 = { id = "Medal of Valor", label = "Medal of Valor", color = "#8B0000", required = { "leo", "ems", "fire" } },
    award2 = { id = "Distinguished Service Cross", label = "Distinguished Service Cross", color = "#B22222", required = { "leo", "ems", "fire" } },
    award3 = { id = "Purple Heart", label = "Purple Heart", color = "#800080", required = { "leo", "ems", "fire" } },
    award4 = { id = "Police Star", label = "Police Star", color = "#1E3A8A", required = { "leo", "ems", "fire" } },
    award5 = { id = "Medal of Bravery", label = "Medal of Bravery", color = "#2563EB", required = { "leo", "ems", "fire" } },
    award6 = { id = "Lifesaving Medal", label = "Lifesaving Medal", color = "#0EA5E9", required = { "leo", "ems", "fire" } },
    award7 = { id = "Meritorious Service Medal", label = "Meritorious Service Medal", color = "#1D4ED8", required = { "leo", "ems", "fire" } },
    award8 = { id = "Unit Citation", label = "Unit Citation", color = "#1E40AF", required = { "leo", "ems", "fire" } },
    award9 = { id = "Commendation Medal", label = "Commendation Medal", color = "#D4AF37", required = { "leo", "ems", "fire" } },
    award10 = { id = "Achievement Medal", label = "Achievement Medal", color = "#EAB308", required = { "leo", "ems", "fire" } },
    award11 = { id = "Investigative Excellence Award", label = "Investigative Excellence Award", color = "#F59E0B", required = { "leo", "ems", "fire" } },
    award12 = { id = "Tactical Excellence Award", label = "Tactical Excellence Award", color = "#CA8A04", required = { "leo", "ems", "fire" } },
    award13 = { id = "Good Conduct Medal", label = "Good Conduct Medal", color = "#166534", required = { "leo", "ems", "fire" } },
    award14 = { id = "Longevity Service Medal", label = "Longevity Service Medal", color = "#15803D", required = { "leo", "ems", "fire" } },
    award15 = { id = "Training Excellence Ribbon", label = "Training Excellence Ribbon", color = "#16A34A", required = { "leo", "ems", "fire" } },
    award16 = { id = "Field Training Officer Ribbon", label = "Field Training Officer Ribbon", color = "#22C55E", required = { "leo", "ems", "fire" } },
    award17 = { id = "Chief's Citation", label = "Chief's Citation", color = "#6B21A8", required = { "leo", "ems", "fire" } },
    award18 = { id = "Command Staff Commendation", label = "Command Staff Commendation", color = "#7C3AED", required = { "leo", "ems", "fire" } },
    award19 = { id = "Community Service Award", label = "Community Service Award", color = "#9333EA", required = { "leo", "ems", "fire" } },
    award20 = { id = "Crisis Response Medal", label = "Crisis Response Medal", color = "#8B5CF6", required = { "leo", "ems", "fire" } }
}