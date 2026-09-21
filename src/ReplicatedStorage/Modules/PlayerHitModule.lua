local module = {}
--Modules and commands--
local SoundModule = require(game:GetService("ReplicatedStorage").Modules.SoundModule)

function Sound(SoundId, Parent, Volume)
	SoundModule.Sound(SoundId, Parent, Volume)
end
---PlayerStateManager
local PlayerStateManager = require(game:GetService("ReplicatedStorage").Modules.PlayerStateManger)
local RemoteEventFolder = game:GetService("ReplicatedStorage").RemoteEvents
local PlayerGUICommunicatorEvent = RemoteEventFolder.PlayerGUIinteractionEvents.PlayerGuiCommunicator --This is a remote event that listens to actions of player triggered in this file and send it to both player and Server
local PlayerGUIBossUIEVent = RemoteEventFolder.PlayerGUIinteractionEvents.BossFight
local PointChangeRemoteEvent = RemoteEventFolder.PlayerCombatEvents.PointChangeEvent 
---Services
local TweenService = game:GetService("TweenService")

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

local function CreateForceField(Player)
	local ForceField = Instance.new("ForceField")
	ForceField.Parent = Player.Character
	ForceField.Visible = false
	game:GetService("Debris"):AddItem(ForceField, 0.01)
end

--Values
--Multipliers--
local PlayerParryValue = 5
local PlayerDashedThroughAttackValue = 1.2
--BaseValues--
local PlayerAttackValue = 10
--Negative VAlues
local PlayerHitValue = -50

---DamageModule
function module.PlayerIsHit(Player, Damage)
	if GetPlayerStates(Player, "Parrying") then
		PlayerGUICommunicatorEvent:FireClient(Player, "PARRIED", Damage, PlayerParryValue)
		RemoveState(Player, "Parrying")
		RemoveState(Player, "ParryCooldown")
		CreateForceField(Player)
		game:GetService("ReplicatedStorage").RemoteEvents.PlayerCombatEvents.Parry:FireClient(Player, true, "SUCCESS")
		PointChangeRemoteEvent:Invoke(Player, PlayerParryValue * Damage)
		Sound(126570676614497, Player.Character, 3)
	elseif GetPlayerStates(Player, "Dashing") then
		PlayerGUICommunicatorEvent:FireClient(Player, "DODGED", Damage, PlayerDashedThroughAttackValue)
		PointChangeRemoteEvent:Invoke(Player, PlayerDashedThroughAttackValue * Damage)
		CreateForceField(Player)
	else
		if Player.Character:FindFirstChild("ForceField") then
			
		else
			local Indicator = game:GetService("ReplicatedStorage").VFX.PlayerVFX.Indicator.StunnedBillBoard:Clone()
			Indicator.TextLabel.Text = "[It hurts.]"
			Indicator.Parent = Player.Character.Head
			game:GetService("TweenService"):Create(Indicator.TextLabel, TweenInfo.new(0.5), {TextTransparency = 1} ):Play()
			game:GetService("Debris"):AddItem(Indicator, 1)

			Player.Character.Humanoid:TakeDamage(Damage)
			PlayerGUICommunicatorEvent:FireClient(Player, "Hit", PlayerHitValue)
			PointChangeRemoteEvent:Invoke(Player, PlayerHitValue)
		end
	
	end
end

function module.PlayerHitandDamageEnemyIfHit(Player, Damage)
	local Hits = {}
	for _, hit : BasePart in pairs(workspace:GetPartBoundsInRadius(Player.Character.Torso.Position, 8)) do
		local enemyHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		local enemyTag = hit.Parent:FindFirstChild("Enemy")
		local NonEnemyTag = enemyHumanoid and enemyHumanoid:HasTag("NonEnemy")
		if enemyTag and enemyHumanoid and enemyHumanoid.Health > 0 and not Hits[enemyHumanoid] and not NonEnemyTag then
			Hits[enemyHumanoid] = true
			enemyHumanoid:TakeDamage(Damage)
			PlayerGUICommunicatorEvent:FireClient(Player, "SUCCESSFUL HIT", PlayerAttackValue)	
			PlayerGUIBossUIEVent:FireClient(Player, "bossHealthUpdate", enemyHumanoid.Health, enemyHumanoid.MaxHealth, hit.Name)
			PointChangeRemoteEvent:Invoke(Player, PlayerAttackValue)
		end
	end
end

return module
	