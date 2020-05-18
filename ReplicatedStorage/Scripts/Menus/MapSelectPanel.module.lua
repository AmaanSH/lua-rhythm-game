uiController = require(game.ReplicatedStorage.Scripts.UI.UIController)
eventManager = require(game.ReplicatedStorage.Events.EventManager)

ContentProvider = game:GetService("ContentProvider")

local MapSelectPanel = {}

MapSelectPanel.SetupBeatmapMenu = function(player, mapTable)	
	local ui = uiController.GetUIFromTable("menu")
	local songFrame = game.ReplicatedStorage.Components:FindFirstChild("song_frame")
	local currentPosition = 0.05
		
	for i,v in pairs(mapTable) do
		local location = ui.Main.beatmaps.songs
		local songF = songFrame:Clone()
		local playedTrack = eventManager.Trigger("DataGetEvent", {eventManager.keys.getTrackScore, v.Title})	
				
		songF.Position = UDim2.new(songF.Position.X.Scale, songF.Position.X.Offset, currentPosition, songF.Position.Y.Offset)
		songF.Parent = location
		songF.Title.Text = v.Title
		songF.Artist.Text = v.Artist
		songF.BPM.Text = "BPM: "..v.BPM
		
		if playedTrack ~= nil then
			songF.Score.Text = "SCORE: "..playedTrack.Score.."("..playedTrack.Grade..")"
		else
			songF.Score.Visible = false
		end
		
		if v.Cover ~= nil then
			local coverArt = "rbxassetid://"..v.Cover
			local assets = {coverArt}		
			songF.CoverArt.Image = coverArt
			
			local success, assets = pcall(function()
				ContentProvider:PreloadAsync(assets)
			end)			
		end	
					
		songF.select.SelectMap.Disabled = false			
		currentPosition = currentPosition + 0.12
	end	
end

return MapSelectPanel