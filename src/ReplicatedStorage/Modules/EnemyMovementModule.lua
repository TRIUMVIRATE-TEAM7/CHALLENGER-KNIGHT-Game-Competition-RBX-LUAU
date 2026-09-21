local module = {}

function module.LookAtPlayer(Enemy, Player)
	local primaryPart = Enemy.PrimaryPart
	if not primaryPart then return end

	local character = Player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	primaryPart.CFrame = CFrame.lookAt(primaryPart.Position, Vector3.new(hrp.Position.X, primaryPart.Position.Y, hrp.Position.Z))
end

function module.MoveToPlayer(Enemy, Player, Distance)
	local enemyHRP = Enemy:FindFirstChild("HumanoidRootPart")
	if not enemyHRP then return end

	local enemyHumanoid = Enemy:FindFirstChild("Enemy")
	if not enemyHumanoid then return end
	
	enemyHumanoid:MoveTo(Player.Character.HumanoidRootPart.Position)
end

function module.MoveTo(Enemy, Direction, Distance)
	local enemyHRP = Enemy:FindFirstChild("HumanoidRootPart")
	if not enemyHRP then return end

	local enemyHumanoid = Enemy:FindFirstChild("Enemy")
	if not enemyHumanoid then return end

	Direction = string.lower(Direction or "")
	print(Direction)
	if Direction == "front" then
		enemyHumanoid:MoveTo(enemyHRP.Position + enemyHRP.CFrame.LookVector * Distance)
	elseif Direction == "back" then
		enemyHumanoid:MoveTo(enemyHRP.Position - enemyHRP.CFrame.LookVector * Distance)
	elseif Direction == "left" then
		enemyHumanoid:MoveTo(enemyHRP.Position - enemyHRP.CFrame.RightVector * Distance)
	elseif Direction == "right" then
		enemyHumanoid:MoveTo(enemyHRP.Position + enemyHRP.CFrame.RightVector * Distance)
	else
		enemyHumanoid:MoveTo(enemyHRP.Position + enemyHRP.CFrame.LookVector * Distance)
	end
end

function module.DashTo(Enemy, Direction, Distance)
	local enemyHumanoid = Enemy:FindFirstChild("Enemy")
	local enemyHRP = Enemy:FindFirstChild("HumanoidRootPart")
	if not enemyHumanoid or not enemyHRP then return end

	-- Stop any current movement so the dash takes over cleanly
	enemyHumanoid:MoveTo(enemyHRP.Position)

	-- BodyVelocity: forces the HRP to move at a set velocity for a short burst
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(100000, 1, 100000)

	if Direction == "front" then
		bodyVelocity.Velocity = enemyHRP.CFrame.LookVector * Distance
	elseif Direction == "back" then
		bodyVelocity.Velocity = enemyHRP.CFrame.LookVector * -Distance
	elseif Direction == "left" then
		bodyVelocity.Velocity = enemyHRP.CFrame.RightVector * -Distance
	elseif Direction == "right" then
		bodyVelocity.Velocity = enemyHRP.CFrame.RightVector * Distance
	else
		bodyVelocity.Velocity = enemyHRP.CFrame.LookVector * Distance
	end

	bodyVelocity.Parent = enemyHRP

	-- Remove the constraint after a short dash duration
	task.delay(0.35, function()
		bodyVelocity:Destroy()
	end)
end

return module
