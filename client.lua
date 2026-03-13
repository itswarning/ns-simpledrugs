local spawnedPlants = {} -- spawnedPlants[drugkey][plantID] = entity
local isHarvesting = false

-- stats
local xpData = {
    xp = 0,
    level = 1,
    needed = 100
}
TriggerServerEvent('ns-simpledrugs:requestData')

local function spawnPlant(drugKey, id, data, drug)
    spawnedPlants[drugKey] = spawnedPlants[drugKey] or {}
    if spawnedPlants[drugKey][id] and DoesEntityExist(spawnedPlants[drugKey][id]) then
        return
    end

    -- get the model so the game has it loaded before CreatObject
    lib.requestModel(drug.PlantModel)
    local coords = vec3(data.x, data.y, data.z)

    local r = (drug.Radius or 5.0) * math.sqrt(math.random())
    local theta = math.random() * math.pi * 2

    local newCoords = vector3(
        coords.x + r * math.cos(theta),
        coords.y + r * math.cos(theta),
        coords.z
    )

    -- make the plant prop locally and freeze it in place
    local plant = CreateObject(drug.PlantModel, newCoords.x, newCoords.y, newCoords.z - 1, false, false, false)
    SetEntityHeading(plant, data.w)
    FreezeEntityPosition(plant, true)
    SetEntityAsMissionEntity(plant, true, true)

    spawnedPlants[drugKey][id] = plant

    exports.ox_target:addLocalEntity(plant, {
        {
            label = drug.TargetLabel,
            icon = drug.TargetIcon,
            onSelect = function()
                if isHarvesting then return end
                isHarvesting = true

                local ok = lib.progressCircle({
                    duration = drug.HarvestTimeMs,
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
                    TriggerServerEvent('ns-simpledrugs:harvestPlant', drugKey, id, newCoords)

                    -- remove prop locally
                    DeleteEntity(plant)
                    spawnedPlants[drugKey][id] = nil

                    -- respawn after a delay
                    SetTimeout(drug.RespawnTimeMs, function()
                        spawnPlant(drugKey, id, data, drug)
                    end)
                end
                if Config.Logging then
                    TriggerServerEvent('ns-simpledrugs:logHarvest', id, {
                        name = GetPlayerName(PlayerId()),
                        id = PlayerId(),
                        drug = drugKey
                    })
                end

                isHarvesting = false
            end
        }
    })
end

-- spawn all plants from the config on client start
CreateThread(function()
    for drugKey, drug in pairs(Config.Drugs) do
        for i = 1, drug.Count do
            spawnPlant(drugKey, i, drug.Position, drug)
        end
    end
end)

RegisterCommand('removePlants', function()
    for drugKey, plants in pairs(spawnedPlants) do
        for id, plant in pairs(plants) do
            if DoesEntityExist(plant) then
                DeleteEntity(plant)
            end
        end
    end
end, false)

-- draw a marker above each plant pos
--[[
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
]]--


-- NetEvents
RegisterNetEvent('ns-simpledrugs:xpUpdated', function(data)
    lib.notify({
        title = 'Harvested',
        description = ('+%d XP | Level %d (%d XP)'):format(data.gained, data.level, data.xp),
        type = 'success'
    })
end)

-- Commands
RegisterCommand('drugxp', function()
    local progress = math.floor((xpData.xp / xpData.needed) * 100)
    print(('Level: %d | XP: %d/%d (%d%%)'):format(xpData.level, xpData.xp, xpData.needed, progress))

    lib.registerContext({
        id = "drugxp_menu",
        title = "Drug XP",
        options = {
            {
                title = ('Level / XP'),
                description = ('Level: %d | XP: %d/%d (%d%%)'):format(xpData.level, xpData.xp, xpData.needed, progress),
                progress = progress
            }
        }
    })

    lib.showContext('drugxp_menu')
end, false)

RegisterNetEvent('ns-simpledrugs:receiveData', function(xp, level, needed)
    --[[
        lib.notify({
            title = 'Drug XP',
            description = ('Level: %d | XP: %d/%d'):format(level, xp, needed),
            type = 'inform'
        })
    ]]--
    xpData = {
        xp = xp,
        level = level,
        needed = needed
    }
end)