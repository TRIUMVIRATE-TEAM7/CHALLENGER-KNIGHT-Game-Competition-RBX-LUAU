local module = {}

function module.Sound(soundId, Parent, Volume) 
	local Parent = Parent or game:GetService("SoundService")
	local Sound = Instance.new("Sound")
	Sound.SoundId = `rbxassetid://{soundId}`
	Sound.Volume = Volume
	Sound.Parent = Parent
	Sound.PlayOnRemove = true
	Sound:Destroy()
end

function module.SoundWarnAttack(Parent, Volume)
	local Parent = Parent or game:GetService("SoundService")
	local Sound = Instance.new("Sound")
	Sound.SoundId = `rbxassetid://103928210934401`
	Sound.Volume = Volume
	Sound.Parent = Parent
	Sound.PlayOnRemove = true
	Sound:Destroy()
end

function module.BossMusic(soundID, Volume, StartAt)
	local Sound = game.Workspace["Boss Music"]
	Sound.SoundId = `rbxassetid://{soundID}`
	Sound.Volume = Volume
	if StartAt then
		game.Workspace["Boss Music"].TimePosition = StartAt
	end
	Sound:Play()
end

return module
