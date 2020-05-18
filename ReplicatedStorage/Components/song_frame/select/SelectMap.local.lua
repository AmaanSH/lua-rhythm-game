eventManager = require(game.ReplicatedStorage.Events.EventManager)

local uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)
local levelManager = require(game.ReplicatedStorage.Scripts.Game.LevelManager)
local cameraManager = require(game.ReplicatedStorage.Scripts.Game.CameraManager)
local inputManager = require(game.ReplicatedStorage.Scripts.Game.InputManager)
local soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)

local mapTitle = script.Parent.Parent.Title.Text
local mapArtist = script.Parent.Parent.Artist.Text
local leaderboardFrame = script.Parent.Parent.Parent.Parent.leaderboard
local showEditor = script.Parent.Parent.Parent.Parent.Editor
local isScaled = false

script.Parent.Parent.Parent.song_frame.Name = script.Parent.Parent.Parent.song_frame.Name.."_"..mapTitle

local originalSize = script.Parent.Parent.Parent:FindFirstChild("song_frame".."_"..mapTitle).Size
local frame = script.Parent.Parent.Parent:FindFirstChild("song_frame".."_"..mapTitle)
local clicked = 0

function showBeatmapInfo()
	if leaderboardFrame.Song.Value ~= mapTitle then
		clicked = 0
	end
		
	if clicked == 0 then
		-- TODO: Will show some leaderboard and all difficulties available for map
		leaderboardFrame.Position = UDim2.new(-1, 0, 0.25, 0)
		leaderboardFrame.Title.Text = "Leaderboard - "..mapTitle
		leaderboardFrame.Song.Value = mapTitle
		leaderboardFrame.Visible = true
		
		soundManager.PlayAudioPreview(mapTitle)
		
		uiController.TweenIn(leaderboardFrame, 0, leaderboardFrame.Position.Y.Scale, 0.5)
		clicked = 1	
		return	
	end
	
	if clicked == 1 then
		clicked = 0
		
		soundManager.stopAudio(mapTitle)
		
		if showEditor.Value == true then
			-- get the map bpm
			local stringTable = script.Parent.Parent.BPM.Text:split(":")
			showEditorMenu(mapTitle, tonumber(stringTable[2]))
		else
			local map = eventManager.Trigger("MapsGetEvent", {eventManager.keys.getMapWithTitle, mapTitle})
			
			if map ~= nil then
				uiController.DisableUI("menu")
				uiController.DisableBlur()
				
				local target = cameraManager.GetCameraWithName("LevelCam")	
				local cameraTween = cameraManager.TweenCamera(target, Enum.CameraType.Scriptable, 90, {CoordinateFrame = CFrame.new(target.Position) * CFrame.Angles(100, 0, 0) * CFrame.new(0, 0, 0)})		
								
				cameraTween.Completed:Connect(function(playbackState)
					if playbackState == Enum.PlaybackState.Completed then
						-- TODO split difficulties!	
						levelManager.StartLevel(map, "Easy")			
					end
				end)						
			end				
		end			
	end	
end

function showEditorMenu(title, bpm)
	local editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)
	local ui = uiController.GetUIFromTable("beatmapEditor")
	
	uiController.DisableBlur()
	
	uiController.EnableUI("loading")
	uiController.DisableUI("menu")	
	
	local target = cameraManager.GetCameraWithName("LevelCam")	
	local cameraTween = cameraManager.TweenCamera(target, Enum.CameraType.Scriptable, 90, {CoordinateFrame = CFrame.new(target.Position) * CFrame.Angles(100, 0, 0) * CFrame.new(0, 0, 0)})		
		
	cameraTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			editor.Init(title, bpm)
			uiController.EnableUI("beatmapEditor")
			uiController.DisableUI("loading")					
		end
	end)	
end

function onButtonHover()
	if isScaled == false then
		uiController.Tween(false, true, frame, 1.05, 0.9, 0.1)		
		isScaled = true		
	end
end

function onButtonLeave()
	if isScaled == true then
		frame.Size = originalSize
		frame.BackgroundColor3 = Color3.fromRGB(27,27,27)	
		isScaled = false	
	end
end

script.Parent.MouseButton1Click:Connect(showBeatmapInfo)
script.Parent.MouseEnter:Connect(onButtonHover)
script.Parent.MouseLeave:Connect(onButtonLeave)