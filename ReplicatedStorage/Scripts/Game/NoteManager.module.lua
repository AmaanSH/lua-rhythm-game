eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVars = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local Note = {}
Note.__index = Note

Note.Conductor = false

function Note.new(beat, value, target, offset, debugValue, isLong)
	local note = {}
	setmetatable(note, Note)
	
	note.Value = value
	note.Name = value.Name
	note.Timestamp = beat
	note.Target = target
	note.offset = offset
	note.held = false
	note.debug = debugValue
	note.Hit = false

	return note
end

function Note:Drop()			
	local dropRoutine = coroutine.wrap(function()
		while self.Conductor.songPosition ~= nil and self.Conductor.songPosition <= self.Timestamp and self.Conductor.state ~= environmentVars.states.Paused do								
			self.Value.Position = self.Value.Position + Vector3.new(0, 0, (self.Timestamp - self.Conductor.songPosition) + self.offset)							
			game["Run Service"].RenderStepped:wait()
		end
						
		if self.Conductor.songPosition == nil then
			return			
		end
		
		if self.Hit == false and self.debug == false then	
			if environmentVars.calculatingLatency ~= true then
				local grade = eventManager.Trigger("LevelGetEvent", {eventManager.keys.updateMissScore})	
				self.Conductor:MissNoteVisual(self.Target, grade)				
			end					
			self.Conductor:RemoveNote(self.Value)				
		end			
	end) 	
	dropRoutine()
end

function Note:Remove()		
	self.Value:Destroy()				
end

return Note