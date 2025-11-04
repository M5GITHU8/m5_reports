fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'M5'
author 'discord.gg/mi5'
version '1.0.3'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'client/client_admin.lua'
}

server_scripts {
    'server/server.lua'
}

escrow_ignore {
  'config.lua'
}