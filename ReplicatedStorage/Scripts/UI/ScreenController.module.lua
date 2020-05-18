local ScreenController = { screenParts = {}, states = { Waiting = 0, Setting = 1, Done = 2 } }

local states = { Waiting = 0, Setting = 1, Done = 2 }

ScreenController.screenParts = {
	Main = {},
	Secondary = {},
	State = states.Waiting
}

ScreenController.Init = function()
	for i,v in pairs(game.Workspace.Screens:GetDescendants()) do
		if v.Name == "main" then
			table.insert(ScreenController.screenParts.Main, v.SurfaceGui)
		elseif v.Name == "secondary" then
			table.insert(ScreenController.screenParts.Secondary, v.SurfaceGui)
		end		
	end
end

ScreenController.SetBackgroundImage = function(imageID)
	local keyArt = ScreenController.screenParts.Main[1].Frame.KeyArt 
	keyArt.Image = "rbxassetid://"..imageID
	keyArt.ImageTransparency = 1
	keyArt.Visible = true
	ScreenController.screenParts.State = states.Setting
	ScreenController.FadeIn()	
end

ScreenController.HideBackgroundImage = function()
	local keyArt = ScreenController.screenParts.Main[1].Frame.KeyArt 
	keyArt.ImageTransparency = 1
	keyArt.Visible = false	
end

ScreenController.FadeIn = function()
	local fadeRoutine = coroutine.wrap(function()
		for i = 1, 0, -0.1 do			
			ScreenController.screenParts.Main[1].Frame.KeyArt.ImageTransparency = i
			wait(0.01)			
		end	
		ScreenController.screenParts.State = states.Done										
	end)		
	fadeRoutine()	
end


return ScreenController