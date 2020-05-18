editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function onPlayButtonPressed()
	editor.Play()
end

script.Parent.MouseButton1Click:Connect(onPlayButtonPressed)