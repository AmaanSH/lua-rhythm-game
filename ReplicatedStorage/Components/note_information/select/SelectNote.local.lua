editorPanel = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)

function selectNote()
	local count = script.Parent.Parent.count.Text
	local countTable = count:split(":")
	
	editorPanel.ShowNoteInformation(tonumber(countTable[2]))	
end

script.Parent.MouseButton1Click:Connect(selectNote)