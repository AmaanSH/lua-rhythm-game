errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)
eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local levelManager = { notes = {}, colours = {}, Conductor = false, score = {}, inputManager = false}
local currentPlayerScoreObject

local TweenService = game:GetService("TweenService")
local soundManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("SoundManager"))
local conductor = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("Conductor"))
local lightingController = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("LightingController"))
local uiController = require(game.ReplicatedStorage.Scripts.UI:WaitForChild("UIController"))
local screenController = require(game.ReplicatedStorage.Scripts.UI:WaitForChild("ScreenController"))

local endLevelPanel = require(game.ReplicatedStorage.Scripts.Menus.EndLevelPanel)
local gameUIPanel = require(game.ReplicatedStorage.Scripts.Menus.LevelPanel)

levelManager.Init = function(notesArray, targetArray, startArray)			
	levelManager.notes = {
		[1] = {
			Note = notesArray[1],
			Target = targetArray[1],
			Start = startArray[1],
			IsLong = false,		
		},
		
		[2] = {
			Note = notesArray[2],
			Target = targetArray[2],
			Start = startArray[2],
			IsLong = false,						
		},
		
		[3] = {
			Note = notesArray[3],
			Target = targetArray[3],
			Start = startArray[3],
			IsLong = false,	
			Clone = false,					
		},
		
		[4] = {
			Note = notesArray[4],
			Target = targetArray[4],
			Start = startArray[4],
			IsLong = false,		
		},
		
		[5] = {
			Note = notesArray[5],
			Target = targetArray[1],
			Start = startArray[5],
			IsLong = true,
		},
		
		[6] = {
			Note = notesArray[6],
			Target = targetArray[2],
			Start = startArray[6],
			IsLong = true,		
		},
		
		[7] = {
			Note = notesArray[7],
			Target = targetArray[3],
			Start = startArray[7],
			IsLong = true,		
		},
		
		[8] = {
			Note = notesArray[8],
			Target = targetArray[4],
			Start = startArray[8],
			IsLong = true,			
		},					
	}
	
	local playerTable = { player = game.Players.LocalPlayer.Name, Conductor = false, score = false, inputManager = false}	
	table.insert(levelManager, playerTable)
end

levelManager.SetupServerEvents = function()	
	game.ReplicatedStorage.Events.Server.LevelManager.LevelSetEvent.OnServerEvent:Connect(levelManager.SetAction)
	game.ReplicatedStorage.Events.Server.LevelManager.LevelGetEvent.OnServerInvoke = levelManager.GetAction
end

levelManager.SetClientEvent = function()
	game.ReplicatedStorage.Events.Client.LevelManager.LevelSetEventClient.OnClientEvent:Connect(levelManager.SetAction)
end

function levelManager.GetKeyFromEnum(key)
	if key == eventManager.keys.setupScoreManager then
		return "setupScoreManager"
	elseif key == eventManager.keys.removeScoreManager then
		return "removeScoreManager"
	elseif key == eventManager.keys.noteRemoval then
		return "noteRemoval"
	elseif key == eventManager.keys.calculateHit then
		return "calculateHit"
	elseif key == eventManager.keys.updateMissScore then
		return "updateMissScore"
	elseif key == eventManager.keys.getTotalScores then
		return "getTotalScores"
	elseif key == eventManager.keys.getGrade then
		return "getGrade"
	end
end

levelManager.SetAction = function(player, dataTable)
	local key = dataTable[1]
	if environmentVariables.debugMode then	
		print(string.format("SET %s - %s", player.Name, levelManager.GetKeyFromEnum(key)))
	end
		
	if key == eventManager.keys.noteRemoval then
		levelManager.noteRemoval(dataTable[2])
		return	
	elseif key == eventManager.keys.setupScoreManager then
		levelManager.CreateScoreObject(player)
		return
	elseif key == eventManager.keys.removeScoreManager then
		levelManager.RemoveScoreManager(player)
		return	
	else
		local errorMessage = errorHandler.GetErrorMessage("levelmanger", errorHandler.errors.incorrect_key)
		return warn(errorHandler)
	end
end

levelManager.GetAction = function(player, dataTable)
	local key = dataTable[1]
	local score
	
	if environmentVariables.debugMode then		
		print(string.format("GET %s - %s", player.Name, levelManager.GetKeyFromEnum(key)))	
	end
	
	for i,v in pairs(levelManager.score) do
		if v.Player == player then
			score = v	
		end
	end
				
	if key == eventManager.keys.calculateHit then
		return score:CalculateHit(dataTable[2], dataTable[3], dataTable[4], dataTable[5])		
	elseif key == eventManager.keys.updateMissScore then
		return score:UpdateMissScore()	
	elseif key == eventManager.keys.getTotalScores then
		return score	
	elseif key == eventManager.keys.getGrade then
		return score:UpdateGrade(player, dataTable[2])
	elseif key == eventManager.keys.calculateGrade then
		return score:CalculateGrade(dataTable[2], dataTable[3])		
	else
		local errorMessage = errorHandler.GetErrorMessage("levelmanger", errorHandler.errors.incorrect_key)
		return warn(errorHandler)		
	end
