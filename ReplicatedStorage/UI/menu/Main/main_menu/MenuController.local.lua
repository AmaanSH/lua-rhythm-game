local mainMenuPanel = require(game.ReplicatedStorage.Scripts.Menus.MainMenuPanel)

function showBeatmapScreen()
	mainMenuPanel.showBeatmapScreen(script.Parent)
end

function showEditor()
	if game.Players.LocalPlayer.Name == "broken_html" then
		mainMenuPanel.showEditor(script.Parent)	
	else
		return warn("This feature is currently locked")	
	end
end

script.Parent.Editor.MouseButton1Click:Connect(showEditor)
script.Parent.Maps.MouseButton1Click:Connect(showBeatmapScreen)
script.Parent.Settings.MouseButton1Click:Connect(mainMenuPanel.showSettings)