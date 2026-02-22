fx_version  'adamant'
lua54       'yes'
game        'gta5'

name        'MTJ_Carry'
author      'MTJ2024'
version     '2.0'
license     'MIT'
repository  'https://github.com/MTJ2024/Carry'
description 'Trage-Script mit Anfrage-System fuer FiveM RP Server (ESX Legacy)'

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/styles.css',
	'html/scripts.js',
	'html/fonts/*.ttf',
	'html/fonts/*.otf',
	'html/img/*.png'
}

shared_scripts {
    'config.lua',
}

server_scripts {
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

