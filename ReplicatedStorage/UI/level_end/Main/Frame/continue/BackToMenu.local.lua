local cameraManager = require(game.ReplicatedStorage.Scripts.Game.CameraManager)
local uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)
local eventManager = require(game.ReplicatedStorage.Events.EventManager)

function returnToMenu()
	uiController.DisableUI("levelend")
	print(script.Parent.Parent.MapTitle.Text)
	local playedTrack = eventManager.Trigger("DataGetEvent", {eventManager.keys.getTrackScore, script.Parent.Parent.MapTitle.Text})
	local ui = uiController.GetUIFromTable("menu")	
	local target = cameraManager.GetCameraWithName("HomeCam")	
	local cameraTween = cameraManager.TweenCamera(target, Enum.CameraType.Scriptable, 70, {CoordinateFrame = CFrame.new(target.Position) * CFrame.Angles(100, 0, 0) * CFrame.new(0, 0, 0)})
	
	uiController.SetPosition(ui.Main.beatmaps.leaderboard, UDim2.new(-1, 0, 0.25, 0))
	uiController.SetPosition(ui.Main.beatmaps.songs, UDim2.new(2, 0, 0.25, 0))
	
	if playedTrack ~= nil then		
		for i,v in pairs(ui.Main.beatmaps.songs:GetChildren()) do
			if v.Title.Text == script.Parent.Parent.MapTitle.Text then
				v.Score.Text = "SCORE: "..playedTrack.Score.."("..playedTrack.Grade..")"
				v.Score.Visible = true
			end
		end
	end	
	
	uiController.EnableUI("menu")
	--uiController.BlurTransition(24, "menu")
	uiController.TweenIn(ui.Main.beatmaps.songs, 1, ui.Main.beatmaps.songs.Position.Y.Scale, 0.5)
end

script.Parent.MouseButton1Click:Connect(returnToMenu)