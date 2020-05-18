soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)
inputManager = require(game.ReplicatedStorage.Scripts.Game.InputManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local EditorConductor = {}
EditorConductor.__index = EditorConductor

function EditorConductor.new(sound, currentTrack, bpm)
	local conductor = {}	
	setmetatable(conductor, EditorConductor)
	
	conductor.state = environmentVariables.states.Monitoring	
	conductor.BPM = bpm
	conductor.tempo = 60 / bpm
	conductor.songPosition = 0
	conductor.offset = 0
	
	conductor.sound = currentTrack
	conductor.lastbeat = 0
	
	conductor.previousFrameTime = 0
	conductor.currentPlayheadPosition = 0
	conductor.lastReportedPlayheadPosition = 0
	
	conductor.startTime = time()
	conductor.previousFrameTime = conductor.GetTimer()
	conductor.lastReportedPlayheadPosition = 0
	
	conductor.currentIndex = 1	
	conductor.currentActiveNotes = {}
	
	soundManager.playAudio(sound)
	
	return conductor	
end

function EditorConductor:Monitor()
	self.songPosition = self.songPosition + (self:GetTimer() - self.previousFrameTime)
	self.previousFrameTime = self:GetTimer()

	if self.sound.TimePosition ~= self.lastReportedPlayheadPosition then
		self.songPosition = (self.songPosition + self.sound.TimePosition) / 2
		self.lastReportedPlayheadPosition = self.sound.TimePosition
	end	
	
	if self.songPosition > self.lastbeat + self.tempo then																						
		if self.songPosition <= 30 then	
			self.lastbeat = self.lastbeat + self.tempo		
			self.currentIndex = self.currentIndex + 1
		else
			self.state = environmentVariables.states.Finished																																																						
		end
	end																																																																					
end

function EditorConductor:GetTimer()
	return time()
end

return EditorConductor