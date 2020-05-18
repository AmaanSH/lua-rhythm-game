eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVars = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local HeldNote = {}
HeldNote.__index = HeldNote

HeldNote.Conductor = false

function HeldNote.new(beat, value, target, offset, debugValue, isLong, endTime)
	local note = {}
	setmetatable(note, HeldNote)	
	note.Value = value
	note.Name = value.Name
	note.Timestamp = beat
	note.endTimestamp = endTime
	note.Target = target
	note.offset = offset
	note.held = true
	note.debug = debugValue
	note.Hit = false
	note.monitorHold = true
	return note
end

function HeldNote:Drop()			
	local dropRoutine = coroutine.wrap(function()
		while math.floor((self.Target.HITME.Position - self.Value[1].Position).Magnitude) ~= 0 do								
			self.Value[1].Position = self.Value[1].Position + Vector3.new(0, 0, (self.Timestamp - self.Conductor.songPosition) + self.offset)
			self.Value[2].Position = self.Value[2].Position + Vector3.new(0, 0, (self.Timestamp - self.Conductor.songPosition) + self.offset)							
			game["Run Service"].RenderStepped:wait()
		end
										
		if self.Hit == false and self.debug == false then		
			local grade = eventManager.Trigger("LevelGetEvent", {eventManager.keys.updateMissScore})	
			self.Conductor:MissNoteVisual(self.Target, grade)					
			self.Conductor:RemoveHeldNote(self.Value[1])
		end	
	end) 	
	dropRoutine()
end

function HeldNote:Remove()		
	self.Value[1]:Destroy()
	self.Value[2]:Destroy()	
end

function HeldNote:Start()
	-- we need to start decreasing the size of the note
	local heldRoutine = coroutine.wrap(function()
		while self.monitorHold == true do
			--if self.Value[2].Size.Z >= 2 then
				self.Value[2].Size = self.Value[2].Size - Vector3.new(0, 0, (self.endTimestamp - self.Conductor.songPosition) + self.offset)
				self.Value[2].Position = self.Value[2].Position + Vector3.new(0,0, ((self.endTimestamp - self.Conductor.songPosition) + self.offset) /2)						
			--end							
			game["Run Service"].RenderStepped:wait()
		end
					
		if self.monitorHold == false then
			self.Conductor:RemoveHeldNote(self.Value[1])			
		end	
	end)	
	heldRoutine()
end

return HeldNote