local UIController = {}

local UITable = {}
local TweenService = game:GetService("TweenService")

function UIController.Init(player)	
	local UIFolder = game.ReplicatedStorage.UI:GetChildren()
		
	for i,v in pairs(UIFolder) do
		local clone = v:Clone()
					
		clone.Parent = player.PlayerGui						
		local ui = {
			Type = clone.Type.Value,
			UI = clone,
			isSetup = false
		}
		
		table.insert(UITable, ui)			
	end			
end

UIController.GetUITable = function()
	return UITable
end

UIController.GetUIFromTable = function(ui)
	local player = game.Players.LocalPlayer.Name
	
	for i,v in pairs(UITable) do
		if v.Type == ui then
			return v.UI
		end
	end
	
	return warn("No UI found with name "..ui)
end

UIController.EnableUI = function(id)
	for i,v in pairs(UITable) do
		if v.Type == id then
			if id == "loading" then
				v.UI.Main.LoadingSpin.Disabled = false
			end
			v.UI.Enabled = true
		end
	end
end

UIController.DisableUI = function(id)
	for i,v in pairs(UITable) do
		if v.Type == id then
			if id == "loading" then
				v.UI.Main.LoadingSpin.Disabled = true
			end			
			v.UI.Enabled = false
		end
	end	
end

UIController.Visible = function(ui)	
	ui.Visible = true
end

UIController.Hide = function(ui)
	ui.Visible = false
end

UIController.getTweenInfo = function(easing, direction, duration)
	local tweenInfo = TweenInfo.new(
		duration, -- time
		easing, -- easing style
		direction, -- Easing direction
		0, -- repeat count (< 0 means loop)
		false, -- tween reverse once reach goal
		0 -- delay time
	)
	
	return tweenInfo	
end

UIController.ScaleTween = function(element, scaler, fadeOut, orgX, orgY)
	local tweenInfo = UIController.getTweenInfo(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2)
	local tween = TweenService:Create(element, tweenInfo, {TextTransparency = 0, Size = UDim2.new(element.Size.X.Scale * scaler, element.Size.X.Offset, element.Size.Y.Scale * scaler, element.Size.Y.Offset)})
	
	tween:Play()
	
	tween.Completed:Connect(function(playbackState)
		if not fadeOut then
			local tween = TweenService:Create(element, tweenInfo, {TextTransparency = 0, Size = UDim2.new(orgX, element.Size.X.Offset, orgY, element.Size.Y.Offset)})			
			tween:Play()	
		else
			local tween = TweenService:Create(element, tweenInfo, {TextTransparency = 1, Size = UDim2.new(orgX, element.Size.X.Offset, orgY, element.Size.Y.Offset)})			
			tween:Play()							
		end	
	end)
end

UIController.TweenIn = function(frame, orgX, orgY, duration)			
	local tweenInfo = UIController.getTweenInfo(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration)
	local tween = TweenService:Create(frame, tweenInfo, {Position = UDim2.new(orgX, frame.Position.X.Scale, orgY, frame.Position.Y.Scale)})
	
	tween:Play()
end

UIController.Tween = function(fadeOut, fade, element, scaler, orgX, orgY)
	-- scaling effect on tween
	if element:IsA("TextLabel") then
		local tweenInfo = UIController.getTweenInfo(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2)
		local tween = TweenService:Create(element, tweenInfo, {TextTransparency = 0, Size = UDim2.new(element.Size.X.Scale * scaler, element.Size.X.Offset, element.Size.Y.Scale * scaler, element.Size.Y.Offset)})
		
		tween:Play()
		
		tween.Completed:Connect(function(playbackState)
			if not fadeOut then
				local tween = TweenService:Create(element, tweenInfo, {TextTransparency = 0, Size = UDim2.new(orgX, element.Size.X.Offset, orgY, element.Size.Y.Offset)})			
				tween:Play()	
			else
				local tween = TweenService:Create(element, tweenInfo, {TextTransparency = 1, Size = UDim2.new(orgX, element.Size.X.Offset, orgY, element.Size.Y.Offset)})			
				tween:Play()							
			end					
		end)
	end
	
	if element:IsA("Frame") then
		local tweenInfo = UIController.getTweenInfo(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0.2)
		
		if fade then
			local tween = TweenService:Create(element, tweenInfo, {BackgroundColor3 = Color3.fromRGB(65,65,65), Size = UDim2.new(orgX * scaler, element.Size.X.Offset, orgY * scaler, element.Size.Y.Offset)})			
			tween:Play()
		else
			local tween = TweenService:Create(element, tweenInfo, {Size = UDim2.new(orgX * scaler, element.Size.X.Offset, orgY * scaler, element.Size.Y.Offset)})				
			tween:Play()			
		end	
	end					
end

UIController.GetTween = function(ui, orgX, orgY, duration)
	local tweenInfo = UIController.getTweenInfo(Enum.EasingStyle.Quad, Enum.EasingDirection.Out, duration)
	local tween = TweenService:Create(ui, tweenInfo, {Position = UDim2.new(orgX, ui.Position.X.Scale, orgY, ui.Position.Y.Scale)})
	
	return tween		
end

UIController.BlurTransition = function(max, ui)
	local blur = game.Lighting:WaitForChild("Blur")
	blur.Enabled = true
	
	for i = 0, max, 2 do
		blur.Size = i		
		wait()	
	end	
	
	if ui then
		UIController.EnableUI(ui)
	end
end

UIController.DisableBlur = function()
	local blur = game.Lighting:WaitForChild("Blur")
	blur.Enabled = false
end

UIController.AnimateIncrease = function(score, existingScore, updatedScore)
	local last = tick()
	local padding = "%08i"
	
	local animateRoutine = coroutine.wrap(function()
		local i = 0		
		while (i <= 1) do
			local t = tick()
			local deltaTime = t - last
			
			i  = i + deltaTime / 2
			
			local newScore = UIController.Lerp(tonumber(existingScore), updatedScore, i)		
			score.Text = string.format(padding, newScore)
			game["Run Service"].RenderStepped:wait()					
		end
		
		-- make sure the final score is shown correctly
		score.Text = string.format(padding, updatedScore)		
	end)
	
	animateRoutine()
end

UIController.Lerp = function(a, b, t)
	return a + (b - a) * t
end

UIController.SetPosition = function(frame, position)
	frame.Position = position
end

UIController.UpdateText = function(uiType, update, value, tween) 	
	for i,v in pairs(UITable) do
		if v.Type == uiType then								
			update.Text = value
			
			if tween then
				UIController.Tween(false, false, v.UI, 1.2, 0.3, 1)
			end										
		end
	end	
end

return UIController