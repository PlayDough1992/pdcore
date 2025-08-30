fx_version 'cerulean'
game 'gta5'

description 'PD Appearance Menu'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}


dependency 'pd-phone'
