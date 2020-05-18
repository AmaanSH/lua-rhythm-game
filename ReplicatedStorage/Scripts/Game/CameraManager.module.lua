local CameraManager = {}

CameraManager.cameras = {}

local TweenService = game:GetService("TweenService")

CameraManager.Init = function()
	local cameraFolder = game.Workspace:WaitForChild("Cameras"):GetChildren()	
	for i,v in pairs(cameraFolder) do		
		local camTable = { Name = v.Name, Camera = v }
		table.insert(CameraManager.cameras, camTable)
	end	
end

CameraManager.GetCameras = function()
	return CameraManager.cameras
end

CameraManager.GetCameraWithName = function(name)
	local cameras = CameraManager.cameras
	
	for i,v in pairs(cameras) do
		if v.Name == name then
			return v.Camera
		end
	end
end

CameraManager.TweenCamera = function(target, cameraType, fov, movementTable)	
	local camera = workspace.CurrentCamera
	local tweenInfo = CameraManager.getTweenInfo()
	
	camera.CameraType = cameraType
	camera.CameraSubject = target
	camera.FieldOfView = fov

	local tween = TweenService:Create(camera, tweenInfo, movementTable)	
	tween:Play()
	
	return tween
end

CameraManager.getTweenInfo = function()
	local tweenInfo = TweenInfo.new(
		1, -- time
		Enum.EasingStyle.Quad, -- easing style
		Enum.EasingDirection.Out, -- Easing direction
		0, -- repeat count (< 0 means loop)
		false, -- tween reverse once reach goal
		0 -- delay time
	)
	
	return tweenInfo				
end

return CameraManager
