errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)
eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local Maps = { difficulties = { Easy = "Easy", Normal = "Normal", Hard = "Hard", Expert = "Expert" } }

local mapTable = {}

local mapNames = {	
	[1] = {
		Title = "Inferno2",
	},
	
	[2] = {
		Title = "Neo-Aspect",
	},
			
	[3] = {
		Title = "Yolo"
	},
	
	[4] = {
		Title = "Anamanaguchi"
	}
}

local FX = {
	[1] = {
		Title = "hitclap",
		SongID = 3654749910,
		Volume = 1
	},
	
	[2] = {
		Title = "soft-hitclap",
		SongID = 3654796428,
		Volume = 1		
	},
	
	[3] = {
		Title = "ping",
		SongID = 2946997202,
		Volume = 5
	},	
	
	[4] = {
		Title = "normal-hit",
		SongID = 3660140698,
		Volume = 5		
	},

	[5] = {
		Title = "ping2",
		SongID = 3660140294,
		Volume = 3
	},			
}

Maps.SetupEvents = function()
	game.ReplicatedStorage.Events.Server.Maps.MapsGetEvent.OnServerInvoke = Maps.GetAction
	game.ReplicatedStorage.Events.Server.Maps.MapsSetEvent.OnServerEvent:Connect(Maps.SetAction)
end

function Maps.GetKeyFromEnum(key)
	if key == eventManager.keys.getMapWithTitle then
		return "getMapWithTitle"
	elseif key == eventManager.keys.getSimpleMapTable then
		return "getSimpleMapTable"
	elseif key == eventManager.keys.getBeatmap then
		return "getBeatmap"
	elseif key == eventManager.keys.getFXTable then
		return "getFXTable"
	elseif key == eventManager.keys.getMapTable then
		return "getMapTable"
	elseif key == eventManager.keys.updateBeatmap then
		return "updateBeatmap"
	end
end

Maps.GetAction = function(player, updateTable)
	if environmentVariables.debugMode then		
		print(string.format("GET %s - %s", player.Name, Maps.GetKeyFromEnum(updateTable[1])))
	end
		
	local key = updateTable[1]
	if key == eventManager.keys.getSimpleMapTable then
		return Maps.GetSimpleMapTable()
	elseif key == eventManager.keys.getMapWithTitle then
		return Maps.GetMapWithTitle(updateTable[2])
	elseif key == eventManager.keys.getMapTable then
		return Maps.GetMapTable()
	elseif key == eventManager.keys.getFXTable then
		return Maps.GetFXTable()
	elseif key == eventManager.keys.getBeatmap then
		return Maps.GetBeatmap(updateTable[2], updateTable[3])				
	else
		errorHandler.GetErrorMessage("mapmetadata", errorHandler.errors.incorrect_key)
	end
end

Maps.SetAction = function(player, updateTable)
	if environmentVariables.debugMode then		
		print(string.format("SET %s - %s", player.Name, Maps.GetKeyFromEnum(updateTable[1])))
	end	
	
	local key = updateTable[1]
	if key == eventManager.keys.updateBeatmap then
		Maps.UpdateBeatmap(updateTable[2], updateTable[3], updateTable[4])
	else
		local errorMessage = errorHandler.GetErrorMessage("mapmetadata", errorHandler.errors.incorrect_key)
		return warn(errorMessage)		
	end
end

Maps.GetFXTable = function()
	return FX
end

Maps.GetMapTitleTable = function()
	return mapNames
end

Maps.GetMapTable = function()
	return mapTable
end

Maps.InsertMap = function(map)	
	table.insert(mapTable, map)	
end

Maps.GetBeatmap = function(title, difficulty)
	local map = Maps.GetMapWithTitle(title)
	
	if map ~= nil then
		for i,v in pairs(map.Difficulties) do
			if map.Difficulties[i].Rating == difficulty then
				return map.Difficulties[i].Beatmap[1]		
			else
				return error("Can't find difficulty specified!")			
			end
		end			
	end
end

Maps.GetMapWithTitle = function(title)
	local maps = mapTable
	
	if #maps == 0 then
		return warn("Map table not initialised!")
	end
	
	for i,v in pairs(maps) do
		if v.Title == title then
			return v
		end
	end
	
	return warn("Map with name "..title.." not found!")	
end

Maps.GetSimpleMapTable = function()
	local resultTable = {}
	for i,v in pairs (mapTable) do
		local map = {
			Title = v.Title,
			Artist = v.Artist,
			Cover = v.Cover,
			BPM = v.Difficulties[1].BPM
		}
		table.insert(resultTable, map)
	end
	
	return resultTable
end

Maps.UpdateBeatmap = function(title, difficulty, beatmap)
	local map = Maps.GetMapWithTitle(title)
	
	if map ~= nil then
		for i,v in pairs(map.Difficulties) do
			if v.Rating == difficulty then
				v.Beatmap[1] = beatmap
				return
			end
		end
	end
end

return Maps