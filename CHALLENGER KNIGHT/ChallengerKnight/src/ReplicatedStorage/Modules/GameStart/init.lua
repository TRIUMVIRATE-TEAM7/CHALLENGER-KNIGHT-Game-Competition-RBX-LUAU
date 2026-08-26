local module = {}

function module.StartTheGame(Player, Difficulty)
	print("Start the game")
	for i, v in pairs(script.Maps:GetChildren()) do
		if v.Name == Difficulty then
			v:Clone().Parent = workspace
			local PlayerSpawn = v:WaitForChild("PlayerSpawn"):Clone()
			PlayerSpawn.Parent = workspace.Map
			Player.Character.PrimaryPart.CFrame = PlayerSpawn.CFrame
			PlayerSpawn:Destroy()
			local EnemySpawn = v:WaitForChild("EnemySpawn"):Clone()
			EnemySpawn.Parent = workspace.Map
			local Enemy = game.ReplicatedStorage.Enemies:WaitForChild("Enemy"):Clone()
			Enemy.Parent = workspace
			Enemy.PrimaryPart.CFrame = EnemySpawn.CFrame
			EnemySpawn:Destroy()
		end
	end
	
end

return module
