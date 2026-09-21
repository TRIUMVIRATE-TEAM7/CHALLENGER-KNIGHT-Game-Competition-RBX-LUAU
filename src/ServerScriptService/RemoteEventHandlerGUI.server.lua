--Initialize Important Stuff
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GameStartModule = require(ReplicatedStorage.Modules.GameStartandEnd)

--Events
local StartFightEvent = ReplicatedStorage.RemoteEvents.PlayerGUIinteractionEvents.BossFight
local PlayerGuiCommunicatorEvent = ReplicatedStorage.RemoteEvents.PlayerGUIinteractionEvents.PlayerGuiCommunicator

StartFightEvent.OnServerEvent:Connect(function(Player, Difficulty)
	print("Start Fight ", Difficulty)
	local Humanoid = Player.Character:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator")

	local SpawnAnim = Instance.new("Animation")
	SpawnAnim.AnimationId = "rbxassetid://80246302907417"
	local SpawnAnimTrack = Animator:LoadAnimation(SpawnAnim)
	SpawnAnimTrack:Play()
	
	if Difficulty == "Tutorial" then
		local TutorialBoss = ReplicatedStorage.Bosses["Tutorial Boss"]:Clone()
		TutorialBoss.Parent = workspace
		GameStartModule.StartTheGame(Player, "Tutorial", TutorialBoss)
	elseif Difficulty == "Difficult" then
		local DifficultBoss = ReplicatedStorage.Bosses["The Conquerer"]:Clone()
		DifficultBoss.Parent = workspace
		GameStartModule.StartTheGame(Player, "Difficult", DifficultBoss)
	end
	game:GetService("Lighting").FogEnd = 200
end)

PlayerGuiCommunicatorEvent.OnServerEvent:Connect(function(Player, GUI)
	
end)