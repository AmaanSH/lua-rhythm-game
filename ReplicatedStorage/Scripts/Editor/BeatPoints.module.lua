soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)

local BeatPoints = {}
BeatPoints.__index = BeatPoints

function BeatPoints.new(sound, currentTrack, bpm, beatmap, levelNotes)
	local generateBeatPoints = {}	
	setmetatable(generateBeatPoints, BeatPoints)
	
	generateBeatPoints.BPM = bpm
	generateBeatPoints.tempo = 60 / bpm
	generateBeatPoints.songPosition = 0
	
	generateBeatPoints.sound = currentTrack
	generateBeatPoints.lastbeat = 0
	
	generateBeatPoints.previousFrameTime = 0
	generateBeatPoints.currentPlayheadPosition = 0
	generateBeatPoints.lastReportedPlayheadPosition = 0
	
	generateBeatPoints.startTime = time()
	generateBeatPoints.previousFrameTime = BeatPoints.GetTimer()
	generateBeatPoints.lastReportedPlayheadPosition = 0
	
	generateBeatPoints.currentIndex = 0
	generateBeatPoints.map = beatmap
	generateBeatPoints.notes = levelNotes
	
	generateBeatPoints.currentActiveNotes = {}
	
	soundManager.playAudio(sound)
	
	return generateBeatPoints	
	
end

-- Methods for generating notes
function BeatPoints:Generate()
	self.songPosition = self.songPosition + (self:GetTimer() - self.previousFrameTime)
	self.previousFrameTime = self:GetTimer()

	if self.sound.TimePosition ~= self.lastReportedPlayheadPosition then
		self.songPosition = (self.songPosition + self.sound.TimePosition) / 2
		self.lastReportedPlayheadPosition = self.sound.TimePosition
	end	
	
	if self.songPosition > self.lastbeat + self.tempo then
		local noteIterator = math.random(1, 4)
					
		local beatInformation = {
			Timestamp = self.songPosition,
			Beat = self.lastbeat,
			NoteInformation = {
				Type = noteIterator,						
				Length = 3,
				isLong = false,	
				HitSound = "normal-hit"											
			}
		}				
		print("NOTE GEN: "..self.currentIndex.." Timestamp: "..beatInformation.Timestamp.." Beat: "..self.lastbeat.." Note Type: ".. beatInformation.NoteInformation.Type)				
		table.insert(self.map, self.currentIndex, beatInformation)
		
		self.lastbeat = self.lastbeat + self.tempo
		self.currentIndex = self.currentIndex + 1																																																								
	end		
end

function BeatPoints:GetTimer()
	return time()
end

return BeatPoints