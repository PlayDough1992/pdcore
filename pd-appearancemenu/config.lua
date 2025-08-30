Config = {}

-- Basic configurations
Config.UseTarget = true -- For interacting with locations
Config.Debug = false

-- Components available for customization
Config.Components = {
    Face = {
        id = 0,
        name = "Face",
        min = 0,
        max = 45,
        zoomType = "head"
    },
    Masks = {
        id = 1,
        name = "Masks",
        min = 0,
        max = 195,
        zoomType = "face"
    },
    Hair = {
        id = 2,
        name = "Hair",
        min = 0,
        max = 73,
        zoomType = "head"
    },
    Torsos = {
        id = 3,
        name = "Arms",
        min = 0,
        max = 195,
        zoomType = "body"
    },
    Legs = {
        id = 4,
        name = "Pants",
        min = 0,
        max = 143,
        zoomType = "legs"
    },
    Bags = {
        id = 5,
        name = "Bags",
        min = 0,
        max = 99,
        zoomType = "body"
    },
    Shoes = {
        id = 6,
        name = "Shoes",
        min = 0,
        max = 101,
        zoomType = "feet"
    },
    Accessories = {
        id = 7,
        name = "Neck",
        min = 0,
        max = 151,
        zoomType = "body"
    },
    Undershirts = {
        id = 8,
        name = "Undershirt",
        min = 0,
        max = 189,
        zoomType = "body"
    },
    BodyArmor = {
        id = 9,
        name = "Vest",
        min = 0,
        max = 50,
        zoomType = "body"
    },
    Decals = {
        id = 10,
        name = "Decals",
        min = 0,
        max = 74,
        zoomType = "body"
    },
    Tops = {
        id = 11,
        name = "Shirt",
        min = 0,
        max = 393,
        zoomType = "body"
    }
}

-- Props configuration
Config.Props = {
    Hats = {
        id = 0,
        name = "Hat",
        min = -1,
        max = 151,
        zoomType = "head"
    },
    Glasses = {
        id = 1,
        name = "Glasses",
        min = -1,
        max = 41,
        zoomType = "face"
    },
    Ears = {
        id = 2,
        name = "Ear Accessories",
        min = -1,
        max = 41,
        zoomType = "head"
    },
    Watches = {
        id = 6,
        name = "Watches",
        min = -1,
        max = 41,
        zoomType = "arms"
    },
    Bracelets = {
        id = 7,
        name = "Bracelets",
        min = -1,
        max = 41,
        zoomType = "arms"
    }
}

-- Camera positions for different view types
Config.CameraZones = {
    default = {
        bone = 0,
        offset = vector3(0.0, 2.0, 0.0),
        pointOffset = vector3(0.0, 0.0, 0.0),
        fov = 90.0
    },
    head = {
        bone = 31086,
        offset = vector3(0.0, 0.5, 0.2),
        pointOffset = vector3(0.0, 0.0, 0.0),
        fov = 50.0
    },
    body = {
        bone = 11816,
        offset = vector3(0.0, 2.0, 0.2),
        pointOffset = vector3(0.0, 0.0, 0.0),
        fov = 70.0
    },
    legs = {
        bone = 46078,
        offset = vector3(0.0, 1.5, -0.4),
        pointOffset = vector3(0.0, 0.0, 0.0),
        fov = 60.0
    },
    feet = {
        bone = 52301,
        offset = vector3(0.0, 0.9, -0.8),
        pointOffset = vector3(0.0, 0.0, 0.0),
        fov = 40.0
    },
    face = {
        bone = 31086,
        offset = vector3(0.0, 0.3, 0.2),
        pointOffset = vector3(0.0, 0.0, 0.0),
        fov = 40.0
    }
}