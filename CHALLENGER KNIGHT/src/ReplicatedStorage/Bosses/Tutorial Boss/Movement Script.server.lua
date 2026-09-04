local MovementModule = require(game:GetService("ReplicatedStorage").Modules.EnemyMovementModule)
local Boss = script.Parent
local Players = game:GetService("Players")
local MovementStatus = Boss.Enemy.CurrentStatus
wait(4)
while wait() do
	if Players:GetPlayers() then
		local Player = Players:GetPlayers()[1]
		if Player then
			MovementModule.MoveToPlayer(Boss, Player)
			if MovementStatus.Value == "Offensive" then
				Boss.Enemy.WalkSpeed = 3
			else
				Boss.Enemy.WalkSpeed = 16
			end
		end
	end
end