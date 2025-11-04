RegisterCommand("reports", function()
    lib.callback('report:isAdmin', false, function(isAdmin)
        if not isAdmin then
            lib.notify({title = "Reports", description = "Access denied.", type = "error"})
            return
        end

        lib.callback('report:getOpenReports', false, function(reports)
            if not reports or next(reports) == nil then
                lib.notify({title = "Reports", description = "No ongoing reports.", type = "info"})
                return
            end

            local options = {}
            for id, report in pairs(reports) do
                table.insert(options, {
                    title = "Report #" .. id .. ": " .. report.subject,
                    description = "From Player ID: " .. report.player .. "\nStatus: " .. report.status,
                    onSelect = function()
                        lib.registerContext({
                            id = "report_action_" .. id,
                            title = "Report #" .. id,
                            options = {
                                {
                                    title = "Conclude Report",
                                    description = "Mark this report as closed.",
                                    onSelect = function()
                                        TriggerServerEvent("report:conclude", id)
                                        lib.notify({title = "Reports", description = "Report #" .. id .. " concluded.", type = "success"})
                                        lib.showContext("reports_menu")
                                    end
                                },
                                {
                                    title = "Teleport to Player",
                                    description = "Teleport to the reported player's location.",
                                    onSelect = function()
                                        TriggerServerEvent("report:teleportToPlayer", report.player)
                                        lib.notify({title = "Reports", description = "Teleporting...", type = "info"})
                                    end
                                },
                                {
                                    title = "Bring Player to Me",
                                    description = "Teleport the reported player to your location.",
                                    onSelect = function()
                                        TriggerServerEvent("report:bringPlayerToAdmin", report.player)
                                        lib.notify({title = "Reports", description = "Bringing player to you...", type = "info"})
                                    end
                                },
                                {
                                    title = "Return Player to Original Spot",
                                    description = "Return the player to where they were before teleport.",
                                    onSelect = function()
                                        TriggerServerEvent("report:returnPlayerOriginalSpot", report.player)
                                        lib.notify({title = "Reports", description = "Returning player to original spot...", type = "info"})
                                    end
                                },
                                {
                                    title = "Back",
                                    onSelect = function()
                                        lib.showContext("reports_menu")
                                    end
                                }
                            }
                        })
                        lib.showContext("report_action_" .. id)
                    end
                })
            end

            lib.registerContext({
                id = "reports_menu",
                title = "Ongoing Reports",
                options = options
            })
            lib.showContext("reports_menu")
        end)
    end)
end)

RegisterNetEvent("report:teleportToPlayerCoords")
AddEventHandler("report:teleportToPlayerCoords", function(targetPlayer)
    local ped = PlayerPedId()
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targetPlayer))

    if targetPed and DoesEntityExist(targetPed) then
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(ped, coords.x, coords.y, coords.z + 1.0, false, false, false, true)
        lib.notify({title = "Reports", description = "Teleported to player.", type = "success"})
    else
        lib.notify({title = "Reports", description = "Player ped not found.", type = "error"})
    end
end)
