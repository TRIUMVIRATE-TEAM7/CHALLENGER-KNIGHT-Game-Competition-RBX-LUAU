local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEventFolder = game:GetService("ReplicatedStorage").RemoteEvents
--Events
local PlayerHitModule = require(game:GetService("ReplicatedStorage").Modules.PlayerHitModule)
local PlayerGUICommunicatorEvent = RemoteEventFolder.PlayerGUIinteractionEvents.PlayerGuiCommunicator


while wait(1) do
	for i, v in pairs(game.Players:GetPlayers()) do
		if v.Character then
			if v.Character:FindFirstChild("Humanoid") then
				PlayerHitModule.PlayerIsHit(v, 1)
			end
		end
	end
end