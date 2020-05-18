local SoundManager = {}

local ContentProvider = game:GetService("ContentProvider")
local num = 1

SoundManager.Init = function(FX, mapTable)
	if #mapTable > 0 then
		for i = 1, #mapTable do	
			SoundManager.preloadAudio({[mapTable[i].Title] = mapTable[i].SongID}, mapTable[i].Volume)	
		end		
	else
		return error("Maps have not been initialised correctly")	
	end		
		
	for i = 1, #FX do	
		SoundManager.preloadAudio({[FX[i].Title] = FX[i].SongID}, FX[i].Volume)	
	end			
end

SoundManager.preloadAudio = function(assetArray, volume)
	local audioAssets = {}
	
	for name, audioID in pairs(assetArray) do
		local audioInstance = Instance.new("Sound")
		audioInstance.SoundId = "rbxassetid://" .. audioID
		audioInstance.Name = name
		audioInstance.Parent = game.Workspace
		
		audioInstance.Volume = 2
		
		if volume ~= false then
			audioInstance.Volume = volume
		end
		
		table.insert(audioAssets, audioInstance)
	end
	
	local success, assets = pcall(function()
		ContentProvider:PreloadAsync(audioAssets)
	end)
end

SoundManager.playAudio = function(assetName, volume)	
	local audio = game.Workspace:FindFirstChild(assetName)
	if not audio then
		warn("Could not find audio asset: " .. assetName)
		return
	end
	
	if not audio.IsLoaded then
		audio.Loaded:wait()
	end
	
	if volume ~= nil then
		audio.Volume = volume
	else
		audio.Volume = 2		
	end
	audio:Play()
end

SoundManager.stopAllAudio = function()
	for i,v in pairs(game.Workspace:GetChildren()) do
		if v:IsA("Sound") then
			v:Stop()
		end
	end	
end

SoundManager.PlayAudioPreview = function(assetName)
	for i,v in pairs(game.Workspace:GetChildren()) do
		if v:IsA("Sound") then
			v:Stop()
		end
	end
	
	local audio = game.Workspace:FindFirstChild(assetName)
	if not audio then
		warn("Could not find audio asset: " .. assetName)
		return
	end
	
	if not audio.IsLoaded then
		audio.Loaded:wait()
	end
	
	local volume = 1
	audio.Volume = 0
	audio.TimePosition = 30
	
	audio:Play()
	
	local fadeInRoutine = coroutine.wrap(function()
		for i = 1, 50 do
			audio.Volume = audio.Volume + 0.05
			wait(0.1)
		end		
		coroutine.yield()					
	end)
	
	local monitorAudio = coroutine.wrap(function()
		while audio.IsPlaying do
			if audio.TimePosition >= 40 then
				for i = 1, 50 do
					audio.Volume = audio.Volume - 0.05
					wait(0.1)
				end
				
				audio:Stop()
				coroutine.yield()
			end
			
			wait()
		end		
	end)
	
	fadeInRoutine()
	monitorAudio()	
end

SoundManager.stopAudio = function(assetName)
	local audio = game.Workspace:FindFirstChild(assetName)
	
	if not audio then
		return warn("Could not find audio asset: " .. assetName)
	end
	
	audio:Stop()	
end

SoundManager.retrieveAudio = function(assetName)
	local audio = game.Workspace:FindFirstChild(assetName)
	if not audio then
		warn("Could not find audio asset: " .. assetName)
		return false
	end
	return audio
end

SoundManager.HitSound = function(drum)
	if not drum then
		SoundManager.playAudio("normal-hit", 2)
		return	
	else
		local hitSoundArray = {"hitclap", "soft-hitclap"}
		if num == 1 then
			SoundManager.playAudio(hitSoundArray[num])
			num = num + 1
		elseif num == 2 then
			SoundManager.playAudio(hitSoundArray[num])
			num = num - 1				
		end		
	end
end

return SoundManager