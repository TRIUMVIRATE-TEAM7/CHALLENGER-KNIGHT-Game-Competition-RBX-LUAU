local EnemySelectionGUI = script.Parent
local ScreenGUI = EnemySelectionGUI.Parent

local buttons = {
	[EnemySelectionGUI.Tutorial] = "Tutorial",
	[EnemySelectionGUI.Easy] = "Easy",
	[EnemySelectionGUI.Medium] = "Medium",
	[EnemySelectionGUI.Difficult] = "Difficult",
}

for button, name in pairs(buttons) do
	button.Activated:Connect(function()
		EnemySelectionGUI.Visible = false
		if name == "Tutorial" then
			ScreenGUI.BossFrames.TutorialFrame.Visible = true
		elseif name == "Easy" then
			ScreenGUI.BossFrames.EasyFrame.Visible = true
		elseif name == "Medium" then
			ScreenGUI.BossFrames.MediumFrame.Visible = true
		elseif name == "Difficult" then
			ScreenGUI.BossFrames.DifficultFrame.Visible = true
		end
	end)
end