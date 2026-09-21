local MovementModule = require(game:GetService("ReplicatedStorage").Modules.EnemyMovementModule)
local Boss = script.Parent
local Players = game:GetService("Players")
local MovementStatus = Boss.Enemy.CurrentStatus
local Animatior = Boss.Enemy.Animator
local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://109685077220379"
local AnimationTrack = Animatior:LoadAnimation(Animation)
AnimationTrack:Play()
wait(4)
while wait() do
	if Players:GetPlayers() then
		local Player = Players:GetPlayers()[1]
		if Player and MovementStatus.Value == "HUNT" then
			MovementModule.MoveToPlayer(Boss, Player)
		end
	end
end