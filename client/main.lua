
RegisterNetEvent("gilded_milk:try_search")
RegisterNetEvent("gilded_milk:do_search")
RegisterNetEvent("gilded_milk:abort_search")
RegisterNetEvent("gilded_milk:harvest")


local _prompts, _prompt = GetRandomIntInRange(0, 0xffffff), nil
local searching, showprompt, nearest = false, false, 0

AddEventHandler("gilded_milk:try_search",function()
	searching, nearest = false, 0
end)

AddEventHandler("gilded_milk:do_search",function(nestIndex, searchTime)
	local playerPed = PlayerPedId()
	TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), searchTime, true, false, false, false)
	exports['progressBars']:startUI(searchTime, _U("searching"))
	Citizen.Wait(searchTime)
	ClearPedTasksImmediately(playerPed)
	nearest = 0
	searching = false
	TriggerServerEvent("gilded_milk:do_search",nestIndex)
end)

AddEventHandler("gilded_milk:harvest",function()
	local playerPed = PlayerPedId()
	local dict, anim = "mech_skin@chicken@field_dress", "success"
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Wait(0) 
	end
	TaskPlayAnim(playerPed, dict, anim, 1.0, 1.0, 4000, 16, 0.0, false, false, false, '', false)
	exports['progressBars']:startUI(5000, _U("harvesting"))
	Citizen.Wait(5000)
	ClearPedTasksImmediately(playerPed)
	RemoveAnimDict(dict)
	TriggerServerEvent("gilded_milk:harvest")
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		showprompt = false
		local sleep = true
		local pedID = PlayerPedId()
		local DeadOrDying = IsPedDeadOrDying(pedID)
		if (not searching) and (not DeadOrDying) then
			local coords = GetEntityCoords(pedID)
			for index, pos in ipairs(Config.GatherLocations) do
				local distance = #(coords - pos)
				if distance <= 1.5 then
					sleep = false 
					showprompt = true
					nearest = index
					break
				end
			end
		elseif searching and DeadOrDying then
			searching = false
			showprompt = false
			TriggerServerEvent("gilded_milk:abort_search")
		end
		if showprompt and (not searching) and (nearest > 0) and (not DeadOrDying) then
			PromptSetActiveGroupThisFrame(_prompts, CreateVarString(10, 'LITERAL_STRING', _U("search_nest")))
			if Citizen.InvokeNative(0xC92AC953F0A982AE,_prompt) then
				sleep = true
				searching = true
				TriggerServerEvent("gilded_milk:try_search",nearest)
			end
		end
		nearest = 0
		if sleep then Citizen.Wait(500) end
	end
end)

Citizen.CreateThread(function()
	_prompt = PromptRegisterBegin()
	PromptSetControlAction(_prompt, 0x760A9C6F) -- G key
	local str = CreateVarString(10, 'LITERAL_STRING', _U("nest"))
	PromptSetText(_prompt, str)
	PromptSetEnabled(_prompt, 1)
	PromptSetStandardMode(_prompt,1)
	PromptSetGroup(_prompt, _prompts)
	Citizen.InvokeNative(0xC5F428EE08FA7F2C,_prompt,true)
	PromptRegisterEnd(_prompt)
end)
