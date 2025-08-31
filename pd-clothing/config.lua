Config = {}

-- Menu Position (can be 'left' or 'right')
Config.MenuPosition = 'left'

-- Menu Dimensions and Position
Config.Menu = {
    width = 400,              -- Width of the menu in pixels
    height = '90vh',          -- Height of the menu (90% of viewport height)
    padding = 20,            -- Padding from screen edge
    backgroundColor = '#1a1a1a', -- Dark background
    textColor = '#ffffff',    -- White text
    accentColor = '#3498db'   -- Blue accent color
}

-- Camera Settings
Config.Camera = {
    defaultDistance = 2.5,    -- Default camera distance
    minDistance = 1.5,       -- Minimum zoom distance
    maxDistance = 4.0,       -- Maximum zoom distance
    defaultFOV = 45.0,       -- Default Field of View
    rotationSpeed = 3.0,     -- Camera rotation speed
    zoomSpeed = 0.1,        -- Camera zoom speed
    height = -0.15          -- Camera height offset (negative values = lower camera)
}

-- Character Components
Config.Components = {
    {
        id = 0,
        label = "Face",
        maxDrawable = 45,
        maxTexture = 2,
        hasTextures = true,
        defaultZoom = 0.8,
        camOffset = {x = 0.0, y = 0.0, z = 0.6}
    },
    {
        id = 1,
        label = "Mask",
        maxDrawable = 197,
        maxTexture = 2,
        hasTextures = true,
        defaultZoom = 0.8,
        camOffset = {x = 0.0, y = 0.0, z = 0.6}
    },
    {
        id = 2,
        label = "Hair",
        maxDrawable = 73,
        maxTexture = 4,
        hasTextures = true,
        defaultZoom = 0.8,
        camOffset = {x = 0.0, y = 0.0, z = 0.6}
    },
    {
        id = 3,
        label = "Torso",
        maxDrawable = 196,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 4,
        label = "Legs",
        maxDrawable = 126,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.5,
        camOffset = {x = 0.0, y = 0.0, z = -0.4}
    },
    {
        id = 5,
        label = "Bags",
        maxDrawable = 82,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 6,
        label = "Shoes",
        maxDrawable = 97,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 2.0,
        camOffset = {x = 0.0, y = 0.0, z = -0.8}
    },
    {
        id = 7,
        label = "Accessories",
        maxDrawable = 148,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 8,
        label = "Undershirt",
        maxDrawable = 189,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 9,
        label = "Body Armor",
        maxDrawable = 40,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 10,
        label = "Decals",
        maxDrawable = 74,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 11,
        label = "Top",
        maxDrawable = 392,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.2,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    }
}

-- Props (Accessories)
Config.Props = {
    {
        id = 0,
        label = "Hats",
        maxDrawable = 162,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 0.8,
        camOffset = {x = 0.0, y = 0.0, z = 0.6}
    },
    {
        id = 1,
        label = "Glasses",
        maxDrawable = 34,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 0.8,
        camOffset = {x = 0.0, y = 0.0, z = 0.6}
    },
    {
        id = 2,
        label = "Ear Accessories",
        maxDrawable = 21,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 0.8,
        camOffset = {x = 0.0, y = 0.0, z = 0.6}
    },
    {
        id = 6,
        label = "Watches",
        maxDrawable = 40,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.4,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    },
    {
        id = 7,
        label = "Bracelets",
        maxDrawable = 29,
        maxTexture = 16,
        hasTextures = true,
        defaultZoom = 1.4,
        camOffset = {x = 0.0, y = 0.0, z = 0.2}
    }
}

-- Camera Views
Config.CameraViews = {
    default = {
        point = vector3(0.0, 2.0, 0.0),
        offset = vector3(0.0, 0.0, 0.0),
        fov = 45.0
    },
    head = {
        point = vector3(0.0, 0.5, 0.7),
        offset = vector3(0.0, 0.0, 0.7),
        fov = 25.0
    },
    torso = {
        point = vector3(0.0, 1.5, 0.2),
        offset = vector3(0.0, 0.0, 0.2),
        fov = 35.0
    },
    legs = {
        point = vector3(0.0, 1.0, -0.4),
        offset = vector3(0.0, 0.0, -0.4),
        fov = 35.0
    },
    feet = {
        point = vector3(0.0, 0.8, -0.8),
        offset = vector3(0.0, 0.0, -0.8),
        fov = 25.0
    }
}

-- Rotation Controls
Config.Controls = {
    rotate_left = 'A',       -- Rotate character left
    rotate_right = 'D',      -- Rotate character right
    zoom_in = 'W',          -- Zoom camera in
    zoom_out = 'S',         -- Zoom camera out
    toggle_rotate = 'LALT'   -- Hold to enable rotation
}
