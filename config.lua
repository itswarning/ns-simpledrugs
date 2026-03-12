Config = {}

Config.PlantModel = `prop_weed_01` -- change to desired plant prop
Config.HarvestItem = 'weed_bud' -- change to desired item
Config.HarvestAmount = 10 -- amount given per harvest
Config.HarvestTimeMs = 3500 -- time in milliseconds to harvest
Config.RespawnTimeMs = 5 * 60 * 1000 -- time in ms to respawn (5 minutes default)

Config.TargetLabel = 'Harvest Weed' -- third eye label
Config.TargetIcon = 'fa-solid fa-cannabis' -- third eye icon

-- plant locations (vec4: x, y, z, heading)
Config.Plants = {
    vector4(2224.78, 5576.38, 53.83, 15.0),
    vector4(2227.12, 5578.44, 53.86, 120.0),
    vector4(2221.94, 5579.21, 53.80, 250.0)
}

-- Other
Config.Logging = true -- enable or disable webhook logging
Config.WebHookURL = 'WEBHOOK_URL_HERE' -- Webhook for logging purposes
