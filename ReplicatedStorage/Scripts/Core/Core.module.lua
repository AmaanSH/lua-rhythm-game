-- Core class - responsible for the client setup of the game

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local levelManager = require(ReplicatedStorage.Scripts.Game:WaitForChild("LevelManager"))
local soundManager = require(ReplicatedStorage.Scripts.Game:WaitForChild("SoundManager"))
local inputManager = require(ReplicatedStorage.Scripts.Game:WaitForChild("InputManager"))
local cameraManager = require(ReplicatedStorage.Scripts.Game:WaitForChild("CameraManager"))
local lightingController = require(ReplicatedStorage.Scripts.Game:WaitForChild("LightingController"))
local beatmapManager = require(ReplicatedStorage.Scripts.Editor:WaitForChild("BeatmapManager"))
local uiController = require(ReplicatedStorage.Scripts.UI:WaitForChild("UIController"))
local screenController = require(ReplicatedStorage.Scripts.UI:WaitForChild("ScreenController"))
local eventManager = require(game.ReplicatedStorage.Events.EventManager)
local mapPanel = require(game.ReplicatedStorage.Scripts.Menus.MapSelectPanel)

local Core = {}

Core.Init = function(player)
	pcall(function()
		local starterGui = game:GetService('StarterGui')
		starterGui:SetCoreGuiEnabled("PlayerList", false)
		starterGui:SetCoreGuiEnabled("Chat", false)
		starterGui:SetCore("TopbarEnabled", false)			
	end)

	local player = game.Players.LocalPlayer
	
	-- init the events needed on the client
	eventManager.Init()
	
	cameraManager.Init()	
	uiController.Init(player)
	lightingController.Init()
	screenController.Init()
		
	uiController.EnableUI("loading")
		
	-- preload all audio
	local maps = eventManager.Trigger("MapsGetEvent", {eventManager.keys.getMapTable})
	local fx = eventManager.Trigger("MapsGetEvent", {eventManager.keys.getFXTable})
	soundManager.Init(fx, maps)	
						
	local notesArray = {}
	local targetArray = {}
	local startingPos = {}
		
	-- get the positions and values of notes in the scene and setup the level manager
	Core.setNoteValues(notesArray, targetArray, startingPos, player)
	levelManager.Init(notesArray, targetArray, startingPos)		
	levelManager.SetClientEvent()
			
	-- initialises the inputManager with the player's bindings
	local bindings = eventManager.Trigger("DataGetEvent", {eventManager.keys.getBindings})
	inputManager.Init(bindings)	
	levelManager.inputManager = inputManager
			
	local playerData = eventManager.Trigger("DataGetEvent", {eventManager.keys.getPlayerData})
	if playerData == nil then
		warn("player data not found")
	end
	
	local maps = eventManager.Trigger("MapsGetEvent", {eventManager.keys.getSimpleMapTable})
	mapPanel.SetupBeatmapMenu(player, maps)	
	uiController.BlurTransition(24, "menu")
	uiController.DisableUI("loading")																			
end

Core.initLatencyUI = function(player)	
	uiController.BlurTransition(24, "first_time_setup")
end

Core.setNoteValues = function(notesArray, targetArray, startArray, player)
	local notesFolder = game.ReplicatedStorage.Configuration:WaitForChild("Notes")
	local notesLocation = game.Workspace:WaitForChild("play_area")
	
	notesFolder.A.Start.Value = notesLocation.A.Position
	notesFolder.S.Start.Value = notesLocation.S.Position
	notesFolder.D.Start.Value = notesLocation.D.Position
	notesFolder.F.Start.Value = notesLocation.F.Position
	
	notesFolder.A_Long.Start.Value = notesLocation.A.Position
	notesFolder.S_Long.Start.Value = notesLocation.S.Position
	notesFolder.D_Long.Start.Value = notesLocation.D.Position
	notesFolder.F_Long.Start.Value = notesLocation.F.Position	
		
	table.insert(notesArray, notesFolder.A.Value) 
	table.insert(notesArray, notesFolder.S.Value)
	table.insert(notesArray, notesFolder.D.Value)
	table.insert(notesArray, notesFolder.F.Value)
	
	table.insert(notesArray, notesFolder.A_Long.Value) 
	table.insert(notesArray, notesFolder.S_Long.Value)
	table.insert(notesArray, notesFolder.D_Long.Value)
	table.insert(notesArray, notesFolder.F_Long.Value)	
	
	table.insert(targetArray, notesFolder.A.Target.Value) 
	table.insert(targetArray, notesFolder.S.Target.Value)
	table.insert(targetArray, notesFolder.D.Target.Value)
	table.insert(targetArray, notesFolder.F.Target.Value)
	
	table.insert(startArray, notesFolder.A.Start.Value) 
	table.insert(startArray, notesFolder.S.Start.Value)
	table.insert(startArray, notesFolder.D.Start.Value)
	table.insert(startArray, notesFolder.F.Start.Value)	
end

return Core