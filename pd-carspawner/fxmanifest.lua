fx_version 'cerulean'
game 'gta5'

name 'pd-carspawner'
description 'Advanced Vehicle Spawner & Customization System for pd-core'
author 'pd-core'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/customization.lua',
    'client/preview.lua',
    'client/addons.lua'
}

server_scripts {
    'server/database.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'addons.json'
}

dependencies {
    'pd-core',
    'pd-notifications'
}