-- made by @itswarning / warning.rpf

-- functions
local function getIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == "license:" then
            return id
        end
    end
    return nil
end

local function loadPlayerXP(src, cb)
    local identifier = getIdentifier(src)
    if not identifier then return cb(nil) end

    exports.oxmysql:fetch('SELECT xp, level from ns_simpledrugs_xp WHERE identifier = ?', { identifier }, function (result)
        if result and result[1] then
            print(result)
            cb(result[1])
        else
            exports.oxmysql:insert('INSERT INTO ns_simpledrugs_xp (identifier, xp, level) VALUES (?, 0, 1)', { identifier }, function () 
                cb( { xp = 0, level = 1 } )
            end)
        end
    end)
end

local function xpNeeded(level)
    return level * 100 -- simple forumala for xp/level can be adjusted
end

local function addXP(src, amount, cb)
    local identifier = getIdentifier(src)
    if not identifier then return end

    exports.oxmysql:fetch('SELECT xp, level from ns_simpledrugs_xp WHERE identifier = ?', { identifier }, function (result) 
        if not result or not result[1] then 
            -- if missing insert default then retry
            exports.oxmysql:insert('INSERT INTO ns_simpledrugs_xp (identifier, xp, level) VALUES (?, 0, 1)', { identifier }, function () 
                addXP(src, amount, cb)
            end)
            return
        end

        local xp = result[1].xp + amount
        local level = result[1].level

        while xp >= xpNeeded(level) do
            xp = xp - xpNeeded(level)
            level = level + 1
        end

        exports.oxmysql:update('UPDATE ns_simpledrugs_xp SET xp = ?, level = ? WHERE identifier = ?', {
            xp, level, identifier
        }, function ()
            if cb then cb({ xp = xp, level = level, needed = xpNeeded(level) }) end
            TriggerClientEvent('ns-simpledrugs:receiveData', src, xp, level, xpNeeded(level))
        end)

        TriggerClientEvent('ns-simpledrugs:xpUpdated', src, {
            xp = xp,
            level = level,
            gained = amount
        })
    end)
end

local function getData(src, cb)
    local identifier = getIdentifier(src)
    if not identifier then return end

    exports.oxmysql:fetch('SELECT xp, level from ns_simpledrugs_xp WHERE identifier = ?', { identifier }, function (result)
        if not result or not result[1] then
            -- if missing insert default then retry
            exports.oxmysql:insert('INSERT INTO ns_simpledrugs_xp (identifier, xp, level) VALUES (?, 0, 1)', { identifier }, function ()
                getData(src, cb)
            end)
            return
        end

        local xp = result[1].xp
        local level = result[1].level
        local needed = xpNeeded(level)

        if cb then cb(xp, level, needed) end
    end)
end

RegisterNetEvent('ns-simpledrugs:requestData', function()
    local src = source
    if not src then return end

    getData(src, function(xp, level, needed)
        TriggerClientEvent('ns-simpledrugs:receiveData', src, xp, level, needed)
    end)
end)

RegisterNetEvent('ns-simpledrugs:harvestPlant', function(plantId, clientCoords)
    local src = source
    if not src then return end
    getData(src, function(data) end)

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
    addXP(src, 20)
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