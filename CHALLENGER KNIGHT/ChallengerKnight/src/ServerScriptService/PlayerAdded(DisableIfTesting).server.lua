local Players = game:GetService("Players")
local PlayerScriptsFolder = game:GetService("ReplicatedStorage").PlayerLocalScripts
Players.CharacterAutoLoads = false

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if character then
			local Humanoid = character:WaitForChild("Humanoid")
			local Animator = Humanoid:WaitForChild("Animator")

			local SpawnAnim = Instance.new("Animation")
			SpawnAnim.AnimationId = "rbxassetid://80246302907417"
			local SpawnAnimTrack = Animator:LoadAnimation(SpawnAnim)
			SpawnAnimTrack:Play()
			
			for _, v in pairs(PlayerScriptsFolder:GetChildren()) do
				print(v)
				local ClonedScripts = v:Clone()
				ClonedScripts.Parent = character
				if ClonedScripts:IsA("LocalScript") then
					ClonedScripts.Enabled = true
				end
			end
		end
	end)
	task.wait(5) 
	player:LoadCharacterAsync()
end)