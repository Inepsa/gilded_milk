
Config = {}

Config.defaultlang = "en" -- Default language ("en" English, "es" Español)

Config.SearchTimeMin = 6000 						-- Minimum time, in milliseconds (1000 milliseconds = 1 second), 
Config.SearchTimeMax = 8000 						-- Maximum time, in milliseconds (1000 milliseconds = 1 second),
Config.SearchDelay = 600				 			-- Time, in seconds, before a milking spot can be harvested
Config.SearchRewardCount = {2,4} 					-- How much milk players can find per area; Set this to a table like so {min,max} for random reward count per search; eg {0,3} will mean a random reward count between 0 and 3.

Config.GatherItem = "milk" 						-- The DB name of the item pulled from the nest
Config.GatherItemLabel = _U("gather_label") -- Item label of what is gathererd from the nest

Config.GatherLocations = { -- vector3(x,y,z)
	--Kamassa Ranch
    vector3(1366.07, -847.2, 70.95),
    vector3(1367.68, -841.48, 71.04),
    vector3(1375.66, -834.07, 70.74),
    vector3(1393.25, -840.17, 68.42),
    vector3(1406.66, -878.96, 62.74),
    vector3(1405.0, -871.02, 62.74),

    --mcfarlanes
    vector3(1377.05, 349.1, 87.92),
    vector3(1401.18, 351.89, 87.74),
    vector3(1386.7, 320.91, 87.86),
    vector3(1382.25, 318.81, 87.99),
    vector3(1402.77, 280.73, 89.3),
    vector3(1408.15, 269.44, 89.63),
    vector3(1411.26, 274.26, 89.63),

    --north Emerald
    vector3(765.51, 876.99, 121.05),
    vector3(766.58, 879.38, 121.05),
    vector3(762.07, 874.33, 121.05),
    vector3(778.65, 840.84, 118.59)
}
