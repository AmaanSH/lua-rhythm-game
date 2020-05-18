uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)

local MainMenuPanel = {}

MainMenuPanel.showBeatmapScreen = function(menuPanel)
	menuPanel.Visible = false
		
	local ui = uiController.GetUIFromTable("menu")
	ui.Main.beatmaps.Visible = true
	ui.Main.beatmaps.Back.Visible = true
	ui.Main.beatmaps.Latency.Visible = true
	ui.Main.beatmaps.CreateBeatmap.Visible = false
	
	if ui.Main.beatmaps.leaderboard.Song.Value ~= "" then
		print("LAST SELECTED: "..ui.Main.beatmaps.leaderboard.Song.Value)
	end
	
	uiController.TweenIn(ui.Main.beatmaps.songs, 1, ui.Main.beatmaps.songs.Position.Y.Scale, 0.5)	
end

MainMenuPanel.showSettings = function()
	-- WIP!
end

MainMenuPanel.showEditor = function(menuPanel)
	menuPanel.Visible = false
	
	local ui = uiController.GetUIFromTable("menu")
	ui.Main.beatmaps.Visible = true
	ui.Main.beatmaps.Back.Visible = true	
	ui.Main.beatmaps.Editor.Value = true
	ui.Main.beatmaps.Latency.Visible = false
	ui.Main.beatmaps.CreateBeatmap.Visible = true
	
	if ui.Main.beatmaps.leaderboard.Song.Value ~= "" then
		print("LAST SELECTED: "..ui.Main.beatmaps.leaderboard.Song.Value)
	end
	
	uiController.TweenIn(ui.Main.beatmaps.songs, 1, ui.Main.beatmaps.songs.Position.Y.Scale, 0.5)
end


return MainMenuPanel