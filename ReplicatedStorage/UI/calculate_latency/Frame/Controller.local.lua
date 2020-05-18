local latencyPanel = require(game.ReplicatedStorage.Scripts.Menus.LatencyPanel)
local uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)
local currentLatencyText = script.Parent.test_frame.current
local cameraManager = require(game.ReplicatedStorage.Scripts.Game.CameraManager)
local eventManager = require(game.ReplicatedStorage.Events.EventManager)
local environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local offset = eventManager.Trigger("DataGetEvent", {eventManager.keys.getVisualLatency})

if offset ~= nil then
	latencyPanel.currentLatency = offset
end


function Increase()
	latencyPanel.IncreaseLatency(currentLatencyText)	
end

function Decrease()
	latencyPanel.DecreaseLatency(currentLatencyText)
end

function Test()
	latencyPanel.SetLatency()
end

function Back()
	uiController.EnableUI("loading")

	environmentVariables.calculatingLatency = false
	environmentVariables.disableLighting = false

	-- save the latency
	latencyPanel.Save()
	
	uiController.DisableUI("latency")
	
	local target = cameraManager.GetCameraWithName("HomeCam")	
	local cameraTween = cameraManager.TweenCamera(target, Enum.CameraType.Scriptable, 70, {CoordinateFrame = CFrame.new(target.Position) * CFrame.Angles(100, 0, 0) * CFrame.new(0, 0, 0)})	

	local menuUI = uiController.GetUIFromTable("menu")
	uiController.SetPosition(menuUI.Main.beatmaps.leaderboard, UDim2.new(-1, 0, 0.25, 0))
	uiController.SetPosition(menuUI.Main.beatmaps.songs, UDim2.new(2, 0, 0.25, 0))
	
	wait(1)	
	uiController.DisableUI("loading")
	uiController.EnableUI("menu")
	--uiController.BlurTransition(24, "menu")
	uiController.TweenIn(menuUI.Main.beatmaps.songs, 1, menuUI.Main.beatmaps.songs.Position.Y.Scale, 0.5)		
end

function Reset()
	latencyPanel.adjustedLatency = 0.000
	currentLatencyText.Text = "+0.000 SEC"
end

script.Parent.button_frame.back.MouseButton1Click:Connect(Back)
script.Parent.button_frame.save.MouseButton1Click:Connect(Test)
script.Parent.reset.MouseButton1Click:Connect(Reset)

script.Parent.test_frame.increase.MouseButton1Click:Connect(Increase)
script.Parent.test_frame.decrease.MouseButton1Click:Connect(Decrease)