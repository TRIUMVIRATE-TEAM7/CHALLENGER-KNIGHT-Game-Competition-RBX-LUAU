local RemoteEventFolder = game:GetService("ReplicatedStorage").RemoteEvents
local UserInputService = game:GetService("UserInputService")
local PlayerGUICommunicatorEvent = RemoteEventFolder.PlayerGUIinteractionEvents.PlayerGuiCommunicator
local PlayerGUIBossUIEvent = RemoteEventFolder.PlayerGUIinteractionEvents.BossFight
local PlayerGUIBossAttackEvent = RemoteEventFolder.PlayerGUIinteractionEvents.BossAttack
---UI---
local GUI = game:GetService("Players").LocalPlayer.PlayerGui
local IngamePlayerGUI = GUI:WaitForChild("IngameGUI")
local EndScreenUI = GUI:WaitForChild("EndScreenGui")

local PlayerUI = IngamePlayerGUI.PlayerUI
if UserInputService.TouchEnabled then
	PlayerUI = IngamePlayerGUI.PlayerUIMobile
	IngamePlayerGUI.PlayerUIMobile.Visible = true
else
	PlayerUI.Visible = true
end

local PointCounter =PlayerUI.Points.PointCounter
local StyleTracker = PlayerUI.Points.PointCounter.StyleTracker
local StyleTextFormat = script.FORMAT

PlayerGUICommunicatorEvent.OnClientEvent:Connect(function(eventType, PointsForAction, Multiplier)
	if eventType == "PARRIED" then
		PointCounter.Text += (PointsForAction * Multiplier)
	elseif eventType == "DODGED" then
		PointCounter.Text += (PointsForAction * Multiplier)
	elseif eventType == "Hit" then
		PointCounter.Text += PointsForAction
	elseif eventType == "SUCCESSFUL HIT" then
		PointCounter.Text += PointsForAction
	end
	
	if not Multiplier then
		Multiplier = 1
	end
	
	if eventType ~= "Hit" then
		local newStyleText = StyleTextFormat:Clone()
		newStyleText.Text = `{eventType} + {PointsForAction * Multiplier} Points`
		newStyleText.Parent = StyleTracker
		game:GetService("Debris"):AddItem(newStyleText, 3.3)
	end
	
	if eventType == "Lose" then
		PointCounter.Text = 0
		EndScreenUI.Enabled = true
		EndScreenUI.EndScreen.Score.Text = `Score: {PointsForAction} Points`
		EndScreenUI.EndScreen["Game Over"].Text = `Game Over.`
	elseif eventType == "Win" then
		PointCounter.Text = 0
		EndScreenUI.Enabled = true
		EndScreenUI.EndScreen.Score.Text = `Score: {PointsForAction} Points`
		EndScreenUI.EndScreen["Game Over"].Text = `You win!`
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

PlayerGUIBossAttackEvent.OnClientEvent:Connect(function(BossAttack)
	local AttackUI = IngamePlayerGUI.BossHPUI["Current Attack"]
	AttackUI.Visible = true
	AttackUI.TextLabel.Text = BossAttack
	AttackUI.TextLabel.BackgroundTransparency = 0
	AttackUI.TextLabel.TextTransparency = 0
	
	game:GetService("TweenService"):Create(AttackUI.TextLabel, TweenInfo.new(2), {BackgroundTransparency = 1}):Play()
	game:GetService("TweenService"):Create(AttackUI.TextLabel, TweenInfo.new(2), {TextTransparency = 1}):Play()
end)