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