local UserInputService = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

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

--Parrying
local ParryEvent = game:GetService("ReplicatedStorage").RemoteEvents.PlayerCombatEvents.Parry

UserInputService.InputBegan:Connect(function(input, gameprocessed)
	if gameprocessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if AttackCycle <= 3 then
			print(AttackCycle)
			AttackCycle += 1
		else 
			AttackCycle = 1
		end
	end
	
	if input.UserInputType == Enum.UserInputType.Keyboard then
		--Dash Handler
		if input.KeyCode == Enum.KeyCode.Q then
			if GetPlayerStates(Player, "Dashed") == nil then
				DashEvent:FireServer()
				print("Dashing from Local")
			end		
		end
		
		--Parry Handler
		if input.KeyCode == Enum.KeyCode.F then
			if GetPlayerStates(Player, "ParryCooldown") == nil then
				ParryEvent:FireServer()
			end
		end
	end
end)