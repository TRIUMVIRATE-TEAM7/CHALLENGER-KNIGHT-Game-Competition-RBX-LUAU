local RemoteEventFolder = game:GetService("ReplicatedStorage").RemoteEvents
local PlayerGUICommunicatorEvent = RemoteEventFolder.PlayerGUIinteractionEvents.PlayerGuiCommunicator
local PlayerGUIBossUIEvent = RemoteEventFolder.PlayerGUIinteractionEvents.BossFight
local GUI = game:GetService("Players").LocalPlayer.PlayerGui
local IngamePlayerGUI = GUI.IngameGUI
local EndScreenUI = GUI.EndScreenGui
local PointCounter = IngamePlayerGUI.PlayerUI.Points.PointCounter
local StyleTracker = IngamePlayerGUI.PlayerUI.Points.PointCounter.StyleTracker
local StyleTextFormat = script.FORMAT

PlayerGUICommunicatorEvent.OnClientEvent:Connect(function(eventType, PointsForAction)
	if eventType == "PARRIED" then
		PointCounter.Text += PointsForAction
	elseif eventType == "DODGED" then
		PointCounter.Text += PointsForAction
	elseif eventType == "Hit" then
		PointCounter.Text += PointsForAction
	elseif eventType == "SUCCESSFUL HIT" then
		PointCounter.Text += PointsForAction
	end
	
	if eventType ~= "Hit" then
		local newStyleText = StyleTextFormat:Clone()
		newStyleText.Text = `{eventType} + {PointsForAction} Points`
		newStyleText.Parent = StyleTracker
		game:GetService("Debris"):AddItem(newStyleText, 3.3)
	end
	
	if eventType == "End" then
		PointCounter.Text = 0
		EndScreenUI.Enabled = true
		EndScreenUI.EndScreen.Score.Text = `Score: {PointsForAction} Points`
	end
end)

local originalHealthSize = IngamePlayerGUI.BossHPUI.Health.Size

PlayerGUIBossUIEvent.OnClientEvent:Connect(function(TypeOfEvent, bossHealth, bossHealthMAXHP, bossName)
	local healthRatio = math.clamp(bossHealth / bossHealthMAXHP, 0, 1)

	if TypeOfEvent == "gameStartingSetup" then
		IngamePlayerGUI.BossHPUI.BossName.Text = bossName
		IngamePlayerGUI.BossHPUI.BossHealthPointCounter.Text = `{bossHealth}/{bossHealthMAXHP}`
		IngamePlayerGUI.BossHPUI.Health.Size = UDim2.new(healthRatio * originalHealthSize.X.Scale, originalHealthSize.X.Offset, originalHealthSize.Y.Scale, originalHealthSize.Y.Offset)

	elseif TypeOfEvent == "bossHealthUpdate" then
		IngamePlayerGUI.BossHPUI.BossHealthPointCounter.Text = `{bossHealth}/{bossHealthMAXHP}`
		IngamePlayerGUI.BossHPUI.Health.Size = UDim2.new(healthRatio * originalHealthSize.X.Scale, originalHealthSize.X.Offset, originalHealthSize.Y.Scale, originalHealthSize.Y.Offset)
	end
end)