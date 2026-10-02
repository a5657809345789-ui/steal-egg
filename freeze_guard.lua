--========================================================--
--                 FREEZE GUARD - SCRIPT                  --
--            Roblox Studio / Game Milik Sendiri          --
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--========================================================--
-- CONFIG
--========================================================--

local CONFIG = {
    Enabled = false,
    Range = 50,
    ScanInterval = 2,
    DefaultWalkSpeed = 16,
    AutoScan = true,
}

--========================================================--
-- CHARACTER
--========================================================--

local character
local rootPart

local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    rootPart = character:WaitForChild("HumanoidRootPart")
end

updateCharacter()

player.CharacterAdded:Connect(function()
    task.wait(1)
    updateCharacter()
end)

--========================================================--
-- GUARD DATA
--========================================================--

local guardData = {}
local lastScan = 0

local function isGuard(model)
    if not model:IsA("Model") then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")

    if not humanoid or not hrp then
        return false
    end

    local name = model.Name:lower()

    return (
        name:find("guard")
        or name:find("npc")
        or name:find("kitsune")
        or name:find("police")
    )
end

--========================================================--
-- SCAN
--========================================================--

local function scanGuards()
    if not rootPart then
        return 0
    end

    local newData = {}
    local found = 0

    for _, obj in ipairs(workspace:GetDescendants()) do
        if isGuard(obj) then

            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")

            if humanoid and hrp then

                local distance =
                    (hrp.Position - rootPart.Position).Magnitude

                if distance <= CONFIG.Range then

                    local oldData = guardData[obj]

                    newData[obj] = oldData or {
                        Model = obj,
                        Humanoid = humanoid,
                        RootPart = hrp,

                        -- Simpan posisi + rotasi
                        OriginalCFrame = hrp.CFrame,

                        OriginalWalkSpeed = humanoid.WalkSpeed,
                        OriginalJumpPower = humanoid.JumpPower,
                        OriginalAutoRotate = humanoid.AutoRotate,

                        Frozen = false
                    }

                    found += 1
                end
            end
        end
    end

    guardData = newData

    return found
end

--========================================================--
-- FREEZE
--========================================================--

local function freezeGuard(data)

    if not data then
        return
    end

    local model = data.Model
    local humanoid = data.Humanoid
    local hrp = data.RootPart

    if not model or not model.Parent then
        return
    end

    if not humanoid or not humanoid.Parent then
        return
    end

    if not hrp or not hrp.Parent then
        return
    end

    -- Stop movement
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.AutoRotate = false

    -- Kembalikan posisi + rotasi awal
    hrp.CFrame = data.OriginalCFrame

    -- Hapus momentum
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    data.Frozen = true
end

--========================================================--
-- UNFREEZE
--========================================================--

local function unfreezeGuard(data)

    if not data then
        return
    end

    local model = data.Model
    local humanoid = data.Humanoid

    if not model or not model.Parent then
        return
    end

    if not humanoid or not humanoid.Parent then
        return
    end

    humanoid.WalkSpeed =
        data.OriginalWalkSpeed
        or CONFIG.DefaultWalkSpeed

    humanoid.JumpPower =
        data.OriginalJumpPower
        or 50

    humanoid.AutoRotate =
        data.OriginalAutoRotate ~= false

    data.Frozen = false
end

local function freezeAll()

    for _, data in pairs(guardData) do
        freezeGuard(data)
    end

end

local function unfreezeAll()

    for _, data in pairs(guardData) do
        unfreezeGuard(data)
    end

end

--========================================================--
-- GUI
--========================================================--

local gui = Instance.new("ScreenGui")

gui.Name = "FreezeGuardGUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

--========================================================--
-- MAIN WINDOW
--========================================================--

local main = Instance.new("Frame")

main.Name = "Main"
main.Size = UDim2.fromOffset(280, 230)
main.Position = UDim2.new(0, 25, 0.5, -115)

main.BackgroundColor3 =
    Color3.fromRGB(18, 20, 27)

main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 70, 90)
mainStroke.Thickness = 1
mainStroke.Transparency = 0.25
mainStroke.Parent = main

--========================================================--
-- HEADER
--========================================================--

