eventManager = require(game.ReplicatedStorage.Events.EventManager)
environmentVariables = require(game.ReplicatedStorage.Scripts.Core.EnvironmentVariables)

local InputManager = {}
local keyBidnings = {}

local blockInput = false

local levelManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("LevelManager"))
local soundManager = require(game.ReplicatedStorage.Scripts.Game:WaitForChild("SoundManager"))
local uiController = require(game.ReplicatedStorage.Scripts.UI:WaitForChild("UIController"))

local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

local heldNoteInfo = {}

InputManager.Init = function(keyTable)	
	keyBidnings = {
		[1] = {
			Key = Enum.KeyCode.A,
			Target = keyTable[1].Target.Value,
			Action = "Note_1"
		},
		
		[2] = {
			Key = Enum.KeyCode.S,
			Target = keyTable[2].Target.Value,
			Action = "Note_2"
		},
		
		[3] = {
			Key = Enum.KeyCode.D,
			Target = keyTable[3].Target.Value,
			Action = "Note_3"
		},	
		
		[4] = {
			Key = Enum.KeyCode.F,
			Target = keyTable[4].Target.Value,
			Action = "Note_4"
		},						
	}
end

InputManager.StartMonitoring = function()
	blockInput = false	
	InputManager.beginMonitoringInput()		
	UserInputService.InputEnded:Connect(InputManager.keyUp)	
end

InputManager.animateKeyPrompts = function()
	for i,v in pairs(keyBidnings) do
		if keyBidnings[i].Target.HITME.HitVisual.Frame.button_prompt.Visible == true then
			uiController.Tween(true, true,keyBidnings[i].Target.HITME.HitVisual.Frame.button_prompt, 0, 0, 0)
			keyBidnings[i].Target.HITME.HitVisual.Frame.button_prompt.Visible = false			
		end
	end
end

InputManager.UpdateBindings = function(position, newKey)
	for i,v in pairs(keyBidnings) do
		if i == position then
			keyBidnings[i] = newKey
		end
	end
	
	return keyBidnings
end

InputManager.GetBindings = function()	
	return keyBidnings
end

InputManager.unbindActions = function()
	ContextActionService:UnbindAllActions()
	blockInput = true
end

InputManager.bindAction = function(key, action)	
	ContextActionService:BindActionAtPriority(action, InputManager.monitorInput, false, Enum.ContextActionPriority.High.Value, key)
end

InputManager.beginMonitoringInput = function()
	local firstKey = keyBidnings[1].Key
	local secondKey = keyBidnings[2].Key
	local thirdKey = keyBidnings[3].Key
	local fourthKey = keyBidnings[4].Key
	
	-- subscribe to key events	
	InputManager.bindAction(firstKey, "Note_1")	
	InputManager.bindAction(secondKey, "Note_2")	
	InputManager.bindAction(thirdKey, "Note_3")	
	InputManager.bindAction(fourthKey, "Note_4")
	
	blockInput = false	
end

InputManager.keyUp = function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.Keyboard and blockInput ~= true then
		for i,v in pairs(keyBidnings) do		
			if keyBidnings[i].Key == input.KeyCode then	
				-- the held key was let go
				if input.KeyCode == heldNoteInfo[1] then			
					heldNoteInfo[2].monitorHold = false					
					--calculate score
					levelManager.hitTarget(keyBidnings[i].Target, {Note = heldNoteInfo[2]}, levelManager.Conductor.songPosition)	
					heldNoteInfo = {}
				end 					
				levelManager.HighlightLane(keyBidnings[i].Target, true)		
			end
		end
	end
end

InputManager.monitorInput = function(actionName, inputState, inputObj)
	if inputState == Enum.UserInputState.Begin then
		for i,v in pairs(keyBidnings) do
			if keyBidnings[i].Action == actionName then				
				local position = levelManager.Conductor.songPosition				
			
				if levelManager.Conductor ~= nil then
					local note = levelManager.Conductor:GetNoteFromTable(keyBidnings[i].Target, position)					
					-- if the note is held keep note of the key it is on
					if note ~= nil and note.Note.held == true then
						table.insert(heldNoteInfo, keyBidnings[i].Key)
						table.insert(heldNoteInfo, note.Note)
						table.insert(heldNoteInfo, note.Note.endTimestamp)
						note.Note:Start()
					end
					levelManager.HighlightLane(keyBidnings[i].Target, false)															
					levelManager.hitTarget(keyBidnings[i].Target, note, position)						
				end				
				soundManager.HitSound(false)	
				InputManager.animateKeyPrompts()												
			end
		end					
	end
end

return InputManager