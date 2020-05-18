errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)
eventManager = require(game.ReplicatedStorage.Events.EventManager)

local DatastoreManager = {
	datastores = { 
		Player = "Player_Data_TEST8", 
		Beatmaps = "Beatmaps" 
	},
}

local DataStoreService = game:GetService("DataStoreService")

DatastoreManager.SetEvents = function()
	game.ReplicatedStorage.Events.Server.DatastoreManager.DatastoreSetEvent.OnServerEvent:Connect(DatastoreManager.SetAction)	
end

DatastoreManager.SetAction = function(player, updateTable)
	local key = updateTable[1]
	
	if key == eventManager.keys.Update then
		DatastoreManager.SetData(player, updateTable[2], updateTable[3], updateTable[4])
	else
		local errorMessage = errorHandler.GetErrorMessage("datastoremanager", errorHandler.errors.incorrect_key)
		return warn(errorMessage)
	end
end

DatastoreManager.GetData = function(datastore, key)
	local datastore = DataStoreService:GetDataStore(datastore)	
	
	local success, data = pcall(function()
		return datastore:GetAsync(key)				
	end)
	
	if success then
		return data
	else
		local errorMessage = errorHandler.GetErrorMessage("datastoremanager", errorHandler.errors.data_not_found, { key })
		return warn(errorMessage)
	end	
end

DatastoreManager.SetData = function(player, datastore, key, updateTable)
	if player == nil or datastore == nil or updateTable == nil or key == nil then
		errorHandler.GetErrorMessage("datastoremanager", errorHandler.errors.not_enough_params)
	end
	
	local datastore = DataStoreService:GetDataStore(datastore)
	
	local success, data = pcall(function()
		return datastore:GetAsync(key)				
	end)	
	
	if success then	
		local done, newData = pcall(function()
			return datastore:SetAsync(key, updateTable)
		end)
		
		if done then
			print(string.format("%s updated successfully!", key))
		else
			return warn(newData)
		end	
	else
		return warn(success)	
	end		
end

return DatastoreManager