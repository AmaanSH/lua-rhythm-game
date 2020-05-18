local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Scripts.Core:WaitForChild("Core"))
local initEvent = ReplicatedStorage.Events:WaitForChild("Init")

function Init(player)	
 	Core.Init(player)	
end

initEvent.OnClientEvent:Connect(Init)