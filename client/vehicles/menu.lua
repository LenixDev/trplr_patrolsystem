RegisterNetEvent('patrol_system:client:menu', function(data)
    local config = data.config
    local spawn = data.spawn
    local preview = data.preview
    if Menu == 'qb-menu' then
        local Menu = {
            {
                header = "Patrols",
                isMenuHeader = true,
            },
            {
                header = "Police Vehicles",
                txt = "Next",
                params = {
                    event = "patrol_system:client:list",
                    args = {
                        config = config,
                        spawn = spawn,
                        preview = preview
                    }
                }
            },
        }
        Menu[#Menu+1] = {
            header = "Preview Patrols",
            txt = "Next",
            params = {
                event = "patrol_system:client:previewmenu",
                args = {
                    config = config,
                    preview = preview,
                    spawn = spawn
                }
            }
        }
        Menu[#Menu+1] = {
            header = "⬅ Store Vehicle",
            params = {
                event = "patrol_system:client:return"
            }
        }
        Menu[#Menu+1] = {
            header = "Close Menu",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }
        exports['qb-menu']:openMenu(Menu)
    elseif Menu == 'ox_lib' then
        local options = {
            {
                title = 'Police Vehicles',
                description = 'Next',
                onSelect = function()
                    TriggerEvent('patrol_system:client:list', {
                        config = config,
                        spawn = spawn,
                        preview = preview
                    })
                end
            },
            {
                title = 'Preview Patrols',
                description = 'Next',
                onSelect = function()
                    TriggerEvent('patrol_system:client:previewmenu', {
                        config = config,
                        preview = preview,
                        spawn = spawn
                    })
                end
            },
            {
                title = '⬅ Store Vehicle',
                onSelect = function()
                    TriggerEvent('patrol_system:client:return')
                end
            },
            {
                title = 'Close Menu',
                onSelect = function()
                    lib.hideContext()
                end
            }
        }

        lib.registerContext({
            id = 'patrol_menu',
            title = 'Patrols',
            options = options
        })

        lib.showContext('patrol_menu')
    end
end)

RegisterNetEvent("patrol_system:client:list", function(data)
    local config = data.config
    local spawn = data.spawn

    if Menu == 'qb-menu' then
        local vehicleMenu = {
            {
                header = "Government Vehicles",
                isMenuHeader = true,
            }
        }

        vehicleMenu[#vehicleMenu+1] = {
            header = "⬅ Go Back",
            params = {
                event = "patrol_system:client:menu",
                args = {
                    config = config
                }
            }
        }

        if Option.Vehicles[config] then
            local playerJob = Core.Functions.GetPlayerData().job.name
            local playerGrade = Core.Functions.GetPlayerData().job.grade.level
        
            for _, vehicle in ipairs(Option.Vehicles[config]) do
                if vehicle.allowed and vehicle.allowed[playerJob] and playerGrade >= vehicle.allowed[playerJob] then
                    local txt = vehicle.Registerable 
                        and ("Get: " .. vehicle.vehiclename .. " For: " .. vehicle.price .. "$")
                        or ("Take Out " .. vehicle.vehiclename)
                    vehicleMenu[#vehicleMenu+1] = {
                        header = vehicle.vehiclename,
                        txt = txt,
                        params = {
                            isServer = true,
                            event = "patrol_system:server:charge",
                            args = {
                                price = vehicle.price,
                                vehiclename = vehicle.vehiclename,
                                vehicle = vehicle.vehicle,
                                config = config,
                                spawn = spawn,
                                chargeable = vehicle.Registerable,
                            }
                        }
                    }
                end
            end
        else
            print("Warning: No vehicles found for config: " .. tostring(config))
        end
        exports['qb-menu']:openMenu(vehicleMenu)
    elseif Menu == 'ox_lib' then
        local options = {
            {
                title = '⬅ Go Back',
                onSelect = function()
                    TriggerEvent('patrol_system:client:menu', {
                        config = config
                    })
                end
            }
        }

        if Option.Vehicles[config] then
            local playerJob = Core.Functions.GetPlayerData().job.name
            local playerGrade = Core.Functions.GetPlayerData().job.grade.level

            for _, vehicle in ipairs(Option.Vehicles[config]) do
                if vehicle.allowed and vehicle.allowed[playerJob] and playerGrade >= vehicle.allowed[playerJob] then
                    local description = vehicle.Registerable 
                        and ("Get: " .. vehicle.vehiclename .. " For: " .. vehicle.price .. "$")
                        or ("Take Out " .. vehicle.vehiclename)

                    options[#options+1] = {
                        title = vehicle.vehiclename,
                        description = description,
                        onSelect = function()
                            TriggerServerEvent('patrol_system:server:charge', {
                                price = vehicle.price,
                                vehiclename = vehicle.vehiclename,
                                vehicle = vehicle.vehicle,
                                config = config,
                                spawn = spawn,
                                chargeable = vehicle.Registerable,
                            })
                        end
                    }
                end
            end
        else
            print("Warning: No vehicles found for config: " .. tostring(config))
        end

        lib.registerContext({
            id = 'vehicle_menu',
            title = 'Government Vehicles',
            options = options
        })

        lib.showContext('vehicle_menu')
    end
end)