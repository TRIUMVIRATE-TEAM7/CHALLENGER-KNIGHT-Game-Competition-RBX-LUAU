local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local IdleAnim = Instance.new("Animation")
IdleAnim.AnimationId = "rbxassetid://80246302907417"
local IdleAnimTrack = Animator:LoadAnimation(IdleAnim)

wait(4)
IdleAnimTrack:Play()