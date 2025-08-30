fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'PlayDough Phone System'
author 'PlayDough'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/index.html'

frame_enabled 'yes'
loadscreen_manual_shutdown 'yes'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/*.png',
    'html/images/*.jpg'
}
