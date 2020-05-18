local PlayerData = {}
PlayerData.__index = PlayerData

function PlayerData.new(player, instance)
	local manager = {}
	setmetatable(manager, PlayerData)
	
	manager.player = player
	
	manager.editorMode = false
	manager.debugMode = false
	manager.calculatingLatency = false	
	manager.disableLighting = false
	manager.disableLyrics = false
	
	manager.start_time = os.time()	
	manager.bindings = {}					
	manager.player_data = {}		
	
	manager.LatencyController = false			
	return manager		
end

function PlayerData:SetLatency(player, value)
	self.player_data.visualLatency = value
end

function PlayerData:SetAudioLatency(player, value)
	self.player_data.audioLatency = value
end

function PlayerData:SetConductor(conductor)
	self.Conductor = conductor
end

function PlayerData:SetInputManager(inputManager)
	self.InputManager = inputManager
end

function PlayerData:GetInputManager()
	return self.InputManager
end

function PlayerData:SetLatencyController(latencyController)
	self.LatencyController = latencyController
end

function PlayerData:SetPlayerData(data)
	self.player_data = data
end

function PlayerData:GetPlayerData()
	return self.player_data
end

function PlayerData:SetFirstTimeFlag(player, value)
	self.player_data.firstTime = value
end

function PlayerData:SetTotalPlaytime(player, value)
	self.player_data.totalPlaytime = value
end

function PlayerData:UpdateTrackScore(trackName, totalScore, totalCombo, grade)
	for i,v in pairs(self.player_data.playedTracks) do
		if v.Track == trackName then
			v.Score = totalScore
			v.Combo = totalCombo
			v.Grade = grade
		end
	end
end

function PlayerData:SetTrackScore(trackName, totalScore, totalCombo, grade)
	local scoreTable = {
		Track = trackName,
		Score = totalScore,
		Combo = totalCombo,
		Grade = grade
	}
	table.insert(self.player_data.playedTracks, scoreTable)
end

function PlayerData:GetTrackScore(trackName)
	for i,v in pairs(self.player_data.playedTracks) do
		if v.Track == trackName then
			return v
		end
	end
end

function PlayerData:GetPlayerBindings()
	return self.bindings
end

function PlayerData:SetPlayerBindings(key1, key2, key3, key4)
	table.insert(self.bindings, key1)
	table.insert(self.bindings, key2)
	table.insert(self.bindings, key3)
	table.insert(self.bindings, key4)
end

function PlayerData:UpdatePlayerBindings(index, newKey)
	self.bindings[index] = newKey
end

function PlayerData:GetLatency()
	return self.player_data.visualLatency
end

function PlayerData:GetAudioLatency()
	return self.player_data.audioLatency
end

return PlayerData