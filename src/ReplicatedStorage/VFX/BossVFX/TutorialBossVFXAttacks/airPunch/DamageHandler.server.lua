local Part = script.Parent
local Players = game:GetService("Players")

local DamageModule = require(game:GetService("ReplicatedStorage").Modules.PlayerHitModule)
local Damage = 10
local DamageActivated = false

Part.Touched:Connect(function(hit)
	if hit.Parent:FindFirstChild("Humanoid") and DamageActivated == false then
		DamageActivated = true
		local Player = Players:GetPlayerFromCharacter(hit.Parent)
		DamageModule.PlayerIsHit(Player, Damage)
	end
end)

while wait(0.01) do
	Part.Attachment.Charge:Emit(1)
end