local beatmapFrame = script.Parent.Parent.Parent.beatmaps

function backToMainmenu()
	beatmapFrame.Visible = false
	beatmapFrame.leaderboard.Position = UDim2.new(-1, 0, 0.25, 0)
	beatmapFrame.songs.Position = UDim2.new(2, 0, 0.25, 0)
	script.Parent.Parent.Parent.main_menu.Visible = true
	
	if script.Parent.Parent.Editor.Value == true then
		script.Parent.Parent.Editor.Value = false
	end
end

script.Parent.MouseButton1Click:Connect(backToMainmenu)