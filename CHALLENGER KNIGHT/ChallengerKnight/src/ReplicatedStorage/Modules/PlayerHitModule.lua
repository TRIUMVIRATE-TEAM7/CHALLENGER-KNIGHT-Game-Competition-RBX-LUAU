local module = {}
--Modules and commands--
---PlayerStateManager
local PlayerStateManager = require(game:GetService("ReplicatedStorage").Modules.PlayerStateManger)
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
---DamageModule

function module.PlayerIsHit(Player, Damage)
	print(ReturnPlayerStates(Player))
	if GetPlayerStates(Player, "Parrying") then
		print("Player Parried")
	else
		print("Player is hit")
		Player.Character.Humanoid:TakeDamage(Damage)
		
	end
end

return module
