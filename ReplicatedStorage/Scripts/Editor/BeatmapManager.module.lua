local BeatmapManager = {}

local environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)
local soundManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("SoundManager"))
local editorConductor = require(game.ReplicatedStorage.Scripts.Editor:WaitForChild("EditorConductor"))
local beatPoints = require(game.ReplicatedStorage.Scripts.Editor.BeatPoints)
local levelManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("LevelManager"))
local inputManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("InputManager"))
local uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)

local eventManager = require(game.ReplicatedStorage.Events.EventManager)
local errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)

-- WIP! --
BeatmapManager.SetupMap = function()
	local map = 
	{
		Artist = "Hatsune Miku",
		Title = "Packaged",
		SongID = 160937946,
		Cover = 149022074,
		Volume = 30,				
		Difficulties = {
			[1] = {
				Rating = "Easy",
				flowRate = 0.7,								
				BPM = 125,
				Beatmap = {}				
			},
		},
		LevelColours = {
			Main = {r = 225, g = 40, b = 133},
			Secondary = {r = 19, g = 122, b = 127}
		},																
	}
	
	soundManager.preloadAudio({[map.Title] = map.SongID}, map.Volume)
	print("BEATMAP: audio preloaded")		
	
	local editorUI = uiController.GetUIFromTable("editor")		
	uiController.UpdateText("editor", editorUI.Frame.NAME, map.Artist.." - "..map.Title)
	uiController.EnableUI("editor")
	uiController.TweenIn(editorUI.Frame, editorUI.Frame.Position.X.Scale, editorUI.Frame.Position.Y.Scale, 1)
					
	BeatmapManager.generateNewBeatmap(map, "Easy")			
end

BeatmapManager.generateNewBeatmap = function(map, diff)
	print("BEATMAP: Notes being generated. This might take a while, go grab a coffee or something")			
	BeatmapManager.generateBeatPoints(map.Title, map, diff, levelManager.notes)	
end

BeatmapManager.generateBeatPoints = function(sound, map, diff, notesArray)
	local lastbeat = 0	
	local currentStep = 0
	
	local beatmap = {}
	local mapArray = {}
	
	local difficulty = {}
	local bpm 
			
	for i,v in pairs(map.Difficulties) do
		if map.Difficulties[i].Rating == diff then
			bpm = map.Difficulties[i].BPM	
			table.insert(difficulty, 1, i)
			table.insert(difficulty, 2, map)						
			beatmap = map.Difficulties[i].Beatmap	
		else
			local errorMessage = errorHandler.GetErrorMessage("beatmapmanager", errorHandler.errors.cant_find_diff)
			return error(errorMessage)			
		end
	end
	
	local currentTrack = soundManager.retrieveAudio(sound)
						
	local monitorThread = coroutine.wrap(function()	
		local beatPointManager = beatPoints.new(sound, currentTrack, bpm, mapArray, levelManager.notes)
								
		while currentTrack.IsPlaying do	
			beatPointManager:Generate()																																																																																													
			game["Run Service"].RenderStepped:wait()				
		end	
		
		beatPointManager = nil
			
		print("A beatmap has been generated! Total Notes: " .. #mapArray)
		table.insert(beatmap, mapArray)
		
		print("Attempting to save..")
		eventManager.Trigger("DatastoreSetEvent", {eventManager.keys.Update, environmentVariables.datastores.Beatmaps, map.Title, map })				
	end)	
	monitorThread()	
end

return BeatmapManager