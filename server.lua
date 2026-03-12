


RegisterNetEvent('ns-simpledrugs:harvestPlant', function(plantId, clientCoords)
    local src = source
    if not src then return end

    -- distance check to prevent exploit
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    if #(pedCoords - clientCoords) > 3.5 then
        return
    end

    local added = exports.ox_inventory:AddItem(src, Config.HarvestItem, Config.HarvestAmount)
    if not added then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Inventory',
            description = 'Unable to give item.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('ns-simpledrugs:logHarvest', function(plantId, data)
    local src = source
    local playerName = GetPlayerName(src)
    -- defining discord embed for logging
    local embed = {
        title = "Plant Harvested",
        description = ("Player: %s harvested a plant."):format(playerName),
        color = 65280, -- green
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    PerformHttpRequest(Config.WebHookURL, function(err, text, headers) end, "POST", json.encode({
        username = "NukeSociety:SimpleDrugs",
        embeds = { embed }
    }), { ["Content-Type"] = "application/json" })
end)