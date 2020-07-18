
Config                          = {}
Config.Locale 					= 'es'

--[[
person = {
 src = 123,
 color = 3,
 name = "Taylor Weitman"
}
]]
-- Below is the roles allowed to use the command /blip 
--[[
	1 = Red
	2 = Green
	3 = Blue
	5 = Yellow
	17 = Orange
	Color Info obtained from: https://wiki.gtanet.work/index.php?title=Blips
]]
-- CONFIG --
Config.roleList = { 
    -- Structure:
    -- ['role name'] = {role id in discord, role color, webhook url}
	['👮 LSPD | '] = {581881252907319369, 2, nil},
	['👮 Sheriff | '] = {577622764618383380, 17, nil},
	['👮 SAHP | '] = {506276895935954944, 3, nil},
	['👨‍🚒 Fire/EMS | '] = {577635624618819593, 1, nil},
	['🎖️ NG | '] = {609828128432586752, 5, nil},
}
