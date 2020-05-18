editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function createHeld()
	local stringTable = script.Parent.Parent.noteID.Text:split(":")
	local count = tonumber(stringTable[2])
	editor.createHeldNote(count)
end

script.Parent.MouseButton1Click:Connect(createHeld)