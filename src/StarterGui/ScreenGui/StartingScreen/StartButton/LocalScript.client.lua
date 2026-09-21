local Button = script.Parent
local EnemySelectionScreen = script.Parent.Parent.Parent.EnemySelection
local StartingScreen = script.Parent.Parent 

Button.MouseButton1Down:Connect(function()
	StartingScreen.Visible = false
	EnemySelectionScreen.Visible = true
end)