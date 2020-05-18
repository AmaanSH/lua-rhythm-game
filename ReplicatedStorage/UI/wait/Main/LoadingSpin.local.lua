loadingImage = script.Parent.ImageLabel
uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)

function rotateLoadingIcon(icon)	
	local loadingRoutine = coroutine.wrap(function()
		while true do
			icon.Rotation = icon.Rotation + 5
			wait()
		end			
	end)
	
	loadingRoutine()
end

rotateLoadingIcon(loadingImage)