fx_version 'cerulean'
game 'gta5'

client_scripts {
    'config.lua',
    'client/*.lua'
}

server_scripts {
    'config.lua',
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'pd-inventory',
    'pd-bank',
    'pd-notifications'
}