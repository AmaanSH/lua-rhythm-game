local editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function updateNoteType()
	local stringTable = script.Parent.Parent.noteID.Text:split(":")
	local count = tonumber(stringTable[2])	

	local new = script.Parent.Parent.typeValue.Text	
	local noteType = editor.GetEnumFromString(new)
	
	editor.updateNoteType(count, noteType)
end

script.Parent.MouseButton1Click:Connect(updateNoteType)