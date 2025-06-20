Interaction = {
    showPreview = function() return exports['interaction']:showInteraction('⇽', 'Close Preview') end,
    showActivated = function() return exports['interaction']:showInteraction('J', 'Activated') end,
    showDeactivated = function() return exports['interaction']:showInteraction(nil, 'Deactivated') end,
    hide = function() return exports['interaction']:hideInteraction() end,
}