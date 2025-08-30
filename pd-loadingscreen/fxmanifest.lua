fx_version 'cerulean'
game 'gta5'

description 'PD Loading Screen'
version '1.0.0'

loadscreen 'html/index.html'
loadscreen_manual_shutdown 'yes'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/images/*.png'
}

client_scripts {
    'client/*.lua'
}

ui_page 'html/index.html'