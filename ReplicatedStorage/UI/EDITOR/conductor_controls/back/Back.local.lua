local editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function Back()
	editor.Back()
end

script.Parent.MouseButton1Click:Connect(Back)