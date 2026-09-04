--Defualt Initialization
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules and commands--
local PlayerStateManager = require(game:GetService("ReplicatedStorage").Modules.PlayerStateManger)
local PlayerHitModule = require(game:GetService("ReplicatedStorage").Modules.PlayerHitModule)

function GetPlayerStates(Player, StateKey)
	return PlayerStateManager.GetState(Player, StateKey)
end
function ReturnPlayerStates(Player)
	return PlayerStateManager.ReturnState(Player)
end
function SetPlayerState(Player, State, Value, Duration)
	return PlayerStateManager.SetState(Player, State, Value, Duration)
end
function RemoveState(Player, StateKey)
	return PlayerStateManager.RemoveStates(Player, StateKey)
end

--Dash
local DashEvent = ReplicatedStorage.RemoteEvents.PlayerMovementsEvents.Dash
local Debris = game:GetService('Debris')
--Dash Settings
local DashCoolDown = 2
local DashTime = 0.6
local DashDistance = 50
local MaxForce = Vector3.new(10000, 0, 10000)
local P = 5000

DashEvent.OnServerEvent:Connect(function(Player)
	if GetPlayerStates(Player, "Dashed") == nil then
		local PlayerTorso = Player.Character.Torso
		local Sound = script.DashSoundEffect:Clone()
		Sound.Parent = PlayerTorso

		PlayerStateManager.PlayerDash(Player, true, DashTime, DashDistance)
		
		Sound:Play()
		Sound.Ended:Connect(function()
			Sound:Destroy()
		end)
		
		SetPlayerState(Player, "Dashed", "number", DashCoolDown)
	end
end)
---------------------------------------------------

--Parry
local ParryEvent = ReplicatedStorage.RemoteEvents.PlayerCombatEvents.Parry
local ParryWindow = 0.33
local ParryCooldown = 0.6

ParryEvent.OnServerEvent:Connect(function(Player, Success)
	if Success == nil then
		local PlayerCharacter = Player.Character
		local PlayerHumanoid = PlayerCharacter.Humanoid

		if GetPlayerStates(Player, "ParryCooldown") == nil then
			SetPlayerState(Player, "Parrying", true, ParryWindow)
			SetPlayerState(Player, "ParryCooldown", "number", ParryCooldown)
		end
	else
		ParryEvent:FireClient(Player)
		print("Parried")
	end
end)

---------------------------------------------------

--Attack
local Attackevent = ReplicatedStorage.RemoteEvents.PlayerCombatEvents.Attack
local AttackCooldown = 0.77
local Damage = 10
Attackevent.OnServerEvent:Connect(function(Player)
	if GetPlayerStates(Player, "Attacking") == nil then
		PlayerStateManager.SetState(Player, "Attacking", true, AttackCooldown)
		PlayerHitModule.PlayerHitandDamageEnemyIfHit(Player, Damage)
	end
end)