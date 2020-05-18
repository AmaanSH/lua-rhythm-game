local Latency = {}
Latency.__index = Latency

local rhythmGameManager = require(game.ReplicatedStorage.Scripts.Core.RhythmGameManager)

function Latency.new(event)
	local latency = {}
	setmetatable(latency, Latency)
		
	latency.table = {}	
	latency.userInputTime = 0
	latency.audioTime = 0
	latency.event = event
	
	rhythmGameManager.calculatingLatency = true
	
	return latency	
end

function Latency:CalculateLatency()
	local sum = 0
	local avg = 0
	
	local elements = #self.table
	local latencyTable = self.table
		
	for i=1,elements do
		sum = sum + latencyTable[i]
	end
	
	avg = sum / elements	
	
	if tostring(avg) == "-nan(ind)" then
		return false
	else
		print("Latency has been calculated as: "..avg)	
		self.event:FireServer(avg)
		return true		
	end
end

function Latency:CalculateDelay()
	if self.event.Name == "SetVisualLatency" then
		print("visual latency test")
		local offset = rhythmGameManager.events.getPlayerAudioLatency:InvokeServer()
		self.userInputTime = self.userInputTime - offset		
	end
	
	local latency = self.userInputTime - self.audioTime
	print(latency)
	table.insert(self.table, latency) 
	self.userInputTime = 0
end

function Latency:SetAudioTime(audioTime)
	self.audioTime = audioTime
end

function Latency:GetUserInputTime()
	return self.userInputTime
end

return Latency