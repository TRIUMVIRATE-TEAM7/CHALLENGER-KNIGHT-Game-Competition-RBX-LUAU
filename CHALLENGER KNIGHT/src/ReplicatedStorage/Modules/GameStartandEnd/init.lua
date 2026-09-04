local module = {}

local RemoteEventFolder = game:GetService("ReplicatedStorage").RemoteEvents
local PlayerGUIBossUIEvent = RemoteEventFolder.PlayerGUIinteractionEvents.BossFight
local GameOverModule = require(game:GetService("ReplicatedStorage").Modules.GameOver)
local PointListener = RemoteEventFolder.PlayerCombatEvents.PointChangeEvent

function module.StartTheGame(Player, Difficulty, Enemy)
	print("Start the game")
	for i, v in pairs(script.Maps:GetChildren()) do
		if v.Name == Difficulty then
			local Map = v:Clone()
			Map.Parent = game.Workspace.Map
			
			local PlayerSpawn = Map:FindFirstChild("PlayerSpawn")
			PlayerSpawn.Parent = workspace.Map
			Player.Character.PrimaryPart.CFrame = PlayerSpawn.CFrame
			PlayerSpawn:Destroy()
			
			local EnemySpawn = Map:FindFirstChild("EnemySpawn")
			EnemySpawn.Parent = workspace.Map
			local Enemy = Enemy
			local EnemyHumanoid = Enemy:FindFirstChildOfClass("Humanoid")
			local EnemyHP = EnemyHumanoid.Health
			local EnemyMaxHP = EnemyHumanoid.MaxHealth
			
			Enemy.Parent = workspace
			Enemy.PrimaryPart.CFrame = EnemySpawn.CFrame
			EnemySpawn:Destroy()
			
			PlayerGUIBossUIEvent:FireClient(Player, "gameStartingSetup", EnemyHP, EnemyMaxHP, Enemy.Name)
			
			local PlayerScore = 0
		
			PointListener.OnInvoke = function(Player, Points)
				PlayerScore += Points
				print(PlayerScore)
			end
			
			EnemyHumanoid.Died:Connect(function()
				RemoteEventFolder.PlayerGUIinteractionEvents.PlayerGuiCommunicator:FireClient(Player, "End", PlayerScore)
				Map:Destroy()
				Enemy:Destroy()
			end)
		end
	end
	
end

return module
