errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)
eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local module = {}

module.playerData = {}

function module.SetupEvent()
	game.ReplicatedStorage.Events.Server.PlayerData.DataSetEvent.OnServerEvent:Connect(module.SetAction)
	game.ReplicatedStorage.Events.Server.PlayerData.DataGetEvent.OnServerInvoke = module.GetAction
end

function module.GetPlayer(player)
	for i,v in pairs(module.playerData) do
		if v.player == player then
			return v
		end
	end
	
	local errorMessage = errorHandler.GetErrorMessage("playerdatamanager" ,errorHandler.errors.player_not_found)
	return warn(errorMessage)
end

function module.AddPlayer(playerManager)
	table.insert(module.playerData, playerManager)
end

function module.GetKeyFromEnum(key)
	if key == eventManager.keys.firstTimeFlag then
		return "firstTimeFlag"
	elseif key == eventManager.keys.getAudioLatency then
		return "getAudioLatency"
	elseif key == eventManager.keys.getBindings then
		return "getBindings"
	elseif key == eventManager.keys.getPlayerData then
		return "getPlayerData"
	elseif key == eventManager.keys.getTrackScore then
		return "getTrackScore"
	elseif key == eventManager.keys.getVisualLatency then
		return "getVisualLatency"
	elseif key == eventManager.keys.setAudioLatency then
		return "setVisualLatency" 
	elseif key == eventManager.keys.setBindings then
		return "setBindings"
	elseif key == eventManager.keys.setConductor then
		return "setConductor"
	elseif key == eventManager.keys.setInputManager then
		return "setInputManager"
	elseif key == eventManager.keys.setLatencyController then
		return "setLatencyController"
	elseif key == eventManager.keys.setPlayerData then
		return "setPlayerData"
	elseif key == eventManager.keys.setTotalPlaytime then
		return "setTotalPlaytime"
	elseif key == eventManager.keys.setTrackScore then
		return "setTrackScore"
	elseif key == eventManager.keys.setVisualLatency then
		return "setVisualLatency"
	elseif key == eventManager.keys.updateBindings then
		return "updateBindings"
	elseif key == eventManager.keys.updateTrackScore then
		return "updateTrackScore"
	elseif key == eventManager.keys.getInputManager then
		return "getInputManager"
	elseif key == eventManager.keys.getPlayerManager then
		return "getPlayerManager"
	end
end

function module.GetAction(player, updateTable)
	local key = updateTable[1]
	
	if environmentVariables.debugMode then
		print(string.format("GET %s - %s", player.Name, module.GetKeyFromEnum(key)))		
	end
	
	local data = module.GetPlayer(player)
	
	if data ~= nil then
		if key == eventManager.keys.getPlayerData then
			return data:GetPlayerData()
		elseif key == eventManager.keys.getBindings then
			return data:GetPlayerBindings()
		elseif key == eventManager.keys.getVisualLatency then
			return data:GetLatency()
		elseif key == eventManager.keys.getAudioLatency then
			return data:GetAudioLatency()
		elseif key == eventManager.keys.getTrackScore then
			return data:GetTrackScore(updateTable[2])
		elseif key == eventManager.keys.getInputManager then
			return data:GetInputManager()
		elseif key == eventManager.keys.getPlayerManager then
			return data
		else
			local errorMessage = errorHandler.GetErrorMessage("playerdatamanager", errorHandler.errors.incorrect_key)
			return warn(errorMessage)
		end		
	end 
end

function module.SetAction(player, updateTable)
	local key = updateTable[1]	
	print(string.format("SET %s - %s", player.Name, module.GetKeyFromEnum(key)))
	
	local data = module.GetPlayer(player)
	
	if data ~= nil then
		-- TODO: data validation
		if key == eventManager.keys.setVisualLatency then
			data:SetLatency(player, updateTable[2])
		elseif key == eventManager.keys.setAudioLatency then
			data:SetAudioLatency(player, updateTable[2])
		elseif key == eventManager.keys.setPlayerData then
			data:SetPlayerData(updateTable[2])
		elseif key == eventManager.keys.firstTimeFlag then
			data:SetFirstTimeFlag(player, updateTable[2])
		elseif key == eventManager.keys.setTotalPlaytime then
			data:SetTotalPlaytime(player, updateTable[2])
		elseif key == eventManager.keys.updateTrackScore then
			data:UpdateTrackScore(updateTable[2], updateTable[3], updateTable[4], updateTable[5])
		elseif key == eventManager.keys.setTrackScore then
			data:SetTrackScore(updateTable[2], updateTable[3], updateTable[4], updateTable[5])
		elseif key == eventManager.keys.setBindings then
			data:SetPlayerBindings(updateTable[2], updateTable[3], updateTable[4], updateTable[5])
		elseif key == eventManager.keys.updateBindings then
			data:UpdatePlayerBindings(updateTable[2], updateTable[3])
		elseif key == eventManager.keys.setConductor then
			data:SetConductor(updateTable[2])
		elseif key == eventManager.keys.setLatencyController then
			data:SetLatencyController(updateTable[2])
		elseif key == eventManager.keys.setInputManager then
			data:SetInputManager(updateTable[2])
		else
			local errorMessage = errorHandler.GetErrorMessage("playerdatamanager", errorHandler.errors.incorrect_key)
			return warn(errorMessage)
		end			
	end
end

return module