end

levelManager.StartLevel = function(map, difficulty)
	local mainCol = map.LevelColours.Main
	local secondaryCol = map.LevelColours.Secondary	
	levelManager.colours = { main = mainCol, secondary = secondaryCol, current = "secondary" }	
	lightingController.SetColours(Color3.fromRGB(mainCol.r, mainCol.g, mainCol.b),Color3.fromRGB(secondaryCol.r, secondaryCol.g, secondaryCol.b))
	
	if map.Cover ~= nil then
		screenController.SetBackgroundImage(map.Cover)
		while screenController.screenParts.State == screenController.states.Setting do
			wait()
		end
	end
	
	--uiController.DisableUI("loading")
	uiController.EnableUI("main")
	
	wait(1)
	
	local offset = eventManager.Trigger("DataGetEvent", {eventManager.keys.getVisualLatency})		
	if offset ~= nil then
		print("current offset: "..offset)
	else
		offset = 0		
	end
		
	local bpm 
	local beatmap
			
	for i,v in pairs(map.Difficulties) do
		if map.Difficulties[i].Rating == difficulty then
			bpm = map.Difficulties[i].BPM	
			beatmap = map.Difficulties[i].Beatmap[1]
			currentMap = map.Difficulties[i].Beatmap[1]			
		else
			return error("Can't find difficulty specified!")			
		end
	end
		
	local currentTrack = soundManager.retrieveAudio(map.Title)
	levelManager.inputManager.StartMonitoring()
		
	local monitorThread = coroutine.wrap(function()
		local Conductor = conductor.new(map.Title, currentTrack, bpm, offset, beatmap, levelManager.colours, levelManager.notes)
		local states = environmentVariables.states		
		levelManager.Conductor = Conductor
		
		-- instantiate the score manager on the server
		eventManager.Trigger("LevelSetEvent", {eventManager.keys.setupScoreManager})
		
		if levelManager.score ~= nil and levelManager.Conductor ~= nil and environmentVariables.calculatingLatency ~= true then
			while Conductor.state ~= states.Finished do						
				Conductor:Monitor()															
				game["Run Service"].RenderStepped:wait()				
			end		
		else
			return warn("Score Manager or Conductor not initalised!")		
		end
		
		wait(1)
		
		-- handle cleanup								
		levelManager.Cleanup(Conductor)
		levelManager.EndLevel(map.Artist, map.Title)							
	end)
	monitorThread()	
end

function levelManager.CreateScoreObject(player)
	local scoreManager = require(game.ServerScriptService.Scripts.Game:WaitForChild("ScoreManager"))	
	local score = scoreManager.new(player)
	
	if score == nil then
		return warn("score object has not been created!")
	end
	
	table.insert(levelManager.score, score)		
end

function levelManager.RemoveScoreManager(player)
	for i,v in pairs(levelManager.score) do
		if v.Player == player then
			v = nil
		end
	end
end

levelManager.hitTarget = function(target, noteTouched, songPosition)			
	if noteTouched ~= nil then
		-- calculate score on the server
		local score = eventManager.Trigger("LevelGetEvent", {eventManager.keys.calculateHit, #currentMap, songPosition, noteTouched})
		
		-- update ui with the score and show hit visual
		levelManager.Conductor:UpdateUI(target, score)
		
		-- remove the note		
		levelManager.Conductor:RemoveNote(score[4])						
	end
end

levelManager.HighlightLane = function(target, toggle)
	if toggle == false then
		target.TRACK.Color = Color3.fromRGB(85, 85, 255)			
		target.TRACK.Material = Enum.Material.Neon
	else
		target.TRACK.Color = Color3.fromRGB(231, 231, 236)
		target.TRACK.Material = Enum.Material.SmoothPlastic			
	end
end

levelManager.noteRemoval = function(note)
	levelManager.Conductor:RemoveNote(note)
end

function levelManager.Cleanup(Conductor)
	-- stop monitoring the user's input
	levelManager.inputManager.unbindActions()
	
	-- reset the lane colours?
	-- hide image on level screen
	screenController.HideBackgroundImage()
	
	levelManager.Conductor = false
	Conductor = nil		
end

levelManager.EndLevel = function(artist, title)	
	local scores = eventManager.Trigger("LevelGetEvent", {eventManager.keys.getTotalScores})
	local grade = eventManager.Trigger("LevelGetEvent", {eventManager.keys.getGrade, title})
			
	endLevelPanel.SetupEndLevelScreen(artist, title, scores.Combo.maxCombo, scores.Good.Total, scores.Okay.Total, scores.Perfect.Total, scores.Miss.Total, scores.Score.Total, grade)
				
	gameUIPanel.UpdateGameUI("score", 0, false)
	gameUIPanel.UpdateGameUI("combo", 0, false)	
	uiController.DisableUI("main")
	
	eventManager.Trigger("LevelSetEvent", {eventManager.keys.removeScoreManager})	
end

return levelManager