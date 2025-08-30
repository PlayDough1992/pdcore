Config = {}

Config.DefaultSettings = {
    enabled = false,
    fov = {
        default = 80.0,
        min = 60.0,
        max = 120.0,
        ads = 60.0
    },
    camera = {
        height = 0.05,
        sensitivity = 1.0,
        smoothing = 0.2
    },
    effects = {
        blur = {
            enabled = true,
            strength = 0.5
        },
        bloom = {
            enabled = true,
            strength = 0.3
        }
    },
    aimAssist = {
        enabled = true,
        strength = 0.7,
        range = 25.0
    }
}