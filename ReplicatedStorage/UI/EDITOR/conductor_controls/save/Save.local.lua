local editor = require(game.ReplicatedStorage.Scripts.Menus.EditorPanel)
local status = script.Parent.Parent.updatedText

function Back()
	editor.Save()
	local currentTime = os.time()
	local dateTable = os.date("!*t", currentTime)
	
	status.Text = "Updated "..dateTable["hour"]..":"..dateTable["min"]..":"..dateTable["sec"]
	status.Visible = true
	
	for i = 0, 1, 0.2 do
		status.TextTransparency = i
		wait(0.2)
	end
	
	status.Visible = false
end

script.Parent.MouseButton1Click:Connect(Back)