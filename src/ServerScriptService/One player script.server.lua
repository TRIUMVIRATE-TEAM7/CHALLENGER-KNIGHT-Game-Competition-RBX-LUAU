local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	if #Players:GetPlayers() > 1 then
		player:Kick("This server is full. Please join another server.")
	end
end)