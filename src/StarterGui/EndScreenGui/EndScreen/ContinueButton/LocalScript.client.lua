local Button = script.Parent
local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
Button.MouseButton1Down:Connect(function()
	local EndGUI = PlayerGui:FindFirstChild("EndScreenGui")
	local StartingGUI = PlayerGui:FindFirstChild("ScreenGui")
	local IngameGUI = PlayerGui:FindFirstChild("IngameGUI")
	if EndGUI then
		EndGUI.Enabled = false
	end
	if StartingGUI then
		StartingGUI.Enabled = true
		-- Reset the StartingScreen frame so it's visible again
		local StartingScreen = StartingGUI:FindFirstChild("StartingScreen")
		local EnemySelection = StartingGUI:FindFirstChild("EnemySelection")
		local BossFrames = StartingGUI:FindFirstChild("BossFrames")
		if StartingScreen then
			StartingScreen.Visible = true
		end
		if EnemySelection then
			EnemySelection.Visible = false
		end
		if BossFrames then
			for _, frame in ipairs(BossFrames:GetChildren()) do
				if frame:IsA("Frame") then
					frame.Visible = false
				end
			end
		end
	end
	if IngameGUI then
		IngameGUI.Enabled = false
	end
end)