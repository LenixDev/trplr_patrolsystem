Option = {}
Option.Print = true
Core = 'qb-core'
Notify = 'qb'
FuelSystem = 'x-fuel'
Menu = 'ox_lib'
Interaction = {
    showPreview = function() return exports['interaction']:showInteraction('⇽', 'Close Preview') end,
    showActivated = function() return exports['interaction']:showInteraction('J', 'Activated') end,
    showDeactivated = function() return exports['interaction']:showInteraction(nil, 'Deactivated') end,
    hide = function() return exports['interaction']:hideInteraction() end,
}

if Core == 'automatic' then
    if GetResourceState('qb-core') == 'started' then
        Core = exports['qb-core']:GetCoreObject()
    else
        print('qb-core not started, please start it before this resource.')
    end
elseif GetResourceState(Core) == 'started' then
    Core = exports[Core]:GetCoreObject()
else
    print('qb-core not started, please start it before this resource.')
end

local originalPrint = print
print = function(...)
    local info = debug.getinfo(2, "Sl")
    local lineInfo = info.short_src .. ":" .. info.currentline
    return Option.Print and originalPrint("[" .. lineInfo .. "]", ...)
end