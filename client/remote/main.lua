IsUIOpen = false
OriginalStates, AvailabilityCheck = {}, {}
CreateThread(function()
    local originalPrint = print
    print = function(...)
        local info = debug.getinfo(2, "Sl")
        local lineInfo = info.short_src .. ":" .. info.currentline
        return Option.Print.Debug and originalPrint("[" .. lineInfo .. "]", ...)
    end
end)

if GetResourceState(Config.CorePrefix == 'auto' and 'qb-core' or Config.CorePrefix .. 'core') == 'started' then
    function Notify(text, type, time)
        exports[Config.CorePrefix == 'auto' and 'qb-core' or Config.CorePrefix .. 'core']:Notify(text, type, time)
    end
else
    function Notify(text)
        SetNotificationTextEntry("STRING")
        AddTextComponentString(text)
        DrawNotification(false, false)
    end
end

if Config.UsingFramework then
    function Check() end
        RegisterNetEvent('QBCore:Command:SpawnVehicle', function(vehName)
        Wait(500) -- Wait for original event to finish

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            for i = 1, 12 do
                SetVehicleExtra(vehicle, i, false)
            end
        end
    end)
else
    function Check()
        for i = 1, 12 do
            SetVehicleExtra(Veh, i, true)
            Wait(1)
            local stateAfterOff = IsVehicleExtraTurnedOn(Veh, i)
            SetVehicleExtra(Veh, i, false)
            local stateAfterOn = IsVehicleExtraTurnedOn(Veh, i)
            if stateAfterOff ~= stateAfterOn then
                AvailabilityCheck[i] = false
            else
                AvailabilityCheck[i] = true
            end
        end
        for i = 1, 12 do
            SetVehicleExtra(Veh, i, not OriginalStates[i])
        end
        print("Restored to original states: " .. json.encode(OriginalStates))

        for i = 1, 12 do
            if AvailabilityCheck[i] then
                table.insert(UnAvailableExtras, i)
            end
        end
    end
end

if Option.IgnoreVehicleState then
    function OpenDamageCheck() end
    function ToggleDamageCheck(isExtraOn, extraNum, cb) 
        SetVehicleExtra(Veh, extraNum, isExtraOn)
        local newState = not isExtraOn -- After toggle, state is opposite
        print("Extra " .. extraNum .. " " .. (isExtraOn and "disabled" or "enabled"))
        cb({
            success = true,
            extraNum = extraNum,
            isActive = newState
        })
    end
else
    function OpenDamageCheck()
        if IsVehicleDamaged(Veh) then
            if IsUIOpen then
                SendNUIMessage({
                    action = 'close',
                    sirenOn = false
                })
                SetNuiFocus(false, false)
                IsUIOpen = false
                return 1
            end
            return 2
        end
        return false
    end
    function ToggleDamageCheck(isExtraOn, extraNum, cb)
        if IsVehicleDamaged(Veh) then 
            if isExtraOn == false then
                Notify(Option.Notify.Error.Damaged, 'error', 10000) 
                cb({success = false, error = "Veh damaged"})
                return
            end
            SetVehicleExtra(Veh, extraNum, isExtraOn)
            local newState = not isExtraOn -- After toggle, state is opposite
            print("Extra " .. extraNum .. " " .. (isExtraOn and "disabled" or "enabled"))
            cb({
                success = true,
                extraNum = extraNum,
                isActive = newState
            })
        else
            SetVehicleExtra(Veh, extraNum, isExtraOn)
            local newState = not isExtraOn -- After toggle, state is opposite
            print("Extra " .. extraNum .. " " .. (isExtraOn and "disabled" or "enabled"))
            cb({
                success = true,
                extraNum = extraNum,
                isActive = newState
            })
        end
    end
end

