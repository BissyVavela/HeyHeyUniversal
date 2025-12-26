-- =====================================
-- DEV MENU (ESP, FLY & NOCLIP)
-- =====================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SETTINGS
local ESP_ENABLED = true
local DISTANCE_ENABLED = true
local MAX_ESP_DISTANCE = 300
local MENU_VISIBLE = true
local FLYING = false
local NOCLIP = false -- NIEUWE SETTING
local FLY_SPEED = 50

-- =====================================
-- UI
-- =====================================

local gui = Instance.new("ScreenGui")
gui.Name = "DevESPMenu"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(240, 350) -- Weer iets groter gemaakt
frame.Position = UDim2.fromOffset(20, 200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local function createButton(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.fromOffset(200, 40)
	b.Position = UDim2.fromOffset(20, y)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(240, 40)
title.BackgroundTransparency = 1
title.Text = "DEV MENU V3"
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(255,80,80)

local espBtn = createButton("ESP: ON", 45)
local distBtn = createButton("Distance: ON", 90)
local flyBtn = createButton("Fly: OFF", 135)
local noclipBtn = createButton("NoClip: OFF", 180) -- NIEUWE KNOP

local rangeLabel = Instance.new("TextLabel", frame)
rangeLabel.Size = UDim2.fromOffset(200, 30)
rangeLabel.Position = UDim2.fromOffset(20, 230)
rangeLabel.BackgroundTransparency = 1
rangeLabel.TextColor3 = Color3.fromRGB(200,200,200)
rangeLabel.Font = Enum.Font.Gotham
rangeLabel.TextScaled = true

local minusBtn = createButton("-", 280)
minusBtn.Size = UDim2.fromOffset(90, 35)

local plusBtn = createButton("+", 280)
plusBtn.Size = UDim2.fromOffset(90, 35)
plusBtn.Position = UDim2.fromOffset(130, 280)

-- =====================================
-- NOCLIP LOGIC
-- =====================================

RunService.Stepped:Connect(function()
	if NOCLIP and LocalPlayer.Character then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide == true then
				part.CanCollide = false
			end
		end
	end
end)

-- =====================================
-- FLY LOGIC
-- =====================================

local bodyVelocity, bodyGyro

local function startFlying()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.CFrame = root.CFrame
	bodyGyro.Parent = root

	char:FindFirstChildOfClass("Humanoid").PlatformStand = true

	task.spawn(function()
		while FLYING do
			local moveDir = Vector3.new(0,0,0)
			
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			
			bodyVelocity.Velocity = moveDir * FLY_SPEED
			bodyGyro.CFrame = Camera.CFrame
			RunService.RenderStepped:Wait()
		end
		
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		if char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid").PlatformStand = false
		end
	end)
end

-- =====================================
-- ESP & HELPER FUNCTIONS (Zelfde als voorheen)
-- =====================================

local function getTeamName(player)
	if player:FindFirstChild("leaderstats") then
		local t = player.leaderstats:FindFirstChild("Team")
		if t and t:IsA("StringValue") then return t.Value end
	end
	return player.Team and player.Team.Name or "No Team"
end

local function getWantedStatus(player)
	if getTeamName(player) ~= "Citizen" then return nil end
	if player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Wanted") then
		local w = player.leaderstats.Wanted
		return (w:IsA("BoolValue") and w.Value and "WANTED") or (w:IsA("StringValue") and string.upper(w.Value)) or "CLEAN"
	end
	return "CLEAN"
end

local function getRoleColor(player)
	local role = getTeamName(player)
	if role == "Citizen" then return Color3.fromRGB(80, 150, 255)
	elseif role == "Police" or role == "ADAC" or role == "BusCompany" then return Color3.fromRGB(80, 255, 80) end
	return Color3.fromRGB(255,255,255)
end

local function applyESP(player, character)
	if player == LocalPlayer or not ESP_ENABLED then return end
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if not root then return end

	local highlight = Instance.new("Highlight", character)
	highlight.Name = "PlayerHighlight"
	highlight.FillTransparency = 1
	highlight.OutlineColor = getRoleColor(player)

	local billboard = Instance.new("BillboardGui", root)
	billboard.Name = "ESPBillboard"
	billboard.Size = UDim2.fromOffset(160, 60)
	billboard.AlwaysOnTop = true

	local text = Instance.new("TextLabel", billboard)
	text.Size = UDim2.fromScale(1,1)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold

	RunService.RenderStepped:Connect(function()
		if not character.Parent or not LocalPlayer.Character then return end
		local dist = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		highlight.Enabled = ESP_ENABLED and dist <= MAX_ESP_DISTANCE
		billboard.Enabled = DISTANCE_ENABLED and dist <= MAX_ESP_DISTANCE
		text.Text = player.Name .. "\n[" .. getTeamName(player) .. "]\n" .. math.floor(dist) .. " studs"
		text.TextColor3 = (getWantedStatus(player) == "WANTED") and Color3.fromRGB(255, 80, 80) or getRoleColor(player)
	end)
end

-- =====================================
-- BUTTON CONNECTIONS
-- =====================================

noclipBtn.MouseButton1Click:Connect(function()
	NOCLIP = not NOCLIP
	noclipBtn.Text = "NoClip: " .. (NOCLIP and "ON" or "OFF")
end)

flyBtn.MouseButton1Click:Connect(function()
	FLYING = not FLYING
	flyBtn.Text = "Fly: " .. (FLYING and "ON" or "OFF")
	if FLYING then startFlying() end
end)

espBtn.MouseButton1Click:Connect(function()
	ESP_ENABLED = not ESP_ENABLED
	espBtn.Text = "ESP: " .. (ESP_ENABLED and "ON" or "OFF")
end)

distBtn.MouseButton1Click:Connect(function()
	DISTANCE_ENABLED = not DISTANCE_ENABLED
	distBtn.Text = "Distance: " .. (DISTANCE_ENABLED and "ON" or "OFF")
end)

minusBtn.MouseButton1Click:Connect(function()
	MAX_ESP_DISTANCE = math.max(50, MAX_ESP_DISTANCE - 50)
	rangeLabel.Text = "ESP Range: " .. MAX_ESP_DISTANCE
end)

plusBtn.MouseButton1Click:Connect(function()
	MAX_ESP_DISTANCE = math.min(2000, MAX_ESP_DISTANCE + 50)
	rangeLabel.Text = "ESP Range: " .. MAX_ESP_DISTANCE
end)

rangeLabel.Text = "ESP Range: " .. MAX_ESP_DISTANCE

-- =====================================
-- TOGGLE & SETUP
-- =====================================

UserInputService.InputBegan:Connect(function(input, gp)
	if not gp and input.KeyCode == Enum.KeyCode.RightShift then
		frame.Visible = not frame.Visible
	end
end)

local function onPlayer(player)
	player.CharacterAdded:Connect(function(char) task.wait(1) applyESP(player, char) end)
end

for _, p in ipairs(Players:GetPlayers()) do onPlayer(p) end
Players.PlayerAdded:Connect(onPlayer)

-- Automatische ESP refresh
spawn(function() while true do task.wait(15) for _,p in pairs(Players:GetPlayers()) do if p.Character then applyESP(p, p.Character) end end end end)
