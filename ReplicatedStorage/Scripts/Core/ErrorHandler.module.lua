local ErrorHandler = {}

ErrorHandler.errors = {
	incorrect_key = 0,
	data_not_found = 1,
	player_not_found = 2,
	not_enough_params = 3,
	cant_find_diff = 4,
	event_not_found = 5,
	params_not_table = 6
}

ErrorHandler.GetErrorMessage = function(module, errorKey, invalidInputTable)
	local errors = ErrorHandler.errors
	
	if errorKey == errors.incorrect_key then
		return error(string.format("%s : Incorrect key provided", string.upper(module)))
	elseif errorKey == errors.data_not_found then
		return error(string.format("%s : data with %s key not found!", string.upper(module), invalidInputTable[1]))
	elseif errorKey == errors.player_not_found then
		return error(string.format("%s : Player not found!", string.upper(module)))
	elseif errorKey == errors.not_enough_params then
		return error(string.format("%s : please provide the correct parameters", string.upper(module)))
	elseif errorKey == errors.cant_find_diff then
		return error(string.format("%s : cannot find difficulty specified!", string.upper(module)))
	elseif errorKey == errors.event_not_found then
		return error(string.format("%s : Event %s not found!", string.upper(module), invalidInputTable[1]))
	elseif errorKey == errors.params_not_table then
		return error(string.format("%s : Params are not in a table", string.upper(module)))
	end	
end

return ErrorHandler
