
local VORP_INV = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent("gilded_milk:try_search")
RegisterServerEvent("gilded_milk:do_search")
RegisterServerEvent("gilded_milk:abort_search")
RegisterServerEvent("gilded_milk:harvest")


local nests_searched = {}
local nests_searching = {}

local function InventoryCheck(_source, item, count)
	local itemsAvailable = true
	local done = false
	TriggerEvent("vorpCore:canCarryItem", _source, item, count, function(canCarryItem)                
		if canCarryItem ~= true then
			itemsAvailable = false
		end
		done = true
	end)
	while done == false do
		Wait(500)
	end
	if not itemsAvailable then
		-- Carrying too many of item already.
		TriggerClientEvent("vorp:TipRight", _source, _U("inv_nospace"), 5000)
		return false
	end
	if not VORP_INV.canCarryItems(_source, count) then
		-- Not enough space available in inventory.
		TriggerClientEvent("vorp:TipRight", _source, _U("inv_nospace"), 5000)
		return false
	end
	return true
end

local function AbortSearch(_source)
	for k,v in ipairs(nests_searching) do
		if v then
			if v == _source then
				nests_searching[k] = false
			end
		end
	end
end

AddEventHandler("gilded_milk:try_search", function(nestIndex)
	local _source = source
	local allow = true
	local curtime = os.time()
	if nests_searching[nestIndex] then
		-- This nest is currently being searched.
		TriggerClientEvent("vorp:TipRight", _source, _U("search_current"), 5000)
		return
	end
	nests_searching[nestIndex] = _source
	if nests_searched[nestIndex] then
		if curtime < (nests_searched[nestIndex] + Config.SearchDelay) then
			-- Not enough time has passed since this nest was last searched.
			TriggerClientEvent("vorp:TipRight", _source, _U("search_recent"), 5000)
			allow = false
		end
	end
	if allow then
		-- Check that the player has enough inventory space to continue...
		local count
		if type(Config.SearchRewardCount) == "table" then
			count = math.max(1,Config.SearchRewardCount[1])
		else
			count = Config.SearchRewardCount
		end
		allow = InventoryCheck(_source, Config.GatherItem, count)
	end
	if not allow then
		nests_searching[nestIndex] = false
		TriggerClientEvent("gilded_milk:try_search", _source) -- we're just doing this to ensure the client resets some local values allowing them to search again
		return
	end
	nests_searched[nestIndex] = curtime
	local searchTime = math.random(Config.SearchTimeMin, Config.SearchTimeMax) -- yes, we're even going to let the server determine the search time...
	TriggerClientEvent("gilded_milk:do_search",_source, nestIndex, searchTime)
end)

AddEventHandler("gilded_milk:do_search", function(nestIndex)
	local _source = source
	if (nests_searching[nestIndex] or 0) ~= _source then
		TriggerClientEvent("gilded_milk:try_search", _source) -- we're just doing this to ensure the client resets some local values allowing them to search again
		return
	end
	nests_searching[nestIndex] = false
	local count
	if type(Config.SearchRewardCount) == "table" then
		count = math.random(Config.SearchRewardCount[1],Config.SearchRewardCount[2])
	else
		count = Config.SearchRewardCount
	end
	if not InventoryCheck(_source, Config.GatherItem, count) then -- check their inventory space again for good measure...
		nests_searched[nestIndex] = false -- let's be nice and let players clear some inventory space then try again (if nobody beats them to it).
		TriggerClientEvent("gilded_milk:try_search", _source) -- we're just doing this to ensure the client resets some local values allowing them to search again
		return
	end
	VORP_INV.addItem(_source, Config.GatherItem, count)
	TriggerClientEvent("vorp:TipRight", _source, _UP("search_found", {count=count,item=Config.GatherItemLabel}), 5000)
end)

AddEventHandler("gilded_milk:abort_search",function()
	AbortSearch(source)
end)

local harvesting = {}
AddEventHandler("gilded_milk:harvest", function()
	local _source = source
	if not harvesting[_source] then return end
	VORP_INV.addItem(_source, Config.CrawfishGivenItemName, harvesting[_source])
	TriggerClientEvent("vorp:TipRight", _source, _UP("harvested", {count=harvesting[_source],item=Config.CrawfishGivenItemLabel}), 5000)
	harvesting[_source] = nil
end)

AddEventHandler("playerDropped", function(reason)
	AbortSearch(source)
end)

AddEventHandler("onResourceStart",function(resourceName)
	if resourceName == GetCurrentResourceName() then
		for k,v in ipairs(Config.GatherLocations) do
			nests_searched[k] = false
			nests_searching[k] = false
		end
	end
end)



-----Code for milking actual cows in the field.
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

RegisterServerEvent('Gilded:Prize')
AddEventHandler('Gilded:Prize', function(item, count)
	local _source = source
	VORPInv.addItem(_source, item, count)
	TriggerClientEvent("vorp:TipRight", _source, "You got ".. count.. "x ".. item, 5000)
end)
