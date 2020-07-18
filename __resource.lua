resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'PoliceEMSActivity'

version '1.1.0'

server_scripts {
	'@es_extended/locale.lua',
    'locales/en.lua',
    'locales/es.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'locales/en.lua',
    'locales/es.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
    'discord_perms'
}