local module = {}

----------LEGEND----------
--PLAYER = TARGETTED PLAYER
--STATEKEY = NAME OF THE STATE
--VALUE = VALUE OF THE STATE (i.e = if it's a bool or an integer)
--DURATION = SELF EXPLANATORY
-------------------------
local Debris = game:GetService("Debris")
local states = {}
------------------Interaction with Player States------------------------
function module.ReturnState(Player)
	return states[Player]
end

function module.GetState(Player, stateKey)
	if states[Player] then
		return states[Player][stateKey]
	end
	return nil
end

function module.ClearAllStates()
	for Player in pairs(states) do
		states[Player] = nil
	end
	
end

function module.RemoveStates(Player, Statekey)
	if not states[Player] then return end ---IF PLAYER NOT IN STATE, STOP
	if Statekey then
		states[Player][Statekey] = nil
		if next(states[Player]) == nil then
			states[Player] = nil
		end
	else
		states[Player] = nil
	end
end

function module.SetState(Player, stateKey, value, duration)
	if not states[Player] then --CHECK IF THE PLAYER IS IN A STATE, IF NOT THEN ADD THEM TO THE STATES TABLE
		states[Player] = {}
	end
	states[Player][stateKey] = value --SET THE STATE AND VALUE OF THE STATUE (CHECK THE LEGEND)
	if duration and type(duration) == "number" then
		delay(duration, function()
			if states[Player] then
				states[Player][stateKey] = nil

				if next(states[Player]) == nil then
					states[Player] = nil
				end
			end
		end)
	end
end

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	states[plr] = nil
end)

-------------------------------------------------------------------------------
-----------------Differnt kinds of states we can put the player in-------------
function module.PlayerParry(Player, value, duration) -------this is an example but honestly we could just use SetState lol
	if not Player or not Player.Character or not Player.Character:WaitForChild("Humanoid") then return end ------- MAKE SURE THE PLAYER IS SPAWNED IN (BAD THINGS HAPPEN IF WE DONT CHECK FOR THIS)
	local humanoid = Player.Character:FindFirstChild("Humanoid")
	
	if not states[Player] then
		states[Player] = {}
	end
	
	if value then 
		states[Player]["Parrying"] = true
		
		coroutine.wrap(function()
			wait(duration)
			states[Player]["Parrying"] = false
			module.RemoveStates(Player, "Parrying")
		end)
	end
end

function module.PlayerDash(Player, value, duration, DashAmount)
	if not Player or not Player.Character or not Player.Character:WaitForChild("Humanoid") then return end ------- MAKE SURE THE PLAYER IS SPAWNED IN (BAD THINGS HAPPEN IF WE DONT CHECK FOR THIS)
	
	if not states[Player] then
		states[Player] = {}
	end
	
	if value then
		states[Player]["Dashing"] = true
		
		coroutine.wrap(function()
			local Bv = Instance.new("BodyVelocity")
			Debris:AddItem(Bv, 0.3)
			Bv.Parent = Player.Character.HumanoidRootPart
			Bv.P = 50000
			Bv.MaxForce = Vector3.new(10000, 0, 10000)
			Bv.Velocity = Player.Character.Humanoid.MoveDirection*DashAmount
			task.wait(duration)
			module.RemoveStates(Player, "Dashing")
		end)()
	end
end

return module
