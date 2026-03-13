Config = {}

Config.Drugs = {
  weed = {
    PlantModel = `prop_weed_01`,
    HarvestItem = 'weed_bud',
    HarvestAmount = 10,
    HarvestTimeMs = 3500,
    RespawnTimeMs = 5 * 60 * 1000,
    TargetLabel = 'Harvest Weed',
    TargetIcon = 'fa-solid fa-cannabis',
    Count = 5,
    Position = vector4(2224.78, 5576.38, 53.83, 15.0),
    Radius = 5
  },

  coca = {
    PlantModel = `prop_plant_cane_01a`,
    HarvestItem = 'coke_leaf',
    HarvestAmount = 6,
    HarvestTimeMs = 4000,
    RespawnTimeMs = 7 * 60 * 1000,
    TargetLabel = 'Harvest Coca',
    TargetIcon = 'fa-solid fa-leaf',
    Count = 5,
    Position = vector4(2224.78, 5576.38, 53.83, 15.0),
    Radius = 5
  }
}

Config.Logging = false
Config.WebHookURL = 'WEBHOOK_URL_HERE'