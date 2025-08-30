fx_version 'cerulean'
game 'gta5'

author 'Playdough'
description 'PlayDough Inventory System'
version '2.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/weapons/*.png',
    'html/images/items/*.png'
}

dependencies {
    'pd-notifications'
}

lua54 'yes'

provide 'inventory'