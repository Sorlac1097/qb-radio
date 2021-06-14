fx_version 'cerulean'
games { 'rdr3', 'gta5' }

description 'Radio Script for Qbus and PmaVoice edited by Solrac#0680'
version '1.0.0'

client_scripts {
  'client/client.lua',
  'client/animation.lua',
  'config.lua'
}
server_scripts {
  'server/server.lua',
  'config.lua'
}

ui_page('html/ui.html')

files {
    'html/ui.html',
    'html/js/script.js',
    'html/css/style.css',
    'html/img/cursor.png',
    'html/img/radio.png'
}

