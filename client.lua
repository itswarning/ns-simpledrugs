local spawnedPlants = {}
local isHarvesting = false

local function spawnPlant(id, data)
    if spawnedPlants[id] and DoesEntityExist(spawnedPlants[id]) then
        return
    end

    -- get the model so the game has it loaded before CreatObject
    lib.requestModel(Config.PlantModel)
    local coords = vec3(data.x, data.y, data.z)

    -- make the plant prop locally and freeze it in place
    local plant = CreateObject(Config.PlantModel, coords.x, coords.y, coords.z - 1, false, false, false)
    SetEntityHeading(plant, data.w)
    FreezeEntityPosition(plant, true)
    SetEntityAsMissionEntity(plant, true, true)

    spawnedPlants[id] = plant

    exports.ox_target:addLocalEntity(plant, {
        {
            label = Config.TargetLabel,
            icon = Config.TargetIcon,
            onSelect = function()
                if isHarvesting then return end
                isHarvesting = true

                local ok = lib.progressCircle({
                    duration = Config.HarvestTimeMs,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        move = true,
                        car = true,
                        combat = true
                    },
                    anim = {
                        dict = 'amb@world_human_gardener_plant@male@base',
                        clip = 'base'
                    }
                })

                if ok then
                    -- give item to player once harvested (s-side is authorative)
                    TriggerServerEvent('ns-simpledrugs:harvestPlant', id, coords)

                    -- remove prop locally
                    DeleteEntity(plant)
                    spawnedPlants[id] = nil

                    -- respawn after a delay
                    SetTimeout(Config.RespawnTimeMs, function()
                        spawnPlant(id, data)
                    end)
                end
                isHarvesting = false
            end
        }
    })
end

-- spawn all plants from the config on client start
CreateThread(function()
    for i = 1, #Config.Plants do
        spawnPlant(i, Config.Plants[i])
    end
end)

-- draw a marker above each plant pos
CreateThread(function ()
    while true do
        Wait(0)
        for i = 1, #Config.Plants do
            local p = Config.Plants[i]
            DrawMarker(
                2,
                p.x, p.y, p.z + 0.2,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                0.25, 0.25, 0.25,
                20, 200, 120, 160,
                false, true, 2, false, nil, nil, false
            )
        end
    end
end)