local module = {
	debugMode = false,
	calculatingLatency = false,
	disableLighting = false,
	
	datastores = {
		Player = "Player_Data_TEST8", 
		Beatmaps = "Beatmaps" 
	},
	
	states = { 
		Countdown = 1, 
		Monitoring = 2, 
		Paused = 3, 
		Finished = 4 
	},
}

return module