local header = Instance.new("Frame")

header.Size = UDim2.new(1, 0, 0, 55)
header.BackgroundColor3 =
    Color3.fromRGB(28, 34, 46)

header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

local title = Instance.new("TextLabel")

title.Size = UDim2.new(1, -60, 0, 28)
title.Position = UDim2.fromOffset(15, 7)

title.BackgroundTransparency = 1

title.Text = "❄  FREEZE GUARD"

title.TextColor3 =
    Color3.fromRGB(235, 242, 255)

title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")

subtitle.Size = UDim2.new(1, -60, 0, 18)
subtitle.Position = UDim2.fromOffset(16, 32)

subtitle.BackgroundTransparency = 1

subtitle.Text = "Guard Control System"

subtitle.TextColor3 =
    Color3.fromRGB(145, 155, 175)

subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left

subtitle.Parent = header

--========================================================--
-- CLOSE BUTTON
--========================================================--

local closeButton = Instance.new("TextButton")

closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Position = UDim2.new(1, -42, 0, 11)

closeButton.BackgroundColor3 =
    Color3.fromRGB(55, 60, 72)

closeButton.Text = "×"

closeButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold

closeButton.BorderSizePixel = 0
closeButton.AutoButtonColor = false

closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

--========================================================--
-- STATUS
--========================================================--

local status = Instance.new("TextLabel")

status.Size = UDim2.new(1, -30, 0, 25)
status.Position = UDim2.fromOffset(15, 65)

status.BackgroundTransparency = 1

status.Text = "●  STATUS : OFFLINE"

status.TextColor3 =
    Color3.fromRGB(150, 155, 165)

status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.TextXAlignment = Enum.TextXAlignment.Left

status.Parent = main

--========================================================--
-- FREEZE BUTTON
--========================================================--

local freezeButton = Instance.new("TextButton")

freezeButton.Size = UDim2.new(1, -30, 0, 45)
freezeButton.Position = UDim2.fromOffset(15, 92)

freezeButton.BackgroundColor3 =
    Color3.fromRGB(45, 49, 60)

freezeButton.Text = "FREEZE : OFF"

freezeButton.TextColor3 =
    Color3.fromRGB(235, 238, 245)

freezeButton.Font = Enum.Font.GothamBold
freezeButton.TextSize = 13

freezeButton.BorderSizePixel = 0
freezeButton.AutoButtonColor = false

freezeButton.Parent = main

local freezeCorner = Instance.new("UICorner")
freezeCorner.CornerRadius = UDim.new(0, 9)
freezeCorner.Parent = freezeButton

--========================================================--
-- SCAN BUTTON
--========================================================--

local scanButton = Instance.new("TextButton")

scanButton.Size =
    UDim2.new(0.48, -7, 0, 38)

scanButton.Position =
    UDim2.fromOffset(15, 148)

scanButton.BackgroundColor3 =
    Color3.fromRGB(35, 95, 160)

scanButton.Text = "SCAN GUARD"

scanButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

scanButton.Font = Enum.Font.GothamBold
scanButton.TextSize = 11

scanButton.BorderSizePixel = 0
scanButton.AutoButtonColor = false

scanButton.Parent = main

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 8)
scanCorner.Parent = scanButton

--========================================================--
-- RESET BUTTON
--========================================================--

local resetButton = Instance.new("TextButton")

resetButton.Size =
    UDim2.new(0.48, -7, 0, 38)

resetButton.Position =
    UDim2.new(0.52, 0, 0, 148)

resetButton.BackgroundColor3 =
    Color3.fromRGB(75, 78, 88)

resetButton.Text = "RESET"

resetButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 11

resetButton.BorderSizePixel = 0
resetButton.AutoButtonColor = false

resetButton.Parent = main

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetButton

--========================================================--
-- COUNTER
--========================================================--

local counter = Instance.new("TextLabel")

counter.Size =
    UDim2.new(1, -30, 0, 25)

counter.Position =
    UDim2.fromOffset(15, 195)

counter.BackgroundTransparency = 1

counter.Text = "Guards detected: 0"

counter.TextColor3 =
    Color3.fromRGB(130, 140, 160)

