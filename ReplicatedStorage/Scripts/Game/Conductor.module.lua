eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local Conductor = {}
Conductor.__index = Conductor

local soundManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("SoundManager"))
local lightingController = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("LightingController"))
local screenController = require(game.ReplicatedStorage.Scripts.UI:WaitForChild("ScreenController"))
local noteManager = require(game.ReplicatedStorage.Scripts.Game.NoteManager)
local heldNote = require(game.ReplicatedStorage.Scripts.Game.HeldNoteManager)
local gameUIPanel = require(game.ReplicatedStorage.Scripts.Menus.LevelPanel)

Conductor.new = function(sound, currentTrack, bpm, offset, beatmap, colours, levelNotes)
	local conductor = {}
	setmetatable(conductor, Conductor)
				
	conductor.state = environmentVariables.states.Monitoring
	conductor.BPM = bpm
	conductor.tempo = 60 / bpm
	conductor.songPosition = 0
	
	conductor.pitch = currentTrack.PlaybackSpeed
	conductor.sound = currentTrack
	conductor.offset = offset
	conductor.lastbeat = 0
	
	conductor.previousFrameTime = 0
	conductor.currentPlayheadPosition = 0
	conductor.lastReportedPlayheadPosition = 0
	
	conductor.startTime = time()
	conductor.previousFrameTime = Conductor.GetTimer()
	conductor.lastReportedPlayheadPosition = 0
	
	conductor.currentIndex = 1
	conductor.map = beatmap
	conductor.colours = colours
	conductor.notes = levelNotes
	
	conductor.keys = {}
	for k in pairs(conductor.map) do table.insert(conductor.keys, k) end
	table.sort(conductor.keys)
	
	conductor.currentActiveNotes = {}
	
	soundManager.playAudio(sound)
	return conductor
end

