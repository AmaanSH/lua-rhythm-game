errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)

local EventManager = {}

EventManager.events = { Server = { Get = {}, Set = {} }, Client = { Get = {}, Set = {}}}
EventManager.keys = {
	setVisualLatency = 0,
	setAudioLatency = 1,
	setPlayerData = 2,
	getPlayerData = 3,
	firstTimeFlag = 4,
	setTotalPlaytime = 5,
	updateTrackScore = 6,
	setTrackScore = 7,
	getTrackScore = 8,
	getBindings = 9,
	setBindings = 10,
	updateBindings = 11,
	getVisualLatency = 12,
	getAudioLatency = 13,
	setConductor = 14,
	setInputManager = 15,
	setLatencyController = 16,
	getInputManager = 17,
	getPlayerManager = 18,
	
	setupScoreManager = 19,
	removeScoreManager = 20,
	noteRemoval = 21,
	calculateHit = 22,
	updateMissScore = 23,
	getTotalScores = 24,
	getGrade = 25,
	calculateGrade = 26,
	
	Update = 27,
	
	getSimpleMapTable = 28,
	getMapWithTitle = 29,
	getMapTable = 30,
	getFXTable = 31,
	getBeatmap = 32,
	updateBeatmap = 33,
}

function EventManager.Init()
	for i,v in pairs(game.ReplicatedStorage.Events:GetChildren()) do
		if v.Name == "Server" then
			for s, server_event in pairs(v:GetDescendants()) do
				if server_event:IsA("RemoteEvent") then
					table.insert(EventManager.events.Server.Set, server_event)
				elseif server_event:IsA("RemoteFunction") then
					table.insert(EventManager.events.Server.Get, server_event)				
				end
			end	
		elseif v.Name == "Client" then
			for c, client_event in pairs(v:GetDescendants()) do
				if client_event:IsA("RemoteEvent") then
					table.insert(EventManager.events.Client.Set, client_event)
				elseif client_event:IsA("RemoteFunction") then
					table.insert(EventManager.events.Client.Get, client_event)				
				end
			end			
		end
	end
end

function EventManager.Trigger(event, params, player) 
	if type(params) ~= "table" then
		local errorMessage = errorHandler.GetErrorMessage("eventmanager", errorHandler.errors.params_not_table)
		return warn(errorMessage)
	end
	
	for g, getEvent in pairs(EventManager.events.Server.Get) do
		if getEvent.Name == event then
			return getEvent:InvokeServer(params)
		end			
	end
	
	for s, setEvent in pairs(EventManager.events.Server.Set) do
		if setEvent.Name == event then
			setEvent:FireServer(params)
			return
		end
	end
	
	for g, getEvent in pairs(EventManager.events.Client.Get) do
		if getEvent.Name == event then
			return getEvent:InvokeClient(params)				
		end
	end
	
	for s, setEvent in pairs(EventManager.events.Client.Set) do
		if setEvent.Name == event then
			if setEvent.FireAllClients.Value == true then
				setEvent:FireAllClients(params)
				return
			else
				setEvent:FireClient(player, params)	
				return				
			end
		end
	end

	local errorMessage = errorHandler.GetErrorMessage("eventmanager", errorHandler.errors.event_not_found, {event})
	return warn(errorMessage)
end

return EventManager