counter.Font = Enum.Font.Gotham
counter.TextSize = 10

counter.TextXAlignment =
    Enum.TextXAlignment.Left

counter.Parent = main

--========================================================--
-- OPEN BUTTON
--========================================================--

local openButton = Instance.new("TextButton")

openButton.Name = "OpenButton"

openButton.Size =
    UDim2.fromOffset(48, 48)

openButton.Position =
    UDim2.new(0, 20, 0.5, -24)

openButton.BackgroundColor3 =
    Color3.fromRGB(28, 34, 46)

openButton.Text = "❄"

openButton.TextColor3 =
    Color3.fromRGB(220, 240, 255)

openButton.TextSize = 22
openButton.Font = Enum.Font.GothamBold

openButton.BorderSizePixel = 0
openButton.Visible = false

openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")

openStroke.Color =
    Color3.fromRGB(70, 130, 200)

openStroke.Thickness = 1

openStroke.Parent = openButton

--========================================================--
-- UPDATE GUI
--========================================================--

local function updateGUI()

    local count = 0

    for _ in pairs(guardData) do
        count += 1
    end

    counter.Text =
        "Guards detected: " .. count

    if CONFIG.Enabled then

        freezeButton.Text =
            "❄  FREEZE : ON"

        freezeButton.BackgroundColor3 =
            Color3.fromRGB(25, 145, 105)

        status.Text =
            "●  STATUS : FROZEN"

        status.TextColor3 =
            Color3.fromRGB(75, 220, 165)

    else

        freezeButton.Text =
            "FREEZE : OFF"

        freezeButton.BackgroundColor3 =
            Color3.fromRGB(45, 49, 60)

        status.Text =
            "●  STATUS : OFFLINE"

        status.TextColor3 =
            Color3.fromRGB(150, 155, 165)

    end

end

--========================================================--
-- OPEN / CLOSE
--========================================================--

closeButton.MouseButton1Click:Connect(function()

    main.Visible = false
    openButton.Visible = true

end)

openButton.MouseButton1Click:Connect(function()

    main.Visible = true
    openButton.Visible = false

end)

--========================================================--
-- FREEZE / UNFREEZE
--========================================================--

freezeButton.MouseButton1Click:Connect(function()

    CONFIG.Enabled = not CONFIG.Enabled

    if CONFIG.Enabled then

        scanGuards()
        freezeAll()

    else

        unfreezeAll()

    end

    updateGUI()

end)

--========================================================--
-- SCAN
--========================================================--

scanButton.MouseButton1Click:Connect(function()

    scanButton.Text = "SCANNING..."

    local count = scanGuards()

    if CONFIG.Enabled then
        freezeAll()
    end

    updateGUI()

    task.wait(0.25)

    scanButton.Text = "SCAN GUARD"

    print("[FREEZE GUARD] Found:", count)

end)

--========================================================--
-- RESET
--========================================================--

resetButton.MouseButton1Click:Connect(function()

    CONFIG.Enabled = false

    unfreezeAll()

    guardData = {}

    updateGUI()

end)

--========================================================--
-- DRAG GUI
--========================================================--

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true

        dragStart = input.Position
        startPosition = main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

RunService.RenderStepped:Connect(function()

    if dragging and dragStart then

        local mouseLocation =
            UserInputService:GetMouseLocation()

        local delta =
            Vector2.new(
                mouseLocation.X,
                mouseLocation.Y
            ) - dragStart

        main.Position =
            UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )

    end

end)

--========================================================--
-- MAIN LOOP
--========================================================--

task.spawn(function()

    while task.wait(0.25) do

        if CONFIG.Enabled then

            if CONFIG.AutoScan
                and os.clock() - lastScan
                >= CONFIG.ScanInterval then

                lastScan = os.clock()

                scanGuards()

                updateGUI()

            end

            -- Unlimited freeze
            freezeAll()

        end

    end

end)

--========================================================--
-- START
--========================================================--

updateGUI()

print("================================")
print("       FREEZE GUARD READY")
print("================================")
print("Freeze    : Unlimited")
print("Auto Scan :", CONFIG.AutoScan)
print("Range     :", CONFIG.Range)
print("================================")
