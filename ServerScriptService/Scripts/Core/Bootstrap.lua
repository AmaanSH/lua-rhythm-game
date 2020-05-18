local Players = game:GetService("Players")
local playerManager = require(game.ServerScriptService.Scripts.Data:WaitForChild("PlayerInit"))
local mapMetadata = require(game.ServerScriptService.Scripts.Data.MapMetadata)
local soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)
local datastoreManager = require(game.ServerScriptService.Scripts.Data.DatastoreManager)
local eventManager = require(game.ReplicatedStorage.Events.EventManager)

local DS = datastoreManager.datastores

local initEvent = Instance.new("RemoteEvent")
initEvent.Parent = game.ReplicatedStorage.Events
initEvent.Name = "Init"

ServerSetup = function(player)	
	local mapNames = mapMetadata.GetMapTitleTable()			
	for i,v in pairs(mapNames) do
		local map = datastoreManager.GetData(DS.Beatmaps, v.Title)		
		if map == nil then
			warn("map with name "..v.Name.." does not exist!")
		else
			mapMetadata.InsertMap(map)		
		end								
	end
	
	mapMetadata.SetupEvents()		
end

Players.PlayerAdded:Connect(function(player)
	playerManager.Init(player)				
	initEvent:FireClient(player)
end)

Players.PlayerRemoving:Connect(function(player)	
	playerManager.handlePlayerLeave(player)
end)

ServerSetup()