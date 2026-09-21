local PlayerUiMobile = script.Parent

local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

local Dash = PlayerUiMobile.Dash
local Parry = PlayerUiMobile.Parry

local DashEvent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerMovementsEvents.Dash
local ParryEvent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerCombatEvents.Parry

local DashClone = game:GetService("ReplicatedStorage").VFX.PlayerVFX.DASHVFX.DashClone
function CloneEffect(DashAmount)
	for i = 1,DashAmount do
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
Dash.Activated:Connect(function()
	if GetPlayerStates(Player, "Dashed") == nil then
		DashEvent:FireServer()
		CloneEffect(6)
		SetPlayerState(Player, "Dashed", "number", 1.2)
	end		
end)
Parry.Activated:Connect(function()
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
		RemoveState(Player, "ParryCooldown")
		local ParryOrSuccessAnimationTrack = Animator:LoadAnimation(ParryOrSuccessAnimation)
		ParryOrSuccessAnimationTrack:Play()
		CloneEffect(1)
	end)
	Debris:AddItem(ParryOrSuccessAnimation, 0.6)
end)