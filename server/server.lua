local reports = {}
local reportId = 0
local playerOriginalCoords = {} -- store players' original coords before teleport

RegisterServerEvent("report:submit")
AddEventHandler("report:submit", function(subject, description)
    local src = source
    reportId = reportId + 1
    reports[reportId] = {
        id = reportId,
        player = src,
        subject = subject,
        description = description,
        timestamp = os.time(),
        status = "Open"
    }

    -- ✅ NEW: Notify all online admins of the new report
    for _, playerId in ipairs(GetPlayers()) do
        if IsPlayerAdmin(tonumber(playerId)) then
            TriggerClientEvent("report:notifyNewReport", tonumber(playerId), reportId, src, subject)
        end
    end
end)

lib.callback.register('report:getOpenReports', function(source)
    if not IsPlayerAdmin(source) then return nil end

    local openReports = {}
    for id, report in pairs(reports) do
        if report.status == "Open" then
            openReports[id] = report
        end
    end

    return openReports
end)

lib.callback.register('report:isAdmin', function(source)
    return IsPlayerAdmin(source)
end)

RegisterServerEvent("report:conclude")
AddEventHandler("report:conclude", function(id)
    if not IsPlayerAdmin(source) then return end
    if reports[id] then
        reports[id].status = "Closed"
    end
end)

local function saveOriginalCoords(playerId)
    local ped = GetPlayerPed(playerId)
    if ped and DoesEntityExist(ped) then
        local coords = GetEntityCoords(ped)
        playerOriginalCoords[playerId] = coords
    end
end

RegisterServerEvent("report:teleportToPlayer")
AddEventHandler("report:teleportToPlayer", function(targetPlayerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local target = tonumber(targetPlayerId)
    if target and GetPlayerPing(target) > 0 then
        saveOriginalCoords(target)
        TriggerClientEvent("report:teleportToPlayerCoords", src, target)
    else
        TriggerClientEvent("lib:notify", src, {title = "Reports", description = "Player not found or offline.", type = "error"})
    end
end)

RegisterServerEvent("report:bringPlayerToAdmin")
AddEventHandler("report:bringPlayerToAdmin", function(targetPlayerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local target = tonumber(targetPlayerId)
    if target and GetPlayerPing(target) > 0 then
        saveOriginalCoords(target)
        local adminPed = GetPlayerPed(src)
        local adminCoords = GetEntityCoords(adminPed)
        TriggerClientEvent("report:teleportToCoords", target, adminCoords)
    else
        TriggerClientEvent("lib:notify", src, {title = "Reports", description = "Player not found or offline.", type = "error"})
    end
end)

RegisterServerEvent("report:returnPlayerOriginalSpot")
AddEventHandler("report:returnPlayerOriginalSpot", function(targetPlayerId)
    local src = source
    if not IsPlayerAdmin(src) then return end

    local target = tonumber(targetPlayerId)
    local coords = playerOriginalCoords[target]
    if target and coords then
        TriggerClientEvent("report:teleportToCoords", target, coords)
        lib.notify({title = "Reports", description = "Player returned to original spot.", type = "success"})
    else
        TriggerClientEvent("lib:notify", src, {title = "Reports", description = "Original position not found for player.", type = "error"})
    end
end)

function IsPlayerAdmin(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if Config.AllowedDiscordIDs[id] then return true end
    end

    local group = GetPlayerGroup(source) or ""
    for _, allowed in ipairs(Config.AllowedAdminGroups) do
        if group == allowed then return true end
    end

    return false
end
