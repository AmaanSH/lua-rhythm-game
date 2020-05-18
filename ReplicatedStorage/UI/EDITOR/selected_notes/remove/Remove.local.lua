local editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function removeNote()
	local stringTable = script.Parent.Parent.noteID.Text:split(":")
	local count = tonumber(stringTable[2])
	editor.removeNote(count)
end

script.Parent.MouseButton1Click:Connect(removeNote)