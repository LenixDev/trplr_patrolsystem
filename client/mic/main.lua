local longVoiceRange = Option.Range
local MicFilter, isMicActive, isToggleOn = false, false, false
local canUseMic = true
local VehicleModels = Option.VehicleModels
local VehicleClasses = Option.VehicleClass

RegisterNetEvent('patrol_system:client:toggle', function()
    print('Toggling Patrol Mic')
    if not IsEmergencyVehicle() then
        exports[Core]:Notify('You must be in an emergency vehicle to use the patrol mic!', 'error', 5000)
        return
    end
    
    if canUseMic then
        isMicActive = not isMicActive
        if isMicActive then
            ApplyMicFilter()
            exports["pma-voice"]:overrideProximityRange(longVoiceRange, true)
            isToggleOn = true
            Interaction.showActivated()
            VehicleCheckLoop()
        else
            DeactivateMic()
        end
    else
        exports[Core]:Notify('Patrol mic is not available right now!', 'error', 3000)
    end
end)

RegisterCommand(Option.Command, function()
    TriggerEvent('patrol_system:client:toggle')
end, false)

RegisterKeyMapping(Option.Command, Option.Description, 'keyboard', Option.Key)

function IsEmergencyVehicle()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleClass = GetVehicleClass(vehicle)
        local vehicleModel = GetEntityModel(vehicle)
        
        if VehicleModels[vehicleModel] then
            canUseMic = true
            return true
        end
        return VehicleClasses[vehicleClass] or false
    end
    return false
end

function CreateMicFilter()
    MicFilter = CreateAudioSubmix("patrol_system")
    if MicFilter then
        SetAudioSubmixEffectRadioFx(MicFilter, 0)
        SetAudioSubmixEffectParamInt(MicFilter, 0, `default`, 1)
        AddAudioSubmixOutput(MicFilter, 0)
    end
end

function ApplyMicFilter()
    if MicFilter then
        MumbleSetSubmixForServerId(PlayerId(), MicFilter)
    end
end

function RemoveMicFilter()
    MumbleSetSubmixForServerId(PlayerId(), -1)
end

function DeactivateMic()
    RemoveMicFilter()
    exports["pma-voice"]:clearProximityOverride()
    isToggleOn = false
    isMicActive = false
    Interaction.showDeactivated()
    Wait(1000)
    Interaction.hide()
end

function VehicleCheckLoop()
    CreateThread(function()
        while isToggleOn do
            Wait(500)
            if not IsEmergencyVehicle() then
                canUseMic = false
                exports.qbx_core:Notify('You left the emergency vehicle, mic turned off!', 'warning', 7500)
                DeactivateMic()
                break
            end
        end
    end)
end

CreateThread(function()
    CreateMicFilter()
end)