CreateThread(function()
    while true do
        Veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if Veh ~= 0 then
            InVehicle = true
            if IsVehicleSirenOn(Veh) then
                SendNUIMessage({
                    sirenOn = true
                })
            else
                SendNUIMessage({
                    sirenOn = false
                })
            end
        else
            if IsUIOpen then
                Veh = 1
                Wait(400)
                ToggleRemote()
                Wait(400)
                Veh = 0
            end
            InVehicle = false
        end
        Wait(200)
    end
end)

RegisterNUICallback('toggle', function(data, cb)
    if not InVehicle then return end
    Wait(200)
    local extraNum = data.num or 1
    local isExtraOn = IsVehicleExtraTurnedOn(Veh, extraNum)
    ToggleDamageCheck(isExtraOn, extraNum, cb)
end)

RegisterNUICallback('unfocus', function(data, cb)
    SetNuiFocus(false, false)
    cb(true)
end)

function Checkavailability()
    if not InVehicle then return end
    OriginalStates, AvailabilityCheck, TurnOnTable, ActiveExtras, InactiveExtras, UnAvailableExtras = {}, {}, {}, {}, {}, {}

    for i = 1, 12 do
        OriginalStates[i] = IsVehicleExtraTurnedOn(Veh, i)
    end

    Check()

    for i = 1, 12 do
        if OriginalStates[i] then
           table.insert(TurnOnTable, OriginalStates[i])
        else
            table.insert(TurnOnTable, false)
        end
    end
    print("Original states: " .. json.encode(TurnOnTable))

    for i = 1, 12 do
        if TurnOnTable[i] then
            table.insert(ActiveExtras, i)
        elseif TurnOnTable[i] == false then
            table.insert(UnAvailableExtras, i)
        else
            table.insert(InactiveExtras, i)
        end
    end
    for i = 1, 12 do
        TurnOnTable[i] = IsVehicleExtraTurnedOn(Veh, i)
        UnAvailableExtras = UnAvailableExtras
    end
end

function ToggleRemote()
    if not InVehicle then return end
    if OpenDamageCheck() == 1 then return Notify(Option.Notify.Success.Closed, 'success', 10000) end
    if OpenDamageCheck() == 2 then return Notify(Option.Notify.Error.Damaged, 'warning', 10000) end

    IsUIOpen = not IsUIOpen
    if IsUIOpen then
        Checkavailability()
        SendNUIMessage({
            action = 'open',
            unAvailableExtras = UnAvailableExtras,
            activeExtras = ActiveExtras,
            inactiveExtras = InactiveExtras,
            sirenOn = true
        })
        IsUiOpen = true
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = 'close',
            sirenOn = false
        })
        IsUiOpen = false
    end
end

RegisterNetEvent('patrol_remote', ToggleRemote)

function ToggleCursor()
    Wait(200)
    if IsUIOpen then
        SetNuiFocus(true, true)
    else
        SetNuiFocus(false, false)
    end
end
RegisterNetEvent('patrol_cursor', ToggleCursor)

RegisterCommand(Option.Controls.toggleRemote.commands.command, Option.Controls.toggleRemote.commands and ToggleRemote, Option.Controls.toggleRemote.commands.enabled and false or true)
RegisterCommand(Option.Controls.toggleCursor.commands.command, Option.Controls.toggleCursor.commands and ToggleCursor, Option.Controls.toggleCursor.commands.enabled and false or true)

RegisterKeyMapping(Option.Controls.toggleRemote.commands.command, Option.Controls.toggleRemote.description, 'keyboard', Option.Controls.toggleRemote.key)
RegisterKeyMapping(Option.Controls.toggleCursor.commands.command, Option.Controls.toggleCursor.description, 'keyboard', Option.Controls.toggleCursor.key)

RegisterCommand('patrol_extras_debug', function()
    if not InVehicle then return end

    Checkavailability()
    print('unavailableextras '..json.encode(UnAvailableExtras))
    print('ActiveExtras '..json.encode(ActiveExtras))
    print('InactiveExtras '..json.encode(InactiveExtras))
end, Option.Print.Debug and true or false)