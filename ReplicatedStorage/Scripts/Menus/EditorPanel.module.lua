eventManager = require(game.ReplicatedStorage.Events.EventManager)
uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)
soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)
conductor = require(game.ReplicatedStorage.Scripts.Game.Conductor)
levelManager = require(game.ReplicatedStorage.Scripts.Game.LevelManager)

local module = {}
local map
local mapTitle = ""
local bpm

local ui
local selectedNoteFrame
local hasUpdated = false

function module.Init(title, mapBpm)	
	map = ""
	mapTitle = ""
	bpm = ""	
	hasUpdated = false	
	module.Conductor = nil

	environmentVariables.calculatingLatency = true
	environmentVariables.disableLighting = true
		
	-- load in the map data
	map = eventManager.Trigger("MapsGetEvent", {eventManager.keys.getBeatmap, title, "Easy"})
	mapTitle = title
	bpm = mapBpm

	ui = uiController.GetUIFromTable("beatmapEditor")
	selectedNoteFrame = ui.selected_notes
	
	for i,v in pairs(map) do
		local noteFrame = game.ReplicatedStorage.Components.note_information:Clone()
		noteFrame.Parent = ui.all_notes.note_frame
		noteFrame.Name = noteFrame.Name.."_"..i
		noteFrame.select.SelectNote.Disabled = false
		
		-- set the values in the frame
		noteFrame.noteID.Text = "Note Type: "..module.GetNoteType(v.NoteInformation.Type)
		noteFrame.count.Text = "Count: "..i
		noteFrame.timestamp.Text = "Timestamp: "..v.Timestamp
	end
	
	local UIListLayout = ui.all_notes.note_frame.UIListLayout
	local contentSize = UIListLayout.AbsoluteContentSize
	ui.all_notes.note_frame.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
end

function module.Play()
	-- disable the play button
	ui.conductor_controls.play.Play.Disabled = true
	
	stop = false
	module.Conductor = nil
	environmentVariables.debugMode = true
	
	local currentTrack = soundManager.retrieveAudio(mapTitle)		
	local monitorThread = coroutine.wrap(function()
		-- sound, currentTrack, bpm, offset, beatmap, colours, levelNotes
		module.Conductor = conductor.new(mapTitle, currentTrack, bpm, 0, map, {}, levelManager.notes)		
		while module.Conductor ~= nil and module.Conductor.state == environmentVariables.states.Monitoring do
			if stop == true then
				module.Conductor.state = environmentVariables.states.Finished
			end
			
			module.Conductor:Monitor()
			game["Run Service"].RenderStepped:wait()
		end
		
		stop = false		
		
		-- enable the play button
		ui.conductor_controls.play.Play.Disabled = false
				
		module.Conductor = nil		
		soundManager.stopAudio(mapTitle)
	end)
	
	monitorThread()	
end

function module.Stop()
	-- stop the conductor from running
	if module.Conductor ~= nil then
		stop = true	
		module.Conductor:RemoveAllNotes()
		
		-- enable the play button
		ui.conductor_controls.play.Play.Disabled = false				
	end	
end

function module.createHeldNote(current)	
	-- map has been changed
	hasUpdated = true

	local currentNote = map[current]
	local lastNote = map[current + 1]
	
	local target = module.GetTargetFromNote(currentNote.NoteInformation.Type)
	local firstNoteName = module.GetNoteType(currentNote.NoteInformation.Type).."-"..current
	local secondNoteName = module.GetNoteType(lastNote.NoteInformation.Type).."-"..current+1
		
	local firstNotePosition = 0
	local lastNotePosition = 0
	for i,v in pairs(game.Workspace.play_area:FindFirstChild(target):GetChildren()) do
		if v.Name == firstNoteName then
			firstNotePosition = v.Position
		elseif v.Name == secondNoteName then
			lastNotePosition = v.Position
		end				
	end
	
	-- we need to convert the held notes into one
	currentNote.NoteInformation.nodes = {}
	currentNote.NoteInformation.held = true
	currentNote.NoteInformation.endTimestamp = lastNote.Timestamp
	
	
	-- middle note node
	local distance = (firstNotePosition - lastNotePosition).Magnitude
	local middleNode = {
		Length = distance,
	}
	table.insert(currentNote.NoteInformation.nodes, middleNode)
		
	-- we need to remove these notes from the beatmap
	table.remove(map, current + 1)	
end

function module.GetTargetFromNote(noteType)
	if noteType == 1 then
		return "A_Target"
	elseif noteType == 2 then
		return "S_Target"
	elseif noteType == 3 then
		return "D_Target"
	else
		return "F_Target"
	end
end

function module.updateNoteType(current, new)	
	-- map has been changed
	hasUpdated = true

	if module.Conductor ~= nil then
		module.Stop()
	end
	
	-- update the note type
	map[current].NoteInformation.Type = new
	
	-- update the type on the note frame
	for i,v in pairs(ui.all_notes.note_frame:GetChildren()) do
		local stringTable = v.Name:split("_")
		
		if tonumber(stringTable[3]) == current then
			v.noteID.Text = "Note Type: "..module.GetNoteType(new)
			return
		end		
	end	
end

function module.removeNote(current)
	-- map has been changed
	hasUpdated = true
	
	-- stop the conductor if its playing
	if module.Conductor ~= nil then
		module.Stop()
	end	
	
	-- remove the note from the beatmap
	table.remove(map, current)
	
	-- hide the selected note frame
	selectedNoteFrame.Visible = false
	
	-- remove it from the total note frame
	for i,v in pairs(ui.all_notes.note_frame:GetChildren()) do
		local stringTable = v.Name:split("_")
		
		if tonumber(stringTable[3]) == current then
			v:Destroy()
			return
		end		
	end
end

function module.ShowNoteInformation(count)
	local note = map[count]
	
	selectedNoteFrame.typeValue.Text = module.GetNoteType(note.NoteInformation.Type)
	selectedNoteFrame.timestamp.Text = note.Timestamp
	selectedNoteFrame.noteID.Text = "Iterator: "..count
	selectedNoteFrame.Visible = true
end

function module.Save(updateText)
	eventManager.Trigger("MapsSetEvent", {eventManager.keys.updateBeatmap, mapTitle, "Easy", map})	
end

function module.Back()
	local cameraManager = require(game.ReplicatedStorage.Scripts.Game.CameraManager)
	
	-- stop the conductor running
	if module.Conductor ~= nil then
		module.Stop()
	end
	
	-- remove all the notes from the frame
	for i,v in pairs(ui.all_notes.note_frame:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	
	-- enable the loading screen anf disable the current ui
	uiController.EnableUI("loading")
	uiController.DisableUI("beatmapEditor")	
	
	environmentVariables.calculatingLatency = false
	environmentVariables.disableLighting = false
	environmentVariables.debugMode = false
	
	if hasUpdated == true then
		-- update the map datastore on the server	
		print("Attempting to update..")
		local mapTable = eventManager.Trigger("MapsGetEvent", {eventManager.keys.getMapWithTitle, mapTitle})
		eventManager.Trigger("DatastoreSetEvent", {eventManager.keys.Update, environmentVariables.datastores.Beatmaps, mapTitle, mapTable})	
	end
	
	local target = cameraManager.GetCameraWithName("HomeCam")	
	local cameraTween = cameraManager.TweenCamera(target, Enum.CameraType.Scriptable, 70, {CoordinateFrame = CFrame.new(target.Position) * CFrame.Angles(100, 0, 0) * CFrame.new(0, 0, 0)})	

	local menuUI = uiController.GetUIFromTable("menu")
	uiController.SetPosition(menuUI.Main.beatmaps.leaderboard, UDim2.new(-1, 0, 0.25, 0))
	uiController.SetPosition(menuUI.Main.beatmaps.songs, UDim2.new(2, 0, 0.25, 0))
	
	wait(1)	
	uiController.DisableUI("loading")
	uiController.EnableUI("menu")
	--uiController.BlurTransition(24, "menu")
	uiController.TweenIn(menuUI.Main.beatmaps.songs, 1, menuUI.Main.beatmaps.songs.Position.Y.Scale, 0.5)
end

function module.GetEnumFromString(note)
	if note == "A" then
		return 1
	elseif note == "S" then
		return 2
	elseif note == "D" then
		return 3
	else
		return 4
	end
end

function module.GetNoteType(id)
	if id == 1 then
		return "A"
	elseif id == 2 then
		return "S"
	elseif id == 3 then
		return "D"
	else
		return "F"
	end
end

return module
