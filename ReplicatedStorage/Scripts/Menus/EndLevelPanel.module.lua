uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)

local EndLevelPanel = {}

EndLevelPanel.SetupEndLevelScreen = function(artist, title, combo, good, okay, perfect, miss, score, grade)
	local ui = uiController.GetUIFromTable("levelend") 
	
	ui.Main.Frame.Artist.Text = artist
	ui.Main.Frame.MapTitle.Text = title
	ui.Main.Frame.scoreFrame.Score.Text = "SCORE: "..score.." ("..grade..")"
	ui.Main.Frame.comboFrame.comboScore.value.Text = combo
	ui.Main.Frame.comboFrame.goodScore.value.Text = good
	ui.Main.Frame.comboFrame.okayScore.value.Text = okay
	ui.Main.Frame.comboFrame.missScore.value.Text = miss
	ui.Main.Frame.comboFrame.perfectScore.value.Text = perfect
	
	uiController.BlurTransition(24, "levelend")
end

return EndLevelPanel