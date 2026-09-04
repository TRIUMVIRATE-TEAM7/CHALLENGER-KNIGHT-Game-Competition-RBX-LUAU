local StyleTracker = script.Parent.StyleTracker

local function checkChildrenCount()
	local children = {}
	for _, child in StyleTracker:GetChildren() do
		if child:IsA("TextLabel") then
			table.insert(children, child)
		end
	end
	if #children > 3 then
		children[1]:Destroy()
		print("DESTROYED")
	end
end


StyleTracker.ChildAdded:Connect(function()
	checkChildrenCount()
end)
