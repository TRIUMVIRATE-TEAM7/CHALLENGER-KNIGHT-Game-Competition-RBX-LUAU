local ParentFolder = script.Parent
local RemoteEventToSend = game:GetService("ReplicatedStorage").RemoteEvents.PlayerGUIinteractionEvents.BossFight
local buttons = {
	[ParentFolder.TutorialFrame.StartButton] = "Tutorial",
	[ParentFolder.EasyFrame.StartButton] = "Easy",
	[ParentFolder.MediumFrame.StartButton] = "Medium",
	[ParentFolder.DifficultFrame.StartButton] = "Difficult",
}
local ChosenDifficulty = false

local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui

if ChosenDifficulty == false then
	for button, name in pairs(buttons) do
		button.Activated:Connect(function()
			local GameUI = PlayerGui:FindFirstChild("IngameGUI")
			if not GameUI then
				warn("IngameGUI not found in PlayerGui")
				return
			end
			if name == "Tutorial" then
				RemoteEventToSend:FireServer("Tutorial")
			elseif name == "Easy" then
				RemoteEventToSend:FireServer("Easy")
			elseif name == "Medium" then
				RemoteEventToSend:FireServer("Medium")
			elseif name == "Difficult" then
				RemoteEventToSend:FireServer("Difficult")
			end
			button.Parent.Visible = false
			GameUI.Enabled = true
		end)
	end
end