latencyPanel = require(game.ReplicatedStorage.Scripts.Menus.LatencyPanel)
uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)
soundManager = require(game.ReplicatedStorage.Scripts.Game.SoundManager)
cameraManager = require(game.ReplicatedStorage.Scripts.Game.CameraManager)
eventManager = require(game.ReplicatedStorage.Events.EventManager)

function startCalibration()
	-- stop all audio
	soundManager.stopAllAudio()
	
	-- tell the game we're calculating latency
	environmentVariables.calculatingLatency = true
	environmentVariables.disableLighting = true
	
	-- show loading screen
	uiController.EnableUI("loading")
	uiController.DisableUI("menu")
	uiController.DisableBlur()
		
	-- setup the latency test
	latencyPanel.Init()
	
	local target = cameraManager.GetCameraWithName("LevelCam")	
	local cameraTween = cameraManager.TweenCamera(target, Enum.CameraType.Scriptable, 90, {CoordinateFrame = CFrame.new(target.Position) * CFrame.Angles(100, 0, 0) * CFrame.new(0, 0, 0)})			
	
	cameraTween.Completed:Connect(function(playbackState)
		if playbackState == Enum.PlaybackState.Completed then
			uiController.DisableUI("loading")
			
			-- tween in the latency ui
			local latencyUI = uiController.GetUIFromTable("latency")	
			local offset = eventManager.Trigger("DataGetEvent", {eventManager.keys.getVisualLatency})
			
			if offset ~= nil then
				local operator = "+"
				if offset < 0 then
					operator = ""
				end				
				latencyUI.Frame.test_frame.current.Text = operator..offset.." SEC"
			end
			
			uiController.SetPosition(latencyUI.Frame, UDim2.new(-2, 0, 0.5, 0))
			uiController.EnableUI("latency")	
			uiController.TweenIn(latencyUI.Frame, 0, 0.5, 0.8)
			
			latencyPanel.StartConductor(true)						
		end
	end)
end

script.Parent.MouseButton1Click:Connect(startCalibration)