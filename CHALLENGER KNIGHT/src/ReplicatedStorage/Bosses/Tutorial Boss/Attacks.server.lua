--Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Boss = script.Parent
local HRP = Boss.HumanoidRootPart
local Torso = Boss.Torso
local Enemy = Boss.Enemy
local movementStatus = Boss.Enemy.CurrentStatus
local EnemyMovementModule = require(game.ReplicatedStorage.Modules.EnemyMovementModule)

--Attack1AnimationSide--
local Animator = Enemy.Animator
local firstAttackTrack = Animator:LoadAnimation(script["Punch Anim"])
firstAttackTrack:GetMarkerReachedSignal("Attack"):Connect(function()
	local Attack = ReplicatedStorage.VFX.BossVFX.TutorialBossVFXAttacks.airPunch:Clone()
	Attack.Parent = workspace
	Attack.CFrame = HRP.CFrame
	local Player = Players:GetPlayers()[1]
	local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if playerHRP then
		Attack.CFrame = CFrame.lookAt(Attack.Position, playerHRP.Position)
		local Tween = TweenService:Create(Attack, TweenInfo.new(0.5), {Position = Attack.Position + Attack.CFrame.LookVector * 50})
		Tween:Play()
		Tween.Completed:Connect(function()
			Attack:Destroy()
		end)
	end
end)
firstAttackTrack:GetMarkerReachedSignal("AttackWarn"):Connect(function()
end)


while wait() do
	movementStatus.Value = "Chase"
	wait(3)
	movementStatus.Value = "Offensive"
	firstAttackTrack:Play()
	wait(2.5)
end