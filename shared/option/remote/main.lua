Option = {}
Option.IgnoreVehicleState = false
Option.Print = {
    Debug = true,
    Author = true
}
Option.Notify = {
    Error = {
        Damaged = "Vehicle's sirens are damaged",
    },
    Success = {
        Closed = "Remote have been successfuly turn off"
    },
}
Option.Controls = {
    toggleRemote = {
        commands = {
            enabled = true,
            command = 'extra_toggle_remote'
        },
        key = 'J',
        description = 'Toggle Patrol Extra\'s Remote'
    },
    toggleCursor = {
        commands = {
            enabled = true,
            command = 'extra_toggle_cursor'
        },
        key = 'F11',
        description = 'Toggle Patrol Extra Cursor',
    }
}