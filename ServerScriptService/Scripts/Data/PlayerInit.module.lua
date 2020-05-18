local datastoreManager = require(game.ServerScriptService.Scripts.Data:WaitForChild("DatastoreManager"))
local levelManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("LevelManager"))
local soundManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("SoundManager"))
local cameraManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("CameraManager"))
local lightingController = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("LightingController"))
local scoreManager = require(game.ServerScriptService.Scripts.Game:WaitForChild("ScoreManager"))
local uiController = require(game.ReplicatedStorage.Scripts.UI:WaitForChild("UIController"))
local rhythmGameManager = require(game.ServerScriptService.Scripts.Data:WaitForChild("RhythmGameManager"))
local playerManagement = require(game.ServerScriptService.Scripts.Data.PlayerDataManager)
local eventManager = require(game.ReplicatedStorage.Events.EventManager)
local DS = datastoreManager.datastores

local module = {}

module.Init = function(player)					
	datastoreManager.SetEvents()

	local dataTable = datastoreManager.GetData(DS.Player, player.UserId.."_DATA")	
	if dataTable == nil then
		dataTable = module.setupNewPlayer(player)
	end	

	local manager = rhythmGameManager.new(player)					
	manager:SetPlayerData(dataTable)
	manager:SetPlayerBindings(
		game.ReplicatedStorage.Configuration.Bindings.button_1, 
		game.ReplicatedStorage.Configuration.Bindings.button_2, 
		game.ReplicatedStorage.Configuration.Bindings.button_3,
		game.ReplicatedStorage.Configuration.Bindings.button_4
	)

	playerManagement.AddPlayer(manager)
		
	-- create event to be able to retrieve a player from the client
	playerManagement.SetupEvent()	
	levelManager.SetupServerEvents()			
end

module.setupNewPlayer = function(player)	
	local dataTable = {
		visualLatency = 0,
		audioLatency = 0,
		totalPlaytime = 0,
		
		unlockedTracks = {},
		playedTracks = {},
		
		firstTime = true
	}		
	datastoreManager.SetData(player, DS.Player, player.UserId.."_DATA", dataTable)	
	return dataTable
end

module.handlePlayerLeave = function(player)
	local data = playerManagement.GetPlayer(player)

	if data ~= nil then
		if data.player_data ~= nil then
			if data.start_time ~= nil then
				data.player_data.totalPlaytime = data.player_data.totalPlaytime + os.difftime(os.time() - data.start_time)
			end	
				
			datastoreManager.SetData(player, DS.Player, player.UserId.."_DATA", data.player_data)			
		end
	end
end

return module