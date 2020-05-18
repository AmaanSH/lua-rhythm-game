errorHandler = require(game.ReplicatedStorage.Scripts.Core.ErrorHandler)
eventManager = require(game.ReplicatedStorage.Events.EventManager)
playerDataManager = require(game.ServerScriptService.Scripts.Data.PlayerDataManager)

local ScoreManager = {}
ScoreManager.__index = ScoreManager

local scoreText = { Perfect="Perfect", Good="Good", Okay="Okay", Miss="Miss" }

function ScoreManager.new(player)
	local scores = {}
	setmetatable(scores, ScoreManager)
	
	scores.Combo = { Total = 0, maxCombo = 0 }
	scores.Perfect = { Total = 0 }
	scores.Good = { Total = 0 }
	scores.Okay = { Total = 0 }
	scores.Miss = { Total = 0 }
    scores.Score = { Total = 0 }
	scores.Mods = {
		[1] = 80,		
		[2] = 40,
		[3] = 20,
	}
	
	scores.Weighting = {
		Perfect = 300,
		Good = 100,
		Okay = 50
	}
	
	scores.Player = player	
	return scores 		
end

function ScoreManager.updateCombo(combo, scores)
	scores.Combo.Total = combo
end

function ScoreManager:GetTotalScore()
	return self
end

function ScoreManager:UpdateMissScore()
	self.Combo.Total = 0
	self.Miss.Total = self.Miss.Total + 1	
	return ScoreManager.CalculateGrade(true, self)	
end

function ScoreManager:CalculateHit(map, timeOfHit, noteToCheck)	
	local note = nil	
	local expectedHit = 0
	
	if noteToCheck.Note.held == true then
		expectedHit = noteToCheck.Note.endTimestamp		
	else
		expectedHit = noteToCheck.Note.Timestamp		
	end
	note = noteToCheck.Note
								
	if note ~= nil then
		local score	
		local grade
		local expectedTime = 0
		
		if noteToCheck.Note.held == false then
			expectedTime = math.abs((timeOfHit - expectedHit) + noteToCheck.Mag)
		else
			expectedTime = math.abs((timeOfHit - expectedHit) - 1)			
		end
						
		score = ScoreManager.CalculatePoints(score, map, expectedTime, self)	
		grade = ScoreManager.CalculateGrade(true, self)
		
		table.insert(score, note.Name)	
		table.insert(score, grade)	
		return score									
	end
end

function ScoreManager.CalculatePoints(score, totalNotes, expected, scores)
	local currentCombo = scores.Combo.Total			
	local scoreCalculation = 0
	
	if currentCombo > scores.Combo.maxCombo then
		scores.Combo.maxCombo = currentCombo
	end
				
	if expected >= 0 and expected <= 3 then
		local weight = 0	
		local modifier = 3
			
		if expected <= 1 then
			weight = scores.Weighting.Perfect
			modifier = 1
		elseif expected <= 2 then
			weight = scores.Weighting.Good
			modifier = 2
		else
			weight = scores.Weighting.Okay
			modifier = 3								
		end
		
		-- TODO: Implement difficulty multiplier based on map diff	
		--local diffMultiplier = (0.8 + 100) / 100
		if currentCombo > 0 then
			local comboMultiplier = (currentCombo + 100) / 100
			if comboMultiplier > 2.5 then
				comboMultiplier = 2.5
			end											
			scoreCalculation = math.floor((weight * scores.Mods[modifier]) / totalNotes * comboMultiplier)				
		else
			scoreCalculation = math.floor((weight * scores.Mods[modifier]) / totalNotes)		
		end
				
		scores.Score.Total = scores.Score.Total + scoreCalculation
		
		if expected <= 1 then
			score = scoreText.Perfect		
			scores.Combo.Total = scores.Combo.Total + 1
			scores.Perfect.Total = scores.Perfect.Total + 1						
		elseif expected <= 2 then
			score = scoreText.Good
			scores.Combo.Total = scores.Combo.Total + 1	
			scores.Good.Total = scores.Good.Total + 1	
		elseif expected <= 3 then
			score = scoreText.Okay	
			scores.Combo.Total = scores.Combo.Total + 1
			scores.Okay.Total = scores.Okay.Total + 1						
		else
			score = scoreText.Miss
			scores.Combo.Total = 0
			scores.Miss.Total = scores.Miss.Total + 1			
		end	
	else
		score = scoreText.Miss
		scores.Combo.Total = 0
		scores.Miss.Total = scores.Miss.Total + 1										
	end	
		
	return {score, scores.Score.Total, scores.Combo.Total}						
end

function ScoreManager.CalculateGrade(formatted, scores)	
	local grade = ""
	local total = ((scores.Mods[1] * scores.Perfect.Total) + (scores.Mods[2] * scores.Good.Total) + (scores.Mods[3] * scores.Okay.Total) + scores.Miss.Total)
	local max = scores.Mods[1] * (scores.Miss.Total + scores.Okay.Total + scores.Good.Total + scores.Perfect.Total)
	
	local accuracy = (total / max) * 100
	
	if accuracy >= 100 then
		grade = "S+"
	elseif accuracy >= 90 then
		grade = "S"
	elseif accuracy >= 80 then
		grade = "A"
	elseif accuracy >= 70 then
		grade = "B"
	elseif accuracy >= 60 then
		grade = "C"
	else
		grade = "D"
	end
		
	if formatted == true then
		return grade.." ("..(math.floor(accuracy * 100)/100).."%)"
	else
		return grade
	end		
end

function ScoreManager:UpdateGrade(player, title)
	local grade = ScoreManager.CalculateGrade(false, self)
	local data = playerDataManager.GetPlayer(player)
	local playedTrack = data:GetTrackScore(title)
	
	if data == nil then
		local errorMessage = errorHandler.GetErrorMessage("scoremanager", errorHandler.errors.player_not_found)
		return warn(errorMessage)
	end
				
	local updateExistingScore = false
	local setNewScore = false
	
	if playedTrack ~= nil then
		if playedTrack.Score < self.Score.Total then
			updateExistingScore = true
		end	
	else
		setNewScore = true
	end		
	if setNewScore then
		data:SetTrackScore(title, self.Score.Total, self.Combo.maxCombo, grade)
	elseif updateExistingScore then
		data:UpdateTrackScore(title, self.Score.Total, self.Combo.maxCombo, grade)
	end	
	
	return grade					
end

return ScoreManager