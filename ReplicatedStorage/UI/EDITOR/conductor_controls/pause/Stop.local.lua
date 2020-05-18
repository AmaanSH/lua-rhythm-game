editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function onStopButtonPressed()
	editor.Stop()
end

script.Parent.MouseButton1Click:Connect(onStopButtonPressed)