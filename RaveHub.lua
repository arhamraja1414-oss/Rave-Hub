-- ██████╗  █████╗ ██╗   ██╗███████╗    ██╗  ██╗██╗   ██╗██████╗ 
-- ██╔══██╗██╔══██╗██║   ██║██╔════╝    ██║  ██║██║   ██║██╔══██╗
-- ██████╔╝███████║██║   ██║█████╗      ███████║██║   ██║██████╔╝
-- ██╔══██╗██╔══██║╚██╗ ██╔╝██╔══╝      ██╔══██║██║   ██║██╔══██╗
-- ██║  ██║██║  ██║ ╚████╔╝ ███████╗    ██║  ██║╚██████╔╝██████╔╝
-- Rave Hub v1.0 | Steal a Brainrot | Dueling Edition

local RaveHub = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    DuelAutoAccept   = false,
    DuelAutoCounter  = false,
    DuelSpeedBoost   = false,
    DuelESP          = false,
    AutoSteal        = false,
    InfiniteJump     = false,
    SpeedValue       = 24,    -- default walk speed
    JumpValue        = 50,    -- default jump power
    Notifications    = true,
}

-- ============================================================
-- UTILITY
-- ============================================================
local function Notify(msg)
    if not Config.Notifications then return end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title   = "Rave Hub",
        Text    = msg,
        Duration = 3,
    })
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- ============================================================
-- GUI BUILDER
-- ============================================================
local function BuildGUI()
    -- Remove old instance if re-executing
    if game.CoreGui:FindFirstChild("RaveHub") then
        game.CoreGui.RaveHub:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RaveHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.CoreGui

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 340, 0, 420)
    Main.Position = UDim2.new(0.5, -170, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = ScreenGui

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

    -- Animated rainbow border
    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(1, 4, 1, 4)
    Border.Position = UDim2.new(0, -2, 0, -2)
    Border.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
    Border.ZIndex = 0
    Border.Parent = Main
    Instance.new("UICorner", Border).CornerRadius = UDim.new(0, 12)

    local hue = 0
    RunService.Heartbeat:Connect(function(dt)
        hue = (hue + dt * 0.3) % 1
        Border.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    end)

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundColor3 = Color3.fromRGB(18, 10, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "⚡ RAVE HUB  |  Steal a Brainrot"
    TitleLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(1, -14, 0, 14)
    SubLabel.Position = UDim2.new(0, 14, 1, 0)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "Dueling Edition v1.0"
    SubLabel.TextColor3 = Color3.fromRGB(120, 80, 180)
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextSize = 11
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = TitleBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 80)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Scroll container for toggles
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -16, 1, -56)
    ScrollFrame.Position = UDim2.new(0, 8, 0, 52)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 3
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 255)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = Main

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.Parent = ScrollFrame

    Instance.new("UIPadding", ScrollFrame).PaddingTop = UDim.new(0, 4)

    -- --------------------------------------------------------
    -- Section Label helper
    -- --------------------------------------------------------
    local function Section(name)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 22)
        lbl.BackgroundTransparency = 1
        lbl.Text = "  " .. name
        lbl.TextColor3 = Color3.fromRGB(160, 100, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = ScrollFrame
    end

    -- --------------------------------------------------------
    -- Toggle helper
    -- --------------------------------------------------------
    local function Toggle(label, configKey, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 38)
        Row.BackgroundColor3 = Color3.fromRGB(22, 14, 38)
        Row.BorderSizePixel = 0
        Row.Parent = ScrollFrame
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -60, 1, 0)
        Lbl.Position = UDim2.new(0, 12, 0, 0)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = label
        Lbl.TextColor3 = Color3.fromRGB(210, 200, 255)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(0, 44, 0, 24)
        ToggleBtn.Position = UDim2.new(1, -54, 0.5, -12)
        ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(120, 40, 220) or Color3.fromRGB(50, 30, 70)
        ToggleBtn.Text = Config[configKey] and "ON" or "OFF"
        ToggleBtn.TextColor3 = Color3.new(1,1,1)
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 11
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Parent = Row
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

        ToggleBtn.MouseButton1Click:Connect(function()
            Config[configKey] = not Config[configKey]
            ToggleBtn.BackgroundColor3 = Config[configKey] and Color3.fromRGB(120, 40, 220) or Color3.fromRGB(50, 30, 70)
            ToggleBtn.Text = Config[configKey] and "ON" or "OFF"
            if callback then callback(Config[configKey]) end
        end)
    end

    -- --------------------------------------------------------
    -- Slider helper
    -- --------------------------------------------------------
    local function Slider(label, configKey, min, max, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 52)
        Row.BackgroundColor3 = Color3.fromRGB(22, 14, 38)
        Row.BorderSizePixel = 0
        Row.Parent = ScrollFrame
        Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 8)

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(0.7, 0, 0, 20)
        Lbl.Position = UDim2.new(0, 12, 0, 6)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = label
        Lbl.TextColor3 = Color3.fromRGB(210, 200, 255)
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local ValLbl = Instance.new("TextLabel")
        ValLbl.Size = UDim2.new(0.3, -12, 0, 20)
        ValLbl.Position = UDim2.new(0.7, 0, 0, 6)
        ValLbl.BackgroundTransparency = 1
        ValLbl.Text = tostring(Config[configKey])
        ValLbl.TextColor3 = Color3.fromRGB(160, 100, 255)
        ValLbl.Font = Enum.Font.GothamBold
        ValLbl.TextSize = 12
        ValLbl.TextXAlignment = Enum.TextXAlignment.Right
        ValLbl.Parent = Row

        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -24, 0, 6)
        Track.Position = UDim2.new(0, 12, 0, 34)
        Track.BackgroundColor3 = Color3.fromRGB(50, 30, 70)
        Track.BorderSizePixel = 0
        Track.Parent = Row
        Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        local pct = (Config[configKey] - min) / (max - min)
        Fill.Size = UDim2.new(pct, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(130, 50, 230)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local Dragging = false
        Track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                rel = math.clamp(rel, 0, 1)
                local val = math.floor(min + rel * (max - min))
                Config[configKey] = val
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                ValLbl.Text = tostring(val)
                if callback then callback(val) end
            end
        end)
    end

    -- ============================================================
    -- SECTIONS & TOGGLES
    -- ============================================================

    Section("⚔️  DUELING")

    Toggle("Auto Accept Duel", "DuelAutoAccept", function(state)
        Notify(state and "Auto Accept: ON" or "Auto Accept: OFF")
    end)

    Toggle("Auto Counter Attack", "DuelAutoCounter", function(state)
        Notify(state and "Auto Counter: ON" or "Auto Counter: OFF")
    end)

    Toggle("Duel Speed Boost", "DuelSpeedBoost", function(state)
        local hum = GetHumanoid()
        if hum then
            hum.WalkSpeed = state and Config.SpeedValue or 16
        end
        Notify(state and "Speed Boost: ON" or "Speed Boost: OFF")
    end)

    Toggle("Duel ESP (Highlight)", "DuelESP", function(state)
        if state then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hl = Instance.new("SelectionBox")
                    hl.Name = "RaveESP"
                    hl.Adornee = plr.Character
                    hl.Color3 = Color3.fromRGB(160, 0, 255)
                    hl.LineThickness = 0.05
                    hl.SurfaceTransparency = 0.7
                    hl.SurfaceColor3 = Color3.fromRGB(100, 0, 200)
                    hl.Parent = plr.Character
                end
            end
            Notify("ESP: ON")
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    local hl = plr.Character:FindFirstChild("RaveESP")
                    if hl then hl:Destroy() end
                end
            end
            Notify("ESP: OFF")
        end
    end)

    Section("🤖  AUTOMATION")

    Toggle("Auto Steal Brainrot", "AutoSteal", function(state)
        Notify(state and "Auto Steal: ON" or "Auto Steal: OFF")
        if state then
            task.spawn(function()
                while Config.AutoSteal do
                    task.wait(0.2)
                    -- Find steal prompts in workspace and trigger them
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and (obj.ActionText == "Steal" or obj.ObjectText:lower():find("brainrot")) then
                            local root = GetRoot()
                            if root then
                                local part = obj.Parent
                                if part and (root.Position - part.Position).Magnitude < 20 then
                                    fireproximityprompt(obj)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    Toggle("Infinite Jump", "InfiniteJump", function(state)
        Notify(state and "Infinite Jump: ON" or "Infinite Jump: OFF")
    end)

    Section("🏃  MOVEMENT")

    Slider("Walk Speed", "SpeedValue", 16, 100, function(val)
        local hum = GetHumanoid()
        if hum and Config.DuelSpeedBoost then hum.WalkSpeed = val end
    end)

    Slider("Jump Power", "JumpValue", 50, 300, function(val)
        local hum = GetHumanoid()
        if hum then hum.JumpPower = val end
    end)

    Section("🔔  MISC")

    Toggle("Notifications", "Notifications", function(state)
        -- no notify since it might be off
    end)

    return ScreenGui
end

-- ============================================================
-- RUNTIME HOOKS
-- ============================================================

-- Infinite Jump hook
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Auto Accept Duel — watches for duel GUI prompts
RunService.Heartbeat:Connect(function()
    if Config.DuelAutoAccept then
        -- Look for accept buttons in PlayerGui
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            for _, obj in pairs(pg:GetDescendants()) do
                if obj:IsA("TextButton") then
                    local t = obj.Text:lower()
                    if t:find("accept") or t:find("duel") then
                        obj.MouseButton1Click:Fire()
                    end
                end
            end
        end
    end
end)

-- Re-apply speed on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Config.DuelSpeedBoost then hum.WalkSpeed = Config.SpeedValue end
        hum.JumpPower = Config.JumpValue
    end
end)

-- ============================================================
-- LAUNCH
-- ============================================================
BuildGUI()
Notify("Rave Hub loaded! Welcome 🎶")
print("[RaveHub] Loaded successfully - Steal a Brainrot Dueling Edition")
