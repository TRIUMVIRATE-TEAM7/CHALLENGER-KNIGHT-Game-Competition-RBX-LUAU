local Boss = script.Parent
local Players = game:GetService("Players") 
local Debris = game:GetService("Debris")
local BossAttackEvent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerGUIinteractionEvents.BossAttack

local Animator = Boss.Enemy.Animator
local WARNFX = Boss.Head.warnVFX.ParticleEmitter
local MovementStatus = Boss.Enemy.CurrentStatus
--Services
local TweenService = game:GetService("TweenService")

--Modules--
local MovementModule = require(game:GetService("ReplicatedStorage").Modules.EnemyMovementModule)
local DamageModule = require(game:GetService("ReplicatedStorage").Modules.PlayerHitModule)
local StateManger = require(game:GetService("ReplicatedStorage").Modules.PlayerStateManger)
local SoundModule = require(game:GetService("ReplicatedStorage").Modules.SoundModule)

function Sound(SoundId, Parent, Volume)
	SoundModule.Sound(SoundId, Parent, Volume)
end

--Animation Preload
local Attack1Animation = Instance.new("Animation")
Attack1Animation.AnimationId = ("rbxassetid://111826455198649")
local Attack1AnimationTrack = Animator:LoadAnimation(Attack1Animation)
Attack1AnimationTrack.Priority = Enum.AnimationPriority.Action

local Attack2Animation = Instance.new("Animation")
Attack2Animation.AnimationId = ("rbxassetid://82493733463096")
local Attack2AnimationTrack = Animator:LoadAnimation(Attack2Animation)
Attack2AnimationTrack.Priority = Enum.AnimationPriority.Action

function summonBlades(numberOfBlades, delayBetweenBladeSpawn, Predict)
	local SpawnPartGroup = game:GetService("ReplicatedStorage").VFX.BossVFX.ConquererBossVFX.RainofSwords:Clone()
	SpawnPartGroup.Parent = workspace
	local Attack = SpawnPartGroup.PrimaryPart
	Attack.Parent = SpawnPartGroup
	Attack.Position = Boss.HumanoidRootPart.Position + Vector3.new(0, 35, 0)
	if Predict == true then
		local Player = Players:GetPlayers()[1]
		local PredictedParticle = game:GetService("ReplicatedStorage").VFX.BossVFX.ConquererBossVFX.Predicted.Attachment:Clone()
		PredictedParticle.Parent = Player.Character.HumanoidRootPart
		PredictedParticle.ParticleEmitter:Emit(1)
		Debris:AddItem(PredictedParticle, 2)
	end
	for i = 1, numberOfBlades do
		Sound(3015952873, Boss.Torso, 2)
		coroutine.wrap(function()
			local Player = Players:GetPlayers()[1]
			local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

			local x = Attack.Position.X + math.random(-Attack.Size.X/2,Attack.Size.X/2)
			local y = Attack.Position.Y + math.random(-Attack.Size.Y/2,Attack.Size.Y/2)
			local z = Attack.Position.Z + math.random(-Attack.Size.Z/2,Attack.Size.Z/2)

			local Sword = game:GetService("ReplicatedStorage").VFX.BossVFX.ConquererBossVFX.Sword:Clone()

			Sword.Parent = SpawnPartGroup
			Sword.Position = Vector3.new(x,y,z)

			for _, v in pairs(Sword.VFXattach:GetChildren()) do
				task.wait(0.01)
				v:Emit(1)
			end

			Sword.CFrame = CFrame.lookAt(Sword.Position, playerHRP.Position)

			local distanceBetweenPlayerandSword = (playerHRP.Position - Sword.Position).Magnitude
			local LocationToTravel = {Position = Sword.Position + Sword.CFrame.LookVector*-(distanceBetweenPlayerandSword*2)}

			local RaycastParams = RaycastParams.new()
			RaycastParams.FilterDescendantsInstances = {SpawnPartGroup, Player.Character, Boss}

			local RayCast = workspace:Raycast(Sword.Position, Sword.CFrame.LookVector*200, RaycastParams)
			if RayCast then
				LocationToTravel = {Position = RayCast.Position + Sword.CFrame.LookVector*1}
			end

			local PredictedMovement = Vector3.new()

			if Predict == true then
				PredictedMovement = Vector3.new((playerHRP.Velocity/1.2).X, 0, (playerHRP.Velocity/1.2).Z)
			end

			LocationToTravel.Position += PredictedMovement

			Sword.CFrame = CFrame.lookAt(Sword.Position, LocationToTravel.Position)

			Sword.CFrame *= CFrame.Angles(0, math.rad(180), 0)
			local speedOfSword = (distanceBetweenPlayerandSword * 0.4) / distanceBetweenPlayerandSword

			local SwordFly = TweenService:Create(Sword, TweenInfo.new(speedOfSword, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), LocationToTravel)
			SwordFly:Play()

			Sword.Touched:Connect(function(hit)
				if hit.Parent == Player.Character and hit.Parent:FindFirstChild("Humanoid") and hit.Parent:FindFirstChild("Humanoid").Health > 0 and not hit.Parent:FindFirstChild("Enemy") and hit ~= true then
					hit = true
					DamageModule.PlayerIsHit(Player, 10)
				end
			end)
			SwordFly.Completed:Connect(function()
				wait(0.6)
				Sword:Destroy()
			end)
		end)()
		task.wait(delayBetweenBladeSpawn)
	end
end

--Attack1--
function Attack1(RandomizedTeleports)
	Attack1AnimationTrack:GetMarkerReachedSignal("Attack"):Connect(function()
		Sound(129132458685715, Boss.Torso, 5)
		local Hits = {}
		for _, hit : BasePart in pairs(workspace:GetPartBoundsInRadius(Boss.HumanoidRootPart.Position, 10)) do
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")

			if player and humanoid and humanoid.Health > 0 and not Hits[humanoid] then
				Hits[humanoid] = true
				if StateManger.ReturnState(player, "Parrying") then
					local Bv = Instance.new("BodyVelocity")
					Debris:AddItem(Bv, 0.1)
					Bv.Parent = player.Character.HumanoidRootPart
					Bv.P = 500000
					Bv.MaxForce = Vector3.new(20000, 0, 20000)
					Bv.Velocity = Boss.HumanoidRootPart.CFrame.LookVector*50
				end
				DamageModule.PlayerIsHit(player, 30)
			end
		end
	end)
	Attack1AnimationTrack:GetMarkerReachedSignal("AttackWarn"):Connect(function()
		
		local Player = Players:GetPlayers()[1]
		local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		task.wait(0.1)
		local random = 1
		if RandomizedTeleports then
			random = math.random(1,2)
		end
		if random == 1 then
			Boss.HumanoidRootPart:PivotTo(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*3))
		else
			Boss.HumanoidRootPart:PivotTo(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*-3))
		end
		MovementModule.LookAtPlayer(Boss, Player)
		WARNFX:Emit(5)
	end)

	Attack1AnimationTrack:Play()
end

--Attack2--
function Attack2()
	Attack2AnimationTrack:GetMarkerReachedSignal("Attack"):Once(function()
		Sound(129132458685715, Boss.Torso, 5)
		local Hits = {}
		for _, hit : BasePart in pairs(workspace:GetPartBoundsInRadius(Boss.HumanoidRootPart.Position, 10)) do
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			local humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")

			if player and humanoid and humanoid.Health > 0 and not Hits[humanoid] then
				Hits[humanoid] = true
				if StateManger.ReturnState(player, "Parrying") then
					local Bv = Instance.new("BodyVelocity")
					Debris:AddItem(Bv, 0.1)
					Bv.Parent = player.Character.HumanoidRootPart
					Bv.P = 500000
					Bv.MaxForce = Vector3.new(20000, 0, 20000)
					Bv.Velocity = Boss.HumanoidRootPart.CFrame.LookVector*50
				end
				DamageModule.PlayerIsHit(player, 30)
			end
		end
	end)
	Attack2AnimationTrack:GetMarkerReachedSignal("Attack Warn"):Once(function()
		
		local Player = Players:GetPlayers()[1]
		local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		task.wait(0.1)
		local random = math.random(1,2)
		if random == 1 then
			Boss.HumanoidRootPart:PivotTo(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*3))
		else
			Boss.HumanoidRootPart:PivotTo(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*-3))
		end
		MovementModule.LookAtPlayer(Boss, Player)
		WARNFX:Emit(5)
	end)

	Attack2AnimationTrack:GetMarkerReachedSignal("Attack Warn 2"):Once(function()
		
		Sound(129132458685715, Boss.Torso, 5)
		local originalWalkSpeed = Boss.Enemy.WalkSpeed
		local Player = Players:GetPlayers()[1]
		local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		Boss.Enemy.WalkSpeed = 50

		WARNFX:Emit(5)
		wait(0.8)
		Boss.Enemy.WalkSpeed = originalWalkSpeed
	end)

	Attack2AnimationTrack:Play()
end
--Attack3--


wait(5)
local Player = Players:GetPlayers()[1]
while wait(2) and Boss.Enemy.Health > 750 do
	BossAttackEvent:FireClient(Player, "<The Conquerer stabs you.>")
	Attack1()
	wait(1)
	BossAttackEvent:FireClient(Player, "<The Conquerer performs a combo.>")
	Attack2()
	wait(2)
	BossAttackEvent:FireClient(Player, "<The Conquerer performs unleashes the swords of the fallen.>")
	summonBlades(5, 0.7)
end

SoundModule.BossMusic(110314072575208, 5, 9)
local FF = Instance.new("ForceField")
FF.Parent = script.Parent
FF.Visible = false
BossAttackEvent:FireClient(Player, "<The Conquerer recognizes a worthy opponent.>")
game:GetService("Debris"):AddItem(FF, 12)
game:GetService("TweenService"):Create(game:GetService("Lighting"), TweenInfo.new(9), {FogEnd = 1200}):Play()
coroutine.wrap(function()
	for i = 1, 20 do
		wait(0.2)
		local Phrases = {"[I'm scared]", "[I feel my end approaching.]", "[I should turn back.]", "[This is not worth it.]", "[This is not worth it.]", "[I'm not ready.]"}
		local Indicator = game:GetService("ReplicatedStorage").VFX.PlayerVFX.Indicator.StunnedBillBoard:Clone()
		game:GetService("TweenService"):Create(Indicator.TextLabel, TweenInfo.new(0.1), {TextTransparency = 1} ):Play()
		Indicator.TextLabel.Text = Phrases[math.random(1, 6)]
		Indicator.Parent = Player.Character.Head
	end
end)()
wait(9)
script.Parent.AttacksPhase2.Enabled = true
script.Enabled = false