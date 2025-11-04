RegisterCommand("report", function()
    local input = lib.inputDialog('Report Player', {
        {type = 'input', label = 'Subject', required = true},
        {type = 'textarea', label = 'Description', required = true}
    })

    if not input then return end

    local subject, description = input[1], input[2]
    TriggerServerEvent("report:submit", subject, description)
    lib.notify({title = "Report", description = "Report submitted!", type = "success"})
end)

RegisterNetEvent("report:teleportToCoords")
AddEventHandler("report:teleportToCoords", function(coords)
    local ped = PlayerPedId()
    if coords then
        SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, false, false, false, true)
        lib.notify({title = "Reports", description = "You have been teleported by an admin.", type = "success"})
    else
        lib.notify({title = "Reports", description = "Teleport failed: no coordinates received.", type = "error"})
    end
end)

-- ✅ NEW: Notify admins when a new report is submitted
RegisterNetEvent("report:notifyNewReport")
AddEventHandler("report:notifyNewReport", function(id, reporterId, subject)
    lib.notify({
        title = "New Report #" .. id,
        description = "From Player ID: " .. reporterId .. "\nSubject: " .. subject,
        type = "inform"
    })
end)
