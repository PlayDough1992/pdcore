fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'PlayDough Core Framework System'
author 'PlayDough - Based on QB-Core'

ui_page 'setjob/html/index.html'

shared_scripts {
    'jobs.lua'
}

server_scripts {
    'server/admin.lua',
    'server/main.lua',
    'setjob/server.lua',
    'server/commands.lua'
}

client_scripts {
    'ignore.lua',
    'setjob/setjob.lua',
    'client/commands.lua',
}

files {
    -- SetJob UI
    'setjob/html/index.html',
    'setjob/html/script.js',
    'setjob/html/style.css',
    
    -- Data files
    'events.meta',
    'popgroups.ymt',
    'relationships.dat'
}

data_file 'FIVEM_LOVES_YOU_4B38E96CC036038F' 'events.meta'
data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups.ymt'