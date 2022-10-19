
progressbar = exports.vorp_progressbar:initiate()

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
	--exports['progressBars']:startUI(searchTime, _U("searching"))
	progressbar.start(_U("searching"), searchTime, 'linear' )
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


----Milk cows standing in field
Citizen.CreateThread(function()
    while true do
        local isTargetting, targetEntity = GetPlayerTargetEntity(PlayerId())

        if isTargetting and GetEntityModel(targetEntity) == `A_C_Cow` then
		
			local cow = GetEntityCoords(targetEntity)
			local pos = GetEntityCoords(PlayerPedId())
			if (Vdist(pos.x, pos.y, pos.z, cow.x, cow.y, cow.z) < 3.0) then
				DrawText3D(cow.x, cow.y, cow.z, "~q~Press [~o~G~q~] to milk")
				if IsControlJustPressed(0, 0x760A9C6F) then
					FreezeEntityPosition(targetEntity, true)
					FreezeEntityPosition(PlayerPedId(), true)
					if IsPedMale(PlayerPedId()) then
						TaskStartScenarioInPlace(PlayerPedId(), `WORLD_HUMAN_FARMER_WEEDING`, 8000, true, false, false, false)
					else
						RequestAnimDict("amb_work@world_human_farmer_weeding@male_a@idle_a")
						while ( not HasAnimDictLoaded( "amb_work@world_human_farmer_weeding@male_a@idle_a" ) ) do
								Citizen.Wait( 100 )
						end
						TaskPlayAnim(PlayerPedId(), "amb_work@world_human_farmer_weeding@male_a@idle_a", "idle_a", 8.0, -8.0, 8000, 1, 0, true, 0, false, 0, false)
					end
					--exports['progressBars']:startUI(8000, 'Milking cow ...')
					progressbar.start('Milking cow ...', 8000, 'linear' )
					Wait(9000)
					FreezeEntityPosition(targetEntity, false)
					FreezeEntityPosition(PlayerPedId(), false)
					local item = "milk"
					local count = 1
					TriggerServerEvent("Gilded:Prize", item , count)
				end
			end
        end

        Citizen.Wait(0)
    end
end)

UipromptManager:startEventThread()

function DrawText3D(x, y, z, text)
	local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
	local px,py,pz=table.unpack(GetGameplayCamCoord())  
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
	local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
	if onScreen then
	  SetTextScale(0.30, 0.30)
	  SetTextFontForCurrentCommand(1)
	  SetTextColor(255, 255, 255, 215)
	  SetTextCentre(1)
	  DisplayText(str,_x,_y)
	  local factor = (string.len(text)) / 225
	  DrawSprite("feeds", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 35, 35, 35, 190, 0)
	end
end

