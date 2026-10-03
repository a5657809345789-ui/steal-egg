local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local P = Players.LocalPlayer
local PG = P:WaitForChild("PlayerGui")

-- ============================================
-- HAPUS GUI LAMA
-- ============================================
local old = PG:FindFirstChild("MadHubUI")
if old then old:Destroy() end

-- ============================================
-- CONFIG
-- ============================================
local CONFIG = {
    autoSteal = false,
    antiRagdoll = false,
    speedBoost = false,
    freezeGuard = false,
    speedValue = 100,
    basePosition = Vector3.new(0, 10, 0),
}

local char = P.Character or P.CharacterAdded:Wait()

-- ============================================
-- GUI UTAMA
-- ============================================
local GUI = Instance.new("ScreenGui")
GUI.Name = "MadHubUI"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = PG

local Main = Instance.new("CanvasGroup")
Main.AnchorPoint = Vector2.new(.5, .5)
Main.Position = UDim2.fromScale(.5, .5)
Main.Size = UDim2.fromOffset(500, 380)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.GroupTransparency = 1
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", Main)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(220, 38, 44)
stroke.Thickness = 2

local scale = Instance.new("UIScale", Main)
scale.Scale = .92

-- ============================================
-- HEADER
-- ============================================
local Header = Instance.new("Frame", Main)
Header.Position = UDim2.fromOffset(24, 18)
Header.Size = UDim2.new(1, -72, 0, 46)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(.58, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.RichText = true
Title.Text = '<font color="rgb(220,38,44)">MAD</font> <font color="rgb(255,255,255)">HUB</font>'
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 23
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left

local Divider = Instance.new("Frame", Header)
Divider.AnchorPoint = Vector2.new(.5, .5)
Divider.Position = UDim2.new(.59, 0, .5, 0)
Divider.Size = UDim2.fromOffset(2, 29)
Divider.BackgroundColor3 = Color3.fromRGB(220, 38, 44)
Divider.BorderSizePixel = 0

local Updated = Instance.new("TextLabel", Header)
Updated.Position = UDim2.new(.62, 0, 0, 0)
Updated.Size = UDim2.new(.38, 0, 1, 0)
Updated.BackgroundTransparency = 1
Updated.Text = "UPDATED!!!"
Updated.TextColor3 = Color3.new(1, 1, 1)
Updated.Font = Enum.Font.GothamBlack
Updated.TextSize = 19
Updated.TextXAlignment = Enum.TextXAlignment.Center

local Close = Instance.new("TextButton", Main)
Close.AnchorPoint = Vector2.new(1, 0)
Close.Position = UDim2.new(1, -10, 0, 10)
Close.Size = UDim2.fromOffset(30, 30)
Close.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
Close.BorderSizePixel = 0
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(220, 220, 225)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 11
Close.AutoButtonColor = false
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local Rail = Instance.new("Frame", Main)
Rail.Position = UDim2.fromOffset(24, 67)
Rail.Size = UDim2.new(1, -48, 0, 2)
Rail.BackgroundColor3 = Color3.fromRGB(220, 38, 44)
Rail.BorderSizePixel = 0

-- ============================================
-- DESKRIPSI
-- ============================================
local Desc = Instance.new("TextLabel", Main)
Desc.Position = UDim2.fromOffset(28, 78)
Desc.Size = UDim2.new(1, -56, 0, 25)
Desc.BackgroundTransparency = 1
Desc.Text = "Steal An Egg - Auto Features"
Desc.TextColor3 = Color3.fromRGB(178, 175, 185)
Desc.Font = Enum.Font.GothamMedium
Desc.TextSize = 13
Desc.TextXAlignment = Enum.TextXAlignment.Center

-- ============================================
-- FUNGSI BUAT TOMBOL TOGGLE
-- ============================================
local function createToggle(name, yPos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.fromOffset(430, 42)
    btn.Position = UDim2.fromOffset(35, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.BorderSizePixel = 0
    btn.Text = name .. " : OFF"
    btn.TextColor3 = Color3.fromRGB(220, 220, 225)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.AutoButtonColor = false
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local state = false
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(25, 145, 105)
            btn.Text = name .. " : ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
            btn.Text = name .. " : OFF"
        end
        callback(state)
    end)
    
    return btn
end

-- ============================================
-- TOMBOL FITUR
-- ============================================
createToggle("🎯 Auto Steal", 110, function(s) CONFIG.autoSteal = s end)
createToggle("❄️ Freeze Guard", 158, function(s) CONFIG.freezeGuard = s end)
createToggle("🛡️ Anti Ragdoll", 206, function(s) CONFIG.antiRagdoll = s end)
createToggle("⚡ Speed Boost", 254, function(s)
    CONFIG.speedBoost = s
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = s and CONFIG.speedValue or 16
    end
end)

-- ============================================
-- TOMBOL SET BASE
-- ============================================
local SetBase = Instance.new("TextButton", Main)
SetBase.Size = UDim2.fromOffset(430, 35)
SetBase.Position = UDim2.fromOffset(35, 302)
SetBase.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
SetBase.BorderSizePixel = 0
SetBase.Text = "📍 Set Base Position"
SetBase.TextColor3 = Color3.new(1, 1, 1)
SetBase.Font = Enum.Font.GothamBold
SetBase.TextSize = 12
SetBase.AutoButtonColor = false
Instance.new("UICorner", SetBase).CornerRadius = UDim.new(0, 10)

SetBase.MouseButton1Click:Connect(function()
    if char and char:FindFirstChild("HumanoidRootPart") then
        CONFIG.basePosition = char.HumanoidRootPart.Position
        SetBase.Text = "📍 Base Tersimpan!"
        task.wait(1)
        SetBase.Text = "📍 Set Base Position"
    end
end)

-- ============================================
-- CLOSE
-- ============================================
Close.MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

-- ============================================
-- ANIMASI MUNCUL
-- ============================================
TweenService:Create(Main, TweenInfo.new(.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    GroupTransparency = 0
}):Play()

TweenService:Create(scale, TweenInfo.new(.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Scale = 1
}):Play()

-- ============================================
-- FUNGSI: CARI OBJECT
-- ============================================
local function findObject(keyword)
    local found = nil
    local nearestDist = math.huge
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = char.HumanoidRootPart.Position
    
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(keyword) then
            local dist = (obj.Position - myPos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                found = obj
            end
        end
    end
    return found, nearestDist
end

-- ============================================
-- LOOP: ANTI RAGDOLL
-- ============================================
task.spawn(function()
    while task.wait(0.1) do
        if CONFIG.antiRagdoll and char and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
            char.Humanoid.Sit = false
        end
    end
end)

-- ============================================
-- LOOP: AUTO STEAL
-- ============================================
task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.autoSteal and char and char:FindFirstChild("HumanoidRootPart") then
            local egg, dist = findObject("egg")
            if egg then
                char.HumanoidRootPart.CFrame = CFrame.new(egg.Position)
                task.wait(0.15)
                pcall(function()
                    if firetouchinterest then
                        firetouchinterest(char.HumanoidRootPart, egg, 0)
                        task.wait(0.05)
                        firetouchinterest(char.HumanoidRootPart, egg, 1)
                    end
                end)
                task.wait(0.2)
                char.HumanoidRootPart.CFrame = CFrame.new(CONFIG.basePosition)
            end
        end
    end
end)

-- ============================================
-- LOOP: FREEZE GUARD
-- ============================================
local guardData = {}

task.spawn(function()
    while task.wait(0.5) do
        if CONFIG.freezeGuard then
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                    local name = obj.Name:lower()
                    if name:find("guard") or name:find("npc") or name:find("kitsune") or name:find("police") then
                        local humanoid = obj:FindFirstChild("Humanoid")
                        local hrp = obj:FindFirstChild("HumanoidRootPart")
                        if humanoid and hrp then
                            if not guardData[obj] then
                                guardData[obj] = {pos = hrp.CFrame, speed = humanoid.WalkSpeed}
                            end
                            humanoid.WalkSpeed = 0
                            humanoid.JumpPower = 0
                            humanoid.AutoRotate = false
                            hrp.CFrame = guardData[obj].pos
                            hrp.AssemblyLinearVelocity = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end
            end
        else
            for obj, data in pairs(guardData) do
                if obj and obj.Parent and obj:FindFirstChild("Humanoid") then
                    obj.Humanoid.WalkSpeed = data.speed or 16
                    obj.Humanoid.JumpPower = 50
                    obj.Humanoid.AutoRotate = true
                end
            end
            guardData = {}
        end
    end
end)

print("[MAD HUB] Loaded! Fitur siap dipake.")
