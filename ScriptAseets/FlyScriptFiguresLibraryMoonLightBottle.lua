The issue is AlignOrientation is rotating the root part to match the camera, which also affects movement direction. Remove ao entirely and just use a BodyGyro to keep the player upright:
FLYING = false
QEfly = true
iyflyspeed = 0.4
vehicleflyspeed = 1
local vfly = false
local Players = game.Players
local RunService = game:GetService("RunService")
local MainUI_upvr = nil
local TweenService_upvr = game:GetService("TweenService")
local soundNew = Instance.new("Sound",workspace)
soundNew.Name = "_ThunderStrikeGD"
soundNew.SoundId = "rbxassetid://1079408535"
local soundNew2 = Instance.new("Sound",workspace)
soundNew2.Name = "_ThunderStrikeGD2"
soundNew2.SoundId = "rbxassetid://5822757538"
local gdPossess = nil
if game.GameId == 6627207668 then
	gdPossess = script.GuidingLightStuff:Clone()
else
	gdPossess = game:GetObjects("rbxassetid://107690853507208")[1]
end
gdPossess.LockedToPart = true
if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainUI") then repeat wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("MainUI") end
MainUI_upvr = game.Players.LocalPlayer.PlayerGui.MainUI

local mobileUp = false
local mobileDown = false

local function createMobileButton(text, pos, onDown, onUp)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 0, 60)
	btn.Position = pos
	btn.Text = text
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
	btn.BackgroundTransparency = 0.4
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamBold
	btn.Parent = game.Players.LocalPlayer.PlayerGui
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0.3, 0)
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then onDown() end
	end)
	btn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.Touch then onUp() end
	end)
	return btn
end

local upBtn = createMobileButton("▲", UDim2.new(1, -140, 1, -200),
	function() mobileUp = true end,
	function() mobileUp = false end
)
local downBtn = createMobileButton("▼", UDim2.new(1, -140, 1, -130),
	function() mobileDown = true end,
	function() mobileDown = false end
)

function getRoot(PlayerChar)
	if PlayerChar == nil then
		PlayerChar = game.Players.LocalPlayer.Character
	end
	if not PlayerChar:FindFirstChild("HumanoidRootPart") then
		return PlayerChar.PrimaryPart
	else
		return PlayerChar.HumanoidRootPart
	end
end

local IYMouse = game.Players.LocalPlayer:GetMouse()
local controlModule = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

spawn(function()
	wait(2)
	soundNew2:Play()
	local newColorEcction = Instance.new("ColorCorrectionEffect",game.Lighting)
	TweenService_upvr:Create(newColorEcction, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Brightness = 0.3,
		TintColor = Color3.fromRGB(102, 255, 255)
	}):Play()
	wait(4.5)
	newColorEcction:Destroy()
	soundNew2:Destroy()
	soundNew:Play()
	spawn(function()
		wait(6)
		soundNew:Destroy()
	end)
	gdPossess.Parent = getRoot()
	flyR()
end)

function flyR()
	repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

	local T = getRoot(Players.LocalPlayer.Character)
	local camera = workspace.CurrentCamera
	local hoverY = nil

	local att = Instance.new("Attachment")
	att.Name = "FlyAttachment"
	att.Parent = T

	local lv = Instance.new("LinearVelocity")
	lv.Name = "FlyVelocity"
	lv.Attachment0 = att
	lv.MaxForce = math.huge
	lv.VectorVelocity = Vector3.new(0, 0, 0)
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Parent = T

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.P = 9e4
	bg.CFrame = T.CFrame
	bg.Parent = T

	FLYING = true

	local mfly = RunService.RenderStepped:Connect(function()
		local root = getRoot(Players.LocalPlayer.Character)
		if not root then return end

		local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.PlatformStand = false end

		bg.CFrame = CFrame.new(root.Position)

		local dir = controlModule:GetMoveVector()
		local move = (camera.CFrame.RightVector * dir.X) + (camera.CFrame.LookVector * -dir.Z)
		move = Vector3.new(move.X, 0, move.Z)

		local mobileQ = mobileUp and (vfly and vehicleflyspeed or iyflyspeed)*2 or 0
		local mobileE = mobileDown and -(vfly and vehicleflyspeed or iyflyspeed)*2 or 0
		local verticalInput = mobileQ + mobileE

		lv.MaxForce = math.huge

		if move.Magnitude > 0 or verticalInput ~= 0 then
			hoverY = root.Position.Y
			local flatMove = move.Magnitude > 0 and move.Unit or Vector3.new(0,0,0)
			lv.VectorVelocity = (flatMove * (iyflyspeed * 50)) + Vector3.new(0, verticalInput * 50, 0)
		else
			if not hoverY then hoverY = root.Position.Y end
			local yCorrection = (hoverY - root.Position.Y) * 10
			lv.VectorVelocity = Vector3.new(0, yCorrection, 0)
		end
	end)

	wait(25)

	mfly:Disconnect()
	FLYING = false

	if MainUI_upvr.MainFrame.Healthbar.Effects:FindFirstChild("GuidingLightPotion") then
		MainUI_upvr.MainFrame.Healthbar.Effects:WaitForChild("GuidingLightPotion"):Destroy()
	end

	local humanoid = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.PlatformStand = false end

	lv:Destroy()
	bg:Destroy()
	att:Destroy()
	upBtn:Destroy()
	downBtn:Destroy()
	gdPossess:Destroy()
	script:Destroy()
end
