uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)

local LevelPanel = {}

LevelPanel.UpdateGameUI = function(updateType, update, tween)
	local ui = uiController.GetUIFromTable("main")
	
	if updateType == "score" then
		uiController.AnimateIncrease(ui.Frame.score_frame.scoreLabel.value, ui.Frame.score_frame.scoreLabel.value.Text, update)								
	end
	
	if updateType == "combo" then
		--uiController.AnimateIncrease(ui.Frame.score_frame.comboLabel.value, update)		
		--[[if tween then
			uiController.Tween(false, false, ui.Frame.score_frame.comboLabel.value, 1.2, 1, 1)
		end	]]		
	end
	
	if updateType == "accuracy" then
		if update ~= nil then
			ui.Frame.score_frame.gradeLabel.Text = update			
		end		
	end
end

LevelPanel.SetHitVisual = function(target, score, textColour)
	target.HITME.HitVisual.Frame.TextLabel.Text = score	
	target.HITME.HitVisual.Frame.TextLabel.TextColor3 = textColour
	uiController.Tween(true, false, target.HITME.HitVisual.Frame.TextLabel, 1.1, 0.5, 1)		
end

return LevelPanel