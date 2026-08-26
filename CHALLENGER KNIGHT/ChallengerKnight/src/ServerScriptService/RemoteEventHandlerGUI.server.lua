--Initialize Important Stuff
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StartFightEvent = ReplicatedStorage.RemoteEvents.PlayerGUIinteractionEvents.BossFight
local Players = game:GetService("Players")
local GameStartModule = require(ReplicatedStorage.Modules.GameStart)

StartFightEvent.OnServerEvent:Connect(function(Player, Difficulty)
	print("Start Fight ", Difficulty)
	local Humanoid = Player.Character:WaitForChild("Humanoid")
	local Animator = Humanoid:WaitForChild("Animator")

	local SpawnAnim = Instance.new("Animation")
	SpawnAnim.AnimationId = "rbxassetid://80246302907417"
	local SpawnAnimTrack = Animator:LoadAnimation(SpawnAnim)
	SpawnAnimTrack:Play()
	
	GameStartModule.StartTheGame(Player, Difficulty)
end)