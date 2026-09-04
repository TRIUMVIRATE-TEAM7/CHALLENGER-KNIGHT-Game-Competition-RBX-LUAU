local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local DashClone = game:GetService("ReplicatedStorage").VFX.PlayerVFX.DASHVFX.DashClone
function DashEffect()
	for i = 1,6 do
		local Clone = DashClone:Clone()
		Clone:PivotTo(Character.HumanoidRootPart.CFrame)
		Clone.Parent = workspace
		game.Debris:AddItem(Clone,0.5)
		spawn(function()
			for i,v in pairs(Clone:GetChildren()) do
				spawn(function()
					if v:IsA("MeshPart") or v:IsA("Part") then
						Debris:AddItem(v, 2)
						v.CFrame = Character:FindFirstChild(v.Name).CFrame
						for i = 0.25,1,0.1 do
							v.Transparency = i
							wait()
						end
					end
				end)
			end	
		end)
		wait(0.05)
	end
end

--Module and commands--
local PlayerStateManager = require(game:GetService("ReplicatedStorage").Modules.PlayerStateManger)
function SetPlayerState(Player, State, Value, Duration)
	return PlayerStateManager.SetState(Player, State, Value, Duration)
end
function RemoveState(Player, StateKey)
	return PlayerStateManager.RemoveStates(Player, StateKey)
end
function GetPlayerStates(Player, StateKey)
	return PlayerStateManager.GetState(Player, StateKey)
end

AttackCycle = 1 --For animation purposes

---Dash
local DashEvent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerMovementsEvents.Dash

--Parrying and Attack
local ParryEvent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerCombatEvents.Parry
local Attackevent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerCombatEvents.Attack

UserInputService.InputBegan:Connect(function(input, gameprocessed)
	if gameprocessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if GetPlayerStates(Player, "Attacking") == nil then
			if AttackCycle < 3 then
				AttackCycle += 1
			else 
				AttackCycle = 1
			end
			local AttackAnimation = Instance.new("Animation")
			Debris:AddItem(AttackAnimation, 0.8)
			SetPlayerState(Player, "Attacking", true, 0.77)
			Attackevent:FireServer()
			if AttackCycle == 1 then
				AttackAnimation.AnimationId = "rbxassetid://106068744828914"
				local AttackAnimationtrack = Animator:LoadAnimation(AttackAnimation)
				AttackAnimationtrack:Play()
			elseif AttackCycle == 2 then
				AttackAnimation.AnimationId = "rbxassetid://136090457201655"
				local AttackAnimationtrack = Animator:LoadAnimation(AttackAnimation)
				AttackAnimationtrack:Play()
			else 
				AttackAnimation.AnimationId = "rbxassetid://89637669450596"
				local AttackAnimationtrack = Animator:LoadAnimation(AttackAnimation)
				AttackAnimationtrack:Play()
			end
		end
	end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		--Dash Handler
		if input.KeyCode == Enum.KeyCode.Q then
			if GetPlayerStates(Player, "Dashed") == nil then
				DashEvent:FireServer()
				DashEffect()
				SetPlayerState(Player, "Dashed", "number", 2)
			end		
		end
		
		--Parry Handler
		if input.KeyCode == Enum.KeyCode.F then
			local ParryOrSuccessAnimation = Instance.new("Animation")

			if GetPlayerStates(Player, "ParryCooldown") == nil then
				ParryOrSuccessAnimation.AnimationId = "rbxassetid://101166422681659"
				local ParryOrSuccessAnimationTrack = Animator:LoadAnimation(ParryOrSuccessAnimation)
				ParryOrSuccessAnimationTrack:Play()
				ParryEvent:FireServer()
				SetPlayerState(Player, "ParryCooldown", "number", 0.6)
			end
			ParryEvent.OnClientEvent:Connect(function()
				print("Parry Successful")
				ParryOrSuccessAnimation.AnimationId = "rbxassetid://78947804962239"
				local ParryOrSuccessAnimationTrack = Animator:LoadAnimation(ParryOrSuccessAnimation)
				ParryOrSuccessAnimationTrack:Play()
			end)

		end
	end
end)