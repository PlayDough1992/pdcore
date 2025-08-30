fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Warzone-style First Person Camera System'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/settings.lua',
    'client/camera.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js'
}

dependencies {
    'pd-core'
}