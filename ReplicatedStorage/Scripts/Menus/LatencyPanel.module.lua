eventManager = require(game.ReplicatedStorage.Events.EventManager)
soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)
evnironmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)
conductor = require(game.ReplicatedStorage.Scripts.Game.Conductor)
levelManager = require(game.ReplicatedStorage.Scripts.Game.LevelManager)
lightingController = require(game.ReplicatedStorage.Scripts.Game.LightingController)
uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)

local module = {}
local map = {}

module.currentLatency = 0.000
module.adjustedLatency = 0.000
local step = 0.002
local operator = "+"
local stop = false

local canIncrease = true
module.Conductor = false

function module.Init()	
	soundManager.preloadAudio({["BPM60"] = 4432996303}, 2)		
	local currentTrack = soundManager.retrieveAudio("BPM60")		
	map = {		
		[0] = {
			Timestamp = 0,
			Debug = true,
			NoteInformation = {
				Type = 1,						
				Length = 3,
				isLong = false,	
				HitSound = "normal-hit"											
			}			
		},
		
		[1] = {
			Timestamp = 2,
			Debug = true,
			NoteInformation = {
				Type = 1,						
				Length = 3,
				isLong = false,	
				HitSound = "normal-hit"											
			}			
		},
		
		[2] = {
			Timestamp = 4,
			Debug = true,
			NoteInformation = {
				Type = 1,						
				Length = 3,
				isLong = false,	
				HitSound = "normal-hit"											
			}			
		},
		
		[3] = {
			Timestamp = 6,
			Debug = true,
			NoteInformation = {
				Type = 1,						
				Length = 3,
				isLong = false,	
				HitSound = "normal-hit"											
			}			
		},		
	}	
end

function module.StartConductor(showWait)
	if showWait == true then
		wait(1)		
	end

	local bpm = 60
	
	print("current offset: "..module.currentLatency)
	
	local currentTrack = soundManager.retrieveAudio("BPM60")		
	local monitorThread = coroutine.wrap(function()
		-- sound, currentTrack, bpm, offset, beatmap, colours, levelNotes
		module.Conductor = conductor.new("BPM60", currentTrack, bpm, module.currentLatency, map, {}, levelManager.notes)			
				
		while module.Conductor ~= nil and module.Conductor.state == evnironmentVariables.states.Monitoring do
			if stop == true then
				module.Conductor.state = evnironmentVariables.states.Finished
			end
			
			module.Conductor:Monitor()
			game["Run Service"].RenderStepped:wait()
		end
		module.Restart()
		return
	end)
	
	monitorThread()		
end

function module.Restart()
	if module.Conductor ~= nil then
		wait()
		soundManager.stopAudio("BPM60")
		module.Conductor:RemoveAllNotes()
		
		module.Conductor = nil
		module.Conductor = false
		
		module.StartConductor(false)
		return		
	end
end

function module.Stop()
	module.Conductor:RemoveAllNotes()
	soundManager.stopAudio("BPM60")	
	module.Conductor = nil
	module.Conductor = false		
end

function module.SetLatency()
	-- stop the conductor from running
	if module.Conductor ~= nil then
		module.Stop()		
	end
	
	local strumBar = game.Workspace.play_area.seperators.strum_bar			
	strumBar.Material = Enum.Material.SmoothPlastic
	
	module.currentLatency = module.adjustedLatency
	
	-- restart the conductor with the new offset
	module.StartConductor(false)	
end

function module.IncreaseLatency(text)
	if module.currentLatency >= 1 then
		canIncrease = false
	else
		canIncrease = true		
	end
	
	if canIncrease then
		if module.currentLatency >= 0 then
			operator = "+"
		else
			operator = ""
		end
		
		module.adjustedLatency = (module.adjustedLatency) + step
		text.Text = tostring(operator..module.adjustedLatency).." SEC"		
	end
end

function module.DecreaseLatency(text)
	if module.currentLatency > -1 then
		canIncrease = true
	else
		canIncrease = false
	end
		
	if canIncrease then
		if module.currentLatency > 0 then
			operator = "+"
		else
			operator = ""
		end
				
		module.adjustedLatency = (module.adjustedLatency) - step
		text.Text = tostring(operator..module.adjustedLatency).." SEC"		
	end
end

function module.Save()	
	-- save the set latency to the player
	eventManager.Trigger("DataSetEvent", {eventManager.keys.setVisualLatency, module.currentLatency})

	-- stop the conductor if its playing
	if module.Conductor ~= nil then
		module.Conductor:RemoveAllNotes()		
		module.Conductor = nil		
	end	
	
	-- remove audio
	local currentTrack = soundManager.retrieveAudio("BPM60")
	currentTrack:Destroy()
end

return module
