Option.Interact = {
    {
        interact = 'interact',
        distance = 5,
        interactDst = 2,
        label = 'Take A Patrol',
        icon = 'fas fa-car',
        ped = 's_f_y_cop_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        coords = vector4(459.16, -1026.98, 28.42, 53.65),
        spawn = vector4(446.2, -1026.17, 28.25, 185.26),
        preview = {
            coords = vector4(452.52, -1021.56, 28.02, 217.03),
            cam = {
                coords = vector3(457.55, -1024.53, 28.63),
                rotation = {
                    verticalrotate = -10.00,
                    horizontalrotate = 0.00,
                    left_n_right = 64.49,
                },
                fov = 40.0
            }
        },
        config = 'police1',
        jobs = {
            police = 0,
        },
    },
    {
        interact = 'interact',
        distance = 5,
        interactDst = 2,
        icon = 'fas fa-car',
        label = 'Take A Patrol',
        ped = 's_f_y_cop_01',
        scenario = 'WORLD_HUMAN_COP_IDLES',
        coords = vector4(1850.69, 3680.53, 34.27, 201.56),
        spawn = vector4(1853.89, 3675.68, 33.34, 31.37),
        preview = {
            coords = vector4(1854.78, 3674.72, 33.3, 7.6),
            cam = {
                coords = vector3(1852.09, 3678.4, 33.98),
                rotation = {
                    verticalrotate = -10.00,
                    horizontalrotate = 0.00,
                    left_n_right = 228.55,
                },
                fov = 80.00
            }
        },
        config = 'police2',
        jobs = {
            police = 0,
        },
    },
    {
        interact = 'interact',
        distance = 5,
        interactDst = 2,
        label = 'Take A Patrol',
        ped = 's_m_y_cop_01',
        scenario = 'WORLD_HUMAN_CLIPBOARD',
        coords = vector4(-441.03, 5994.92, 31.49, 88.86),
        spawn = vector4(-460.64, 6046.97, 30.76, 132.34),
        preview = {
            coords = vector4(-448.14, 5994.5, 31.15, 265.16),
            cam = {
                coords = vector3(-443.87, 5995.86, 31.49),
                rotation = {
                    verticalrotate = -10.00,
                    horizontalrotate = 0.00,
                    left_n_right = 116.83,
                },
                fov = 80.00
            }
        },
        config = 'police3',
        jobs = {
            police = 0,
        },
    },
}

Option.Vehicles = {
    police1 = {
        {
            vehiclename = "Ford Victoria",
            vehicle = "police",
            allowed = {
                police = 1,
            },
            price = 40000,
            Registerable = true,
            plate = {"SASP0", 100, 999},
            style = {
                isenabled = true,
                livery = 4,
                r = 81,
                g = 84,
                b = 89,
            }
        },
    },
    police2 = {
        {
            vehiclename = "Bike",
            vehicle = "policeb",
            allowed = {
                police = 1,
            },
            price = 40000,
            Registerable = false,
            plate = {"SASP0", 100, 999},
            style = {
                isenabled = true,
                livery = 1,
                r = 81,
                g = 84,
                b = 89,
            }
        },
    },
    police3 = {
        {
            vehiclename = "Cruiser",
            vehicle = "police3",
            allowed = {
                police = 1,
            },
            price = 40000,
            Registerable = false,
            plate = {"SASP0", 100, 999},
            style = {
                isenabled = true,
                livery = 1,
                r = 81,
                g = 84,
                b = 89,
            }
        },
    },
}