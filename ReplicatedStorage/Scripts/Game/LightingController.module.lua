local LightingController = {}
local lightingParts = {
	Main = {},
	Secondary = {},
	Connectors = {},
	Colours = { Main = 0, Secondary = 0 }
}

local originalBrightness = 5

LightingController.Init = function()
	local lighting = game.Workspace.lighting.Lights:GetDescendants()	
	
	for i,v in pairs(lighting) do
		if v.Name == "main" then
			table.insert(lightingParts.Main, v)
		elseif v.Name == "secondary" then
			table.insert(lightingParts.Secondary, v)
		elseif v.Name == "connector" then
			table.insert(lightingParts.Connectors, v)		
		end
	end
end

LightingController.SetColours = function(main, secondary)
	lightingParts.Colours.Main = main
	lightingParts.Colours.Secondary = secondary
	
	for i,v in pairs(lightingParts.Main) do
		v.Color = main
		v.lights.Color = main
	end
	
	for j,s in pairs(lightingParts.Secondary) do
		s.Color = secondary
		s.lights.Color = secondary		
	end
end

LightingController.Flash = function(lightingType)	
	local flashThread = coroutine.wrap(function()
		if lightingType == "main" then			
			for i = 0.1, 0.9, 0.1 do			
				for j,v in pairs(lightingParts.Main) do
					v.Transparency = i
					v.lights.Brightness = 5 + i					
					for c,connector in pairs(lightingParts.Connectors) do
						--connector.lights.Brightness = i							
						connector.Color = lightingParts.Colours.Main							
					end				 						
				end
				wait(0.01)			
			end							
		else
			for i = 0.1, 0.9, 0.1 do			
				for h,s in pairs(lightingParts.Secondary) do
					s.Transparency = i
					s.lights.Brightness = 5 + i
					for c,connector in pairs(lightingParts.Connectors) do
						--connector.lights.Brightness = i
						connector.Color = lightingParts.Colours.Secondary						
					end																
				end	
				wait(0.01)			
			end													
		end									
	end)
		
	flashThread()	
end

return LightingController