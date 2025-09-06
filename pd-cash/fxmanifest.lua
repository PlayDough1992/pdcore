fx_version 'cerulean'
game 'gta5'

name 'pd-cash'
description 'Cash drops and player-to-player cash transactions'
version '1.0.0'

client_scripts {
    'client/functions.lua',
    'client/main.lua',
    'client/debug.lua',
    'client/blip_debug.lua'
}

server_scripts {
    'server/server_shared.lua',
    'server/bank_events.lua',
    'server/main.lua',
    'server/commands.lua',
    'server/debug.lua',
    'server/pickupdebug.lua',
    'server/dropcash_command.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_script 'config.lua'

dependency 'pd-bank'
dependency 'pd-notifications'
