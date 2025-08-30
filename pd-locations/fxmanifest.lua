fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'pd-locations'
description 'PlayDough Location Selector'
author 'PlayDough'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'pd-notifications',
    'pd-core'
}