fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Lenix <https://github.com/lenix-x>'
description 'Patrol System: Garage, Mic, Modes'
version '1.0.0'

shared_scripts {'shared/**/**/*.lua', '@ox_lib/init.lua'}
client_script 'client/**/*.lua'
server_scripts {'@oxmysql/lib/MySQL.lua', 'server/**/*.lua'}

ui_page 'nui/*.html'
file 'nui/*/*.*'