function Conductor:Monitor()		
	self.songPosition = self.songPosition + (self:GetTimer() - self.previousFrameTime)
	self.previousFrameTime = self:GetTimer()

	if self.sound.TimePosition ~= self.lastReportedPlayheadPosition then
		self.songPosition = (self.songPosition + self.sound.TimePosition) / 2
		self.lastReportedPlayheadPosition = self.sound.TimePosition
	end	
			
	if self.currentIndex ~= #self.keys then										
		if self.songPosition + (2) > self.map[self.keys[self.currentIndex]].Timestamp then				
			self.lastbeat = self.lastbeat + self.tempo
			
			-- note, step, currentActiveNotes, notes, offset, conductor	
			local chosenNote = Conductor:PrepareNote(self.map[self.keys[self.currentIndex]], self.keys[self.currentIndex], self.currentActiveNotes, self.notes, self.offset, self, self.colours)
			chosenNote:Drop(self)						 
			
			if environmentVariables.disableLighting ~= true then
				lightingController.Flash(self.colours.current)	
				
				if self.colours.current == "main" then
					self.colours.current = "secondary"
				else
					self.colours.current = "main"
				end					
			end
						
			self.currentIndex = self.currentIndex + 1																													
		end
	else
		if #self.currentActiveNotes ~= 0 then
			if environmentVariables.debugMode then
				print(#self.currentActiveNotes)				
			end
		else
			self.state = environmentVariables.states.Finished			
		end																																									
	end
	
  -- has the note reached the end?
	for i,v in pairs(self.currentActiveNotes) do
		if v.note ~= nil and v.note.held == false then
			if environmentVariables.calculatingLatency == true then
				if v.note.Value.Position.Z >= 112.3 then
					local strumBar = game.Workspace.play_area.seperators.strum_bar			
					strumBar.Material = Enum.Material.Neon	
				end				
			end							
			if v.note.Value.Position.Z >= 116.3 then			
				--print("removing: "..v.note.Value.Name)
				if environmentVariables.calculatingLatency == true then 
					local strumBar = game.Workspace.play_area.seperators.strum_bar			
					strumBar.Material = Enum.Material.SmoothPlastic				
				end
					
				v.note:Remove()
				v.note = nil										
				table.remove(self.currentActiveNotes, i)
			end			
		end
	end
end

function Conductor:Reset()
	self.currentIndex = 1
	self.songPosition = 0
	self.lastbeat = 0
	
	self.previousFrameTime = 0
	self.currentPlayheadPosition = 0
	self.lastReportedPlayheadPosition = 0
	
	self.startTime = time()
	self.previousFrameTime = Conductor.GetTimer()
	self.currentActiveNotes = {}
	self.state = environmentVariables.states.Monitoring
	soundManager.playAudio("BPM60")
end

function Conductor:PrepareNote(note, step, currentActiveNotes, notes, offset, conductor, colours)
	local noteFromDictionary = notes[note.NoteInformation.Type]
		
	local ClonedNote = notes[note.NoteInformation.Type].Note:Clone()	
				
	ClonedNote.Name = ClonedNote.Name.."-" ..step
	ClonedNote.Parent = noteFromDictionary.Target
		
	if environmentVariables.debugMode then
		Conductor:ShowNoteName(ClonedNote)	
	end
	
	if note.NoteInformation.held ~= nil then		
		local middleNode = ClonedNote:Clone()
		middleNode.Name = "node"
		middleNode.Parent = ClonedNote
				
		local oldPosition = ClonedNote.Size.Z
		middleNode.Size = Vector3.new(ClonedNote.Size.X, ClonedNote.Size.Y, note.NoteInformation.nodes[1].Length)
		middleNode.Position = middleNode.Position - Vector3.new(0,0, middleNode.Size.Z/2)
					
		heldNote.Conductor = conductor
		local Note = heldNote.new(note.Timestamp, {ClonedNote, middleNode}, noteFromDictionary.Target, offset, environmentVariables.debugMode, note.NoteInformation.isLong, note.NoteInformation.endTimestamp)
		local noteTable = {note = Note} 
		table.insert(currentActiveNotes, noteTable)	
		return Note		
	end	
	noteManager.Conductor = conductor
	
	local Note = noteManager.new(note.Timestamp, ClonedNote, noteFromDictionary.Target, offset, environmentVariables.debugMode, note.NoteInformation.isLong)
	local noteTable = {note = Note} 
	table.insert(currentActiveNotes, noteTable)						
	return Note							
end

function Conductor:RemoveAllNotes()
	for i,v in pairs(self.currentActiveNotes) do
		-- remove note from board
		v.note:Remove()
		-- remove reference to note object in memory
		v.note = nil
	end
	
	self.currentActiveNotes = {}
end

function Conductor:RemoveHeldNote(note)
	for i,v in pairs(self.currentActiveNotes) do
		if v.note.held == true then
			if v.note.Value[1] == note then
				v.note:Remove()
				v.note = nil
				table.remove(self.currentActiveNotes, i)
				return				
			end
		else
			print("note not found: "..note.Name)		
		end
	end
end

function Conductor:RemoveNote(note)
	if note ~= nil then			
		for i,v in pairs(self.currentActiveNotes) do
			if v.note ~= nil then
				--[[if v.note.held == true then
					v.note:Remove()
					v.note = nil
					table.remove(self.currentActiveNotes, i)
					return
				end]]
				
				if v.note.held ~= true and v.note.Value == note or v.note.Name == note then
					v.note:Remove()
					v.note = nil				
					table.remove(self.currentActiveNotes, i)
					return
				end
			else
				table.remove(self.currentActiveNotes, i)
				return				
			end				
		end							
	end	
end

-- Gets the correct note to check the user's hit against
function Conductor:GetNoteFromTable(target, timestamp)		
	for i,v in pairs(self.currentActiveNotes) do
		if v.note ~= nil and v.note.Target == target then
			local magnitude	= 9999
			if v.note.held == true then
				magnitude = (v.note.Value[1].Position - target.HITME.Position).Magnitude
			else
				magnitude = (v.note.Value.Position - target.HITME.Position).Magnitude	
			end
						
			if magnitude <= 10 then
				v.note.Hit = true
				local noteTable = {Note = v.note, Mag = math.floor(magnitude)}				
				return noteTable
			end			
		end		
	end
end

function Conductor:GetTimer()
	return time()
end

function Conductor:ShowNoteName(ClonedNote)
	local billboard = Instance.new("BillboardGui", ClonedNote)	
	billboard.Size = UDim2.new(9, 0, 2, 0)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	
	local frame = Instance.new("Frame", billboard)	
	frame.Size = UDim2.new(1.2, 0, 1.1, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 1
	
	local text = Instance.new("TextLabel", frame)
	text.Text = ClonedNote.Name
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.BorderSizePixel = 1
	text.TextScaled = true	
	text.Font = Enum.Font.SourceSansBold
	text.TextColor3 = Color3.fromRGB(0,0,0)
end

function Conductor:UpdateUI(target, scoreTable)
	Conductor.DisplayScore(target, scoreTable[1])			
	gameUIPanel.UpdateGameUI("score", scoreTable[2], true)
	gameUIPanel.UpdateGameUI("combo", scoreTable[3], true)
	gameUIPanel.UpdateGameUI("accuracy", scoreTable[5], true)			
end

function Conductor.DisplayScore(target, score)
	local textColour = Conductor.GetColourFromScore(score)
	gameUIPanel.SetHitVisual(target, score, textColour)
end

function Conductor:MissNoteVisual(target, grade)
	gameUIPanel.UpdateGameUI("accuracy", grade, true)	
	Conductor.DisplayScore(target, "Miss")	
end

Conductor.GetColourFromScore = function(score)
	if score == "Perfect" then
		return Color3.fromRGB(0,191,255)
	elseif score == "Good" then
		return Color3.fromRGB(34,139,34)
	elseif score == "Okay" then
		return Color3.fromRGB(255,140,0)
	else
		return Color3.fromRGB(139,0,0)
	end
end

return Conductor