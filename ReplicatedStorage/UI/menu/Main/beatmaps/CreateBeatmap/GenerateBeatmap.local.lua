local beatmapManager = require(game.ReplicatedStorage.Scripts.Editor.BeatmapManager)

local beatmapFrame = script.Parent.Parent.Parent.beatmaps

-- WIP!! --
function setup()
	beatmapManager.SetupMap()
end

script.Parent.MouseButton1Click:Connect(setup)