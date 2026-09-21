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

local Attack3Animation = Instance.new("Animation")
Attack3Animation.AnimationId = ("rbxassetid://118311629927700")
local Attack3AnimationTrack = Animator:LoadAnimation(Attack3Animation)
Attack3AnimationTrack.Priority = Enum.AnimationPriority.Action

--Extra Attacks--
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

function CloneAttack(Position)
	local Player = Players:GetPlayers()[1]
	local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	local PlayerPositionToTpTo = CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*-6)

	if Position then 
		PlayerPositionToTpTo = Position
	end

	local Afterimage = game:GetService("ReplicatedStorage").VFX.BossVFX.ConquererBossVFX.Afterimage:Clone()
	Afterimage.Parent = workspace

	local Attack1AnimationTrack = Afterimage.Enemy.Animator:LoadAnimation(Attack1Animation)
	Attack1AnimationTrack.Priority = Enum.AnimationPriority.Action
	--first tp--
	Afterimage:FindFirstChild("HumanoidRootPart"):PivotTo(PlayerPositionToTpTo)
	TweenService:Create(Afterimage.Highlight, TweenInfo.new(0.3), {FillTransparency = 0}):Play()

	Attack1AnimationTrack:GetMarkerReachedSignal("Attack"):Once(function()
		
		Sound(129132458685715, Boss.Torso, 5)
		local Hits = {}
		for _, hit : BasePart in pairs(workspace:GetPartBoundsInRadius(Afterimage.HumanoidRootPart.Position, 10)) do
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
					Bv.Velocity = Afterimage.HumanoidRootPart.CFrame.LookVector*50
				end
				DamageModule.PlayerIsHit(player, 30)
			end
		end
		wait(0.2)
		TweenService:Create(Afterimage.Highlight, TweenInfo.new(0.3), {FillTransparency = 1}):Play()
	end)
	Attack1AnimationTrack:GetMarkerReachedSignal("AttackWarn"):Once(function()
		Afterimage["Right Arm"].Spear.warnVFX.ParticleEmitter:Emit(5)

		if Position then
			PlayerPositionToTpTo = Position
		end

		Afterimage:FindFirstChild("HumanoidRootPart"):PivotTo(PlayerPositionToTpTo)
		MovementModule.LookAtPlayer(Afterimage, Player)
	end)
	Attack1AnimationTrack:Play()
	Attack1AnimationTrack:GetMarkerReachedSignal("CloneFade"):Once(function()
		TweenService:Create(Afterimage.Highlight, TweenInfo.new(0.3), {FillTransparency = 1}):Play()
		Debris:AddItem(Afterimage, 0.3)
	end)
	Debris:AddItem(Afterimage, 3) --failsafe
end

--Attack1--
function Attack1(RandomizedTeleports)
	Attack1AnimationTrack:GetMarkerReachedSignal("Attack"):Once(function()
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
	Attack1AnimationTrack:GetMarkerReachedSignal("AttackWarn"):Once(function()
		
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
		Boss.Enemy.WalkSpeed = 160

		WARNFX:Emit(5)
		wait(0.8)
		Boss.Enemy.WalkSpeed = originalWalkSpeed
	end)

	Attack2AnimationTrack:Play()
end
--Attack3--
function Attack3()
	Attack3AnimationTrack:GetMarkerReachedSignal("AttackWarn"):Once(function()
		
		local Player = Players:GetPlayers()[1]
		local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
		task.wait(0.1)
		Boss.HumanoidRootPart:PivotTo(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*3))

		MovementModule.LookAtPlayer(Boss, Player)
		WARNFX:Emit(5)
	end)

	Attack3AnimationTrack:GetMarkerReachedSignal("Attack"):Once(function()
		Sound(95332057223560, Boss.Torso, 5)
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
					Bv.Velocity = Boss.HumanoidRootPart.CFrame.LookVector*300
				end
				DamageModule.PlayerIsHit(player, 30)
			end
		end
	end)

	Attack3AnimationTrack:GetMarkerReachedSignal("Attack2"):Once(function()
		Sound(7267353919, Boss.Torso, 5)
		local Player = Players:GetPlayers()[1]
		StateManger.PlayerStunned(Player, true, 3)
		DamageModule.PlayerIsHit(Player, 30)
		
		local SlashEffect = game:GetService("ReplicatedStorage").VFX.BossVFX.ConquererBossVFX.Slash:Clone()
		SlashEffect.Parent = workspace
		SlashEffect.CFrame = Boss.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(-90), math.rad(90))
		game:GetService("TweenService"):Create(SlashEffect, TweenInfo.new(0.5), {Transparency = 1}):Play()
		Debris:AddItem(SlashEffect, 0.5)
	end)

	Attack3AnimationTrack:GetMarkerReachedSignal("Summon"):Once(function()
		MovementStatus.Value = "IDLE"
		summonBlades(50, 0.02, false)
		wait(0.5)
		
		MovementStatus.Value = "HUNT"
	end)

	Attack3AnimationTrack:GetMarkerReachedSignal("AttackWarn2"):Once(function()
		print("A")
		Sound(72268417595029, Boss.Torso, 10)
		for i = 1, 3 do
			
			Boss.Head.warnVFX.ParryOnly:Emit(5)
			wait()
		end
	end)
	Attack3AnimationTrack:Play()
end

function AttackPatterns(Number)
	SoundModule.SoundWarnAttack(script.Parent.Torso, 5)
	local Player = Players:GetPlayers()[1]
	local playerHRP = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
	if Number == 1 then
		BossAttackEvent:FireClient(Player, "<The Conquerer unleashes Gungnir's Strength.>")
		for i = 1, 3 do
			Attack1(true)
			wait(0.49)
		end
		wait(0.5)
		CloneAttack()
		wait(0.6)
		Attack2()
		wait(1.7)
		summonBlades(5,0)
	elseif Number == 2 then
		BossAttackEvent:FireClient(Player, "<The Conquerer overwhelms you with Magic.>")
		local animation = Instance.new("Animation")
		animation.AnimationId = ("rbxassetid://113640582415441")
		local AnimationTrack = Boss.Enemy.Animator:LoadAnimation(animation)
		AnimationTrack:Play()
		AnimationTrack.Ended:Connect(function()
			animation:Destroy()
		end)
		wait(0.3)
		coroutine.wrap(function()
			summonBlades(55, 0.04, false)
		end)()
		for i = 1, 3 do
			CloneAttack()
			wait(0.8)
			for i = 1, 4 do
				if i == 1 then
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*-10))
				elseif i == 2 then
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*10))
				elseif i == 3 then
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.RightVector*10))
				else
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.RightVector*-10))
				end
			end
			wait(1.2)
		end
	elseif Number == 3 then
		BossAttackEvent:FireClient(Player, "<The Conquerer attempts to catch you off guard.")
		summonBlades(20, 0.01, false)
		wait(0.3)
		Attack2()
	elseif Number == 4 then
		BossAttackEvent:FireClient(Player, "<The Conquerer combines his powers to create a powerful attack!>")
		Attack3()
		wait(5)
		for i = 1, 2 do
			for i = 1, 4 do
				if i == 1 then
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*-10))
				elseif i == 2 then
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*10))
				elseif i == 3 then
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.RightVector*10))
				else
					CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.RightVector*-10))
				end
			end
			wait(1)
		end
		wait(2)
	else		
		BossAttackEvent:FireClient(Player, "<The Conquerer performs a tricky combo>.")
		local lastPos = Boss.HumanoidRootPart.CFrame
		for i = 1, 4 do
			Attack1()
			wait(0.55)
		end
		Boss.HumanoidRootPart:PivotTo(lastPos)

		local animation = Instance.new("Animation")
		animation.AnimationId = ("rbxassetid://113640582415441")
		local AnimationTrack = Boss.Enemy.Animator:LoadAnimation(animation)
		AnimationTrack:Play()
		AnimationTrack.Ended:Connect(function()
			animation:Destroy()
		end)

		summonBlades(20, 0.01, false)
		for i = 1, 4 do
			if i == 1 then
				CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*-10))
			elseif i == 2 then
				CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.LookVector*10))
			elseif i == 3 then
				CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.RightVector*10))
			else
				CloneAttack(CFrame.new(playerHRP.Position - playerHRP.CFrame.RightVector*-10))
			end
		end
		wait(2)
	end
end

wait(5)
while wait(2) do
	AttackPatterns(5)
	AttackPatterns(2)
	wait(5)
	AttackPatterns(1)
	wait(5)
	AttackPatterns(3)
	wait(5)
	AttackPatterns(4)
end