fx_version 'cerulean'
game 'gta5'

author 'ItzDusty'
description 'Gang creator for FiveM'
version '1.0.0'

shared_script {
   '@es_extended/imports.lua'
}

-- Server Scripts
server_scripts {
   '@mysql-async/lib/MySQL.lua',
   '@oxmysql/lib/MySQL.lua',
   '@es_extended/locale.lua',
   'config.lua',
   'server/main.lua'
}

-- Client Scripts
client_scripts {
   '@es_extended/locale.lua',
   'config.lua',
   'client/main.lua'
}

ui_page {
   "html/dist/index.html"
}

files {
   "html/dist/index.html",
   "html/dist/js/*.*",
   "html/dist/css/*.*"
}

lua54 'yes'

dependencies {
   'es_extended'
}

