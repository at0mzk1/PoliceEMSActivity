-- by: minipunch
-- for: Initially made for USA Realism RP (https://usarrp.net)
-- purpose: Provide public servants with blips for all other active emergency personnel

local ACTIVE_EMERGENCY_PERSONNEL = {}

Citizen.CreateThread(function()
	while true do 
		-- We wait a second and add it to their timeTracker 
		Wait(1000); -- Wait a second
		for k, v in pairs(timeTracker) do 
			timeTracker[k] = timeTracker[k] + 1;
		end 
	end 
end)
timeTracker = {}
hasPerms = {}
permTracker = {}
activeBlip = {}
onDuty = {}
prefix = '^9[^5Badger-Blips^9] ^3'
roleList = Config.roleList

AddEventHandler("playerDropped", function()
	if onDuty[source] ~= nil then 
		local tag = activeBlip[source];
		local webHook = roleList[activeBlip[source]][3];
		if webHook ~= nil then 
			local time = timeTracker[source];
			local now = os.time();
			local startPlusNow = now + time;
			local minutesActive = os.difftime(now, startPlusNow) / 60;
			minutesActive = math.floor(math.abs(minutesActive))
			sendToDisc(_U('offduty_disc_message_title', GetPlayerName(source)), _U('offduty_disc_message', GetPlayerName(source), tag), 
			_U('offduty_disc_message_footer', minutesActive),
				webHook, 16711680)
		end 
	end
	timeTracker[source] = nil;
	onDuty[source] = nil;
	permTracker[source] = nil;
	hasPerms[source] = nil;
	activeBlip[source] = nil;
	-- Remove them from Blips:
	TriggerEvent('eblips:remove', source)
end)
function sendToDisc(title, message, footer, webhookURL, color)
	local embed = {}
	embed = {
		{
			["color"] = color, -- GREEN = 65280 --- RED = 16711680
			["title"] = "**".. title .."**",
			["description"] = "** " .. message ..  " **",
			["footer"] = {
				["text"] = footer,
			},
		}
	}
	-- Start
	-- TODO Input Webhook
	PerformHttpRequest(webhookURL, 
	function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  -- END
end

RegisterCommand('cops', function(source, args, rawCommand) 
	-- Prints the active cops online with a /blip that is on 
	sendMsg(source, _U('active_cops'))
	for id, _ in pairs(onDuty) do 
		TriggerClientEvent('chatMessage', source, '^9[^4' .. id .. '^9] ^0' .. GetPlayerName(id));
	end
end)

function sendMsg(src, msg) 
	TriggerClientEvent('chatMessage', src, prefix .. msg);
end

RegisterCommand('bliptag', function(source, args, rawCommand)
	-- The /blipTag command to toggle on and off the cop blip 
	if hasPerms[source] ~= nil then 
		if #args == 0 then 
			-- List out which ones they have access to 
			sendMsg(source, _U('blip_access'));
			for i = 1, #permTracker[source] do 
				-- List 
				TriggerClientEvent('chatMessage', source, '^9[^4' .. i .. '^9] ^0' .. permTracker[source][i]);
			end
		else 
			-- Choose their bliptag 
			local selection = args[1];
			if tonumber(selection) ~= nil then 
				local sel = tonumber(selection);
				local theirBlips = permTracker[source];
				if sel <= #theirBlips then
					-- Set up their tag
					local tag = activeBlip[source];
					local webHook = roleList[activeBlip[source]][3];
					if onDuty[source] ~= nil then 
						local time = timeTracker[source];
						local now = os.time();
						local startPlusNow = now + time;
						local minutesActive = os.difftime(now, startPlusNow) / (60);
						minutesActive = math.floor(math.abs(minutesActive))
						sendToDisc(_U('offduty_disc_message_title', GetPlayerName(source)), _U('offduty_disc_message', GetPlayerName(source), tag), 
							_U('offduty_disc_message_footer', minutesActive),
							webHook, 16711680)
						timeTracker[source] = 0;
					end
					activeBlip[source] = permTracker[source][sel];
					sendMsg(source, _U('set_blip_tag', permTracker[source][sel]));
					if onDuty[source] ~= nil then 
						tag = activeBlip[source];
						webHook = roleList[activeBlip[source]][3];
						sendToDisc(_U('onduty_disc_message_title', GetPlayerName(source)), _U('onduty_disc_message', GetPlayerName(source), tag), '',
							webHook, 65280) 
						local colorr = roleList[activeBlip[source]][2]
						TriggerEvent('eblips:remove', source)
						TriggerEvent('eblips:add', {name = tag .. GetPlayerName(source), src = source, color = colorr});
					end
				else 
					-- That is not a valid selection 
					sendMsg(source, _U('invalid_selection'))
				end
			else 
				-- Not a number 
				sendMsg(source, _U('invalid_number'))
			end
		end
	else 
		-- You are not a cop, you must be a cop in our discord to use this 
		sendMsg(source, _U('no_permissions'))
	end 
end)

RegisterNetEvent('PoliceEMSActivity:RegisterUser')
AddEventHandler('PoliceEMSActivity:RegisterUser', function()
	local src = source
	for k, v in ipairs(GetPlayerIdentifiers(src)) do
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				identifierDiscord = v
			end
	end
	local perms = {}
	if identifierDiscord then
		local roleIDs = exports.discord_perms:GetRoles(src)
		if not (roleIDs == false) then
			for k, v in pairs(roleList) do 
				for j = 1, #roleIDs do
					if (tostring(v[1]) == tostring(roleIDs[j])) then
						-- They have a proper role to use it 
						table.insert(perms, k);
						activeBlip[src] = k;
						hasPerms[src] = true;
					end
				end
			end
			-- Set up what roles they have access to: 
			permTracker[src] = perms;
		else
			-- They don't have any perms 
			print("[PoliceEMSActivity] " .. GetPlayerName(src) .. " has not gotten their permissions cause roleIDs == false")
		end
	else
		print("[PoliceEMSActivity] " .. GetPlayerName(src) .. " has not gotten their permissions cause discord was not detected...")
	end
	permTracker[src] = perms; 
end)

RegisterServerEvent("eblips:add")
AddEventHandler("eblips:add", function(person)
	ACTIVE_EMERGENCY_PERSONNEL[person.src] = person
	for k, v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent("eblips:updateAll", k, ACTIVE_EMERGENCY_PERSONNEL)
	end
	TriggerClientEvent("eblips:toggle", person.src, true)
end)

RegisterServerEvent("eblips:remove")
AddEventHandler("eblips:remove", function(src)
	-- remove from list --
	ACTIVE_EMERGENCY_PERSONNEL[src] = nil
	-- update client blips --
	for k, v in pairs(ACTIVE_EMERGENCY_PERSONNEL) do
		TriggerClientEvent("eblips:remove", tonumber(k), src)
	end
	-- deactive blips when off duty --
	TriggerClientEvent("eblips:toggle", src, false)
end)

-- Clean up blip entry for on duty player who leaves --
AddEventHandler("playerDropped", function()
	if ACTIVE_EMERGENCY_PERSONNEL[source] then
		ACTIVE_EMERGENCY_PERSONNEL[source] = nil
	end
end)

RegisterServerEvent("PoliceEMSActivity:startDuty")
AddEventHandler("PoliceEMSActivity:startDuty", function(person)
	if hasPerms[source] ~= nil then 
		if onDuty[source] == nil then 
			local colorr = roleList[activeBlip[source]][2];
			local tag = activeBlip[source];
			local webHook = roleList[activeBlip[source]][3];
			if webHook ~= nil then
				sendToDisc(_U('onduty_disc_message_title', GetPlayerName(source)), _U('onduty_disc_message', GetPlayerName(source), tag), '',
					webHook, 65280)
			end
			TriggerEvent('eblips:add', {name = tag .. GetPlayerName(source), src = source, color = colorr}); 
			sendMsg(source, _U('blip_toggle_on', tag))
			onDuty[source] = true;
			timeTracker[source] = 0;
		else 
			onDuty[source] = nil;
			local tag = activeBlip[source];
			local webHook = roleList[activeBlip[source]][3];
			if webHook ~= nil then
				local time = timeTracker[source];
				local now = os.time();
				local startPlusNow = now + time;
				local minutesActive = os.difftime(now, startPlusNow) / 60;
				minutesActive = math.floor(math.abs(minutesActive))
				sendToDisc(_U('offduty_disc_message_title', GetPlayerName(source)), _U('offduty_disc_message', GetPlayerName(source), tag), 
				_U('offduty_disc_message_footer', minutesActive), webHook, 16711680)
			end
			timeTracker[source] = nil;
			sendMsg(source, _U('blip_toggle_off', tag))
			TriggerEvent('eblips:remove', source)
		end
	else 
		-- You are not a cop, you must be a cop in our discord to use it 
		sendMsg(source, _U('no_permissions'))
	end
end)
