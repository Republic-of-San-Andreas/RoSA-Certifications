-- [[ Github Update Configuration ]] --
DISCORD_WEBHOOK = ""
DISCORD_NAME = "RoSA - BAR EXAMS"
DISCORD_IMAGE = "https://cdn.discordapp.com/attachments/1026175982509506650/1026176123928842270/Lanzaned.png"

-- [[ Submission Logs ]] --
DISCORD_WEBHOOK_LOG = "https://ptb.discord.com/api/webhooks/1372862462382309438/4smu77APLM_TOlOHrsYYTXosHmyoCFqZapbDyyKQBrkjyZnBTwdemr61wZQZr1bpTx46"

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

JOB = {
    -- Format: [jobName] = minimum required grade
    ALLOWED_JOBS = {
        trooper = 0,
        police = 5,
        sheriff = 5,
        firedept = 4,
        saems = 3
    }
}

LICENSE_NAMES = {
    opt1 = { id = "service_taser", label = "X26 Taser" },
    opt2 = { id = "service_pistol", label = "Glock 19" },
    opt3 = { id = "service_shotgun", label = "M-590" },
    opt4 = { id = "service_rifle", label = "Sig Spear LT" },
    opt5 = { id = "service_sniper", label = "Remington 700" },
    opt6 = { id = "service_pdw", label = "Kratos Vector Recoil" },
    opt7 = { id = "service_40mm", label = "40mm Beanbag Launcher" },
    opt8 = { id = "swat", label = "S.W.A.T. Arsenal" },
}

