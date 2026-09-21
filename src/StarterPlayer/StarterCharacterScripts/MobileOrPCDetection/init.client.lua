local UIS = game:GetService("UserInputService")
local isPC = UIS.KeyboardEnabled or UIS.MouseEnabled
local isMobile = UIS.TouchEnabled and not (UIS.KeyboardEnabled or UIS.MouseEnabled)

if isPC then  --
	script.UserInputListener.Enabled = true
elseif isMobile then
	script.UserInputListenerMobile.Enabled = true
end
