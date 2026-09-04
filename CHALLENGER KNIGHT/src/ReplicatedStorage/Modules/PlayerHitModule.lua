local module = {}
--Modules and commands--
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

--Values
local PlayerParryValue = 100
local PlayerDashedThroughAttackValue = 50
local PlayerAttackValue = 10
local PlayerHeavyAttackValue = 25

--Negative VAlues
local PlayerHitValue = -50

---DamageModule
function module.PlayerIsHit(Player, Damage)
	if GetPlayerStates(Player, "Parrying") then
		PlayerGUICommunicatorEvent:FireClient(Player, "PARRIED", PlayerParryValue)
		PointChangeRemoteEvent:Invoke(Player, PlayerParryValue)
		RemoveState(Player, "Parrying")
		RemoveState(Player, "ParryCooldown")
		
		game:GetService("ReplicatedStorage").RemoteEvents.PlayerCombatEvents.Parry:FireClient(Player, true, "SUCCESS")
	elseif GetPlayerStates(Player, "Dashing") then
		PlayerGUICommunicatorEvent:FireClient(Player, "DODGED", PlayerDashedThroughAttackValue)
		PointChangeRemoteEvent:Invoke(Player, PlayerDashedThroughAttackValue)
	else
		Player.Character.Humanoid:TakeDamage(Damage)
		PlayerGUICommunicatorEvent:FireClient(Player, "Hit", PlayerHitValue)
		PointChangeRemoteEvent:Invoke(Player, PlayerHitValue)
	end
end

function module.PlayerHitandDamageEnemyIfHit(Player, Damage)
	local Hits = {}
	for _, hit : BasePart in pairs(workspace:GetPartBoundsInRadius(Player.Character.Torso.Position, 7)) do
		local enemyHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		local enemyTag = hit.Parent:FindFirstChild("Enemy")
		if enemyTag and enemyHumanoid and enemyHumanoid.Health > 0 and not Hits[enemyHumanoid] then
			Hits[enemyHumanoid] = true
			enemyHumanoid:TakeDamage(Damage)
			PlayerGUICommunicatorEvent:FireClient(Player, "SUCCESSFUL HIT", PlayerAttackValue)	
			PlayerGUIBossUIEVent:FireClient(Player, "bossHealthUpdate", enemyHumanoid.Health, enemyHumanoid.MaxHealth, hit.Name)
			PointChangeRemoteEvent:Invoke(Player, PlayerAttackValue)
		end
	end
end

return module
	