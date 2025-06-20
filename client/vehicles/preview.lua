RegisterNetEvent("patrol_system:client:preview")
AddEventHandler("patrol_system:client:preview", function(data)
    Core.Functions.TriggerCallback('patrol_system:server:busycheck', function(status)
        if status then
            local cam = data.preview.cam
            local coords = data.preview.coords
            InPreview = true
            Core.Functions.SpawnVehicle(data.vehicle, function(veh)
                FreezeEntityPosition(PlayerPedId(), true)
                SetVehicleNumberPlateText(veh, "PREVIEW")
                exports[FuelSystem]:SetFuel(veh, 0.0)
                FreezeEntityPosition(veh, true)
                SetVehicleEngineOn(veh, false, false)
                DoScreenFadeOut(200)
                Wait(500)
                DoScreenFadeIn(200)
                SetVehicleUndriveable(veh, true)

                VehicleCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam.coords.x, cam.coords.y, cam.coords.z, cam.rotation.verticalrotate, cam.rotation.horizontalrotate, cam.rotation.left_n_right, cam.fov, false, 0)   
                SetCamActive(VehicleCam, true)
                RenderScriptCams(true, true, 2000, true, true)
                
                CreateThread(function()
                    while true do
                        if InPreview then
                            Interaction.showPreview()
                        elseif not InPreview then
                            Interaction.hide()
                            break
                        end
                        Wait(1)
                    end
                end)
        
                CreateThread(function()
                    while true do
                        if IsControlJustReleased(0, 177) then
                            FreezeEntityPosition(PlayerPedId(), false)
                            Core.Functions.DeleteVehicle(veh)
                            DoScreenFadeOut(200)
                            Wait(500)
                            DoScreenFadeIn(200)
                            RenderScriptCams(false, false, 1, true, true)
                            InPreview = false
                            TriggerServerEvent("patrol_system:server:SetActive", false)
                            break
                        end
                        Wait(1)
                    end
                end)
            end, coords, true)
        end
    end)
end)