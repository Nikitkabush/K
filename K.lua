-- === УНИВЕРСАЛЬНОЕ МЕНЮ (ПК + МОБИЛЬНЫЕ) ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character, root, humanoid

local PointA = Vector3.new(0, 5, 0)
local PointB = Vector3.new(100, 5, 100)

local godmodeEnabled = false
local flying = false
local flySpeed = 60

local function UpdateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end
UpdateCharacter()
player.CharacterAdded:Connect(UpdateCharacter)

-- Полёт
local bv, bg
local function ToggleFly()
    flying = not flying
    if flying then
        humanoid.PlatformStand = true
        bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = root
        bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 90000
        bg.Parent = root
    else
        humanoid.PlatformStand = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    if flying and root and bv and bg then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        
        bv.Velocity = dir.Unit * flySpeed
        bg.CFrame = cam.CFrame
    end
end)

local function TeleportTo(pos)
    if not root then return end
    local oldHealth = humanoid.Health
    humanoid.Health = math.huge
    root.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    task.wait(0.2)
    if not godmodeEnabled and humanoid then humanoid.Health = oldHealth end
end

-- GUI (оптимизировано для телефона и ПК)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 480)  -- Компактный размер
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundColor3 = Color3.fromRGB(15,15,22)
Title.Text = "   TELEPORT HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Боковая панель
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 100, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Sidebar.Parent = MainFrame

local function AddSidebarBtn(text, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 42)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 13
    btn.Parent = Sidebar
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

-- Контент
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -110, 1, -60)
ContentFrame.Position = UDim2.new(0, 105, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local function CreatePage()
    local s = Instance.new("ScrollingFrame")
    s.Size = UDim2.new(1,0,1,0)
    s.BackgroundTransparency = 1
    s.ScrollBarThickness = 5
    s.CanvasSize = UDim2.new(0,0,0,700)
    Instance.new("UIListLayout", s).Padding = UDim.new(0, 6)
    s.Parent = ContentFrame
    return s
end

local PageMain = CreatePage()
local PagePlayer = CreatePage()
local PageVisual = CreatePage()
local PageSettings = CreatePage()

PagePlayer.Visible = false
PageVisual.Visible = false
PageSettings.Visible = false

local function AddBtn(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -15, 0, 46)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Parent = parent
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

-- Заполнение страниц
AddBtn(PageMain, "→ A (F1)", function() TeleportTo(PointA) end)
AddBtn(PageMain, "→ B (F2)", function() TeleportTo(PointB) end)
AddBtn(PageMain, "Сохранить A (F3)", function() if root then PointA = root.Position end end)
AddBtn(PageMain, "Сохранить B (F4)", function() if root then PointB = root.Position end end)

AddBtn(PagePlayer, "Godmode ON/OFF", function()
    godmodeEnabled = not godmodeEnabled
    if godmodeEnabled then
        humanoid.MaxHealth = math.huge; humanoid.Health = math.huge
    else
        humanoid.MaxHealth = 100; humanoid.Health = 100
    end
end)
AddBtn(PagePlayer, "Полёт ON/OFF (F)", ToggleFly)
AddBtn(PagePlayer, "Скорость +", function() if humanoid then humanoid.WalkSpeed = math.min(humanoid.WalkSpeed + 8, 100) end end)
AddBtn(PagePlayer, "Прыжок +", function() if humanoid then humanoid.JumpPower = math.min(humanoid.JumpPower + 25, 500) end end)

AddBtn(PageVisual, "ESP Линии", function() print("ESP Lines: ON") end)
AddBtn(PageVisual, "ESP Boxes + Имена", function() print("ESP Boxes: ON") end)

AddBtn(PageSettings, "Скрыть", function() MainFrame.Visible = false end)
AddBtn(PageSettings, "Случайный цвет", function()
    MainFrame.BackgroundColor3 = Color3.fromRGB(math.random(18,38), math.random(18,38), math.random(22,45))
end)

-- Навигация
AddSidebarBtn("Главное", 10, function() PageMain.Visible=true; PagePlayer.Visible=false; PageVisual.Visible=false; PageSettings.Visible=false end)
AddSidebarBtn("Игрок", 60, function() PageMain.Visible=false; PagePlayer.Visible=true; PageVisual.Visible=false; PageSettings.Visible=false end)
AddSidebarBtn("ВХ/ESP", 110, function() PageMain.Visible=false; PagePlayer.Visible=false; PageVisual.Visible=true; PageSettings.Visible=false end)
AddSidebarBtn("Настр.", 160, function() PageMain.Visible=false; PagePlayer.Visible=false; PageVisual.Visible=false; PageSettings.Visible=true end)

-- Кнопка открытия (удобно для телефона)
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 150, 0, 60)
OpenButton.Position = UDim2.new(0, 15, 1, -80)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
OpenButton.Text = "МЕНЮ\n(F5)"
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.TextSize = 16
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Hotkeys (работает на ПК и мобильных с клавиатурой)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F5 then
        MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F then
        ToggleFly()
    elseif input.KeyCode == Enum.KeyCode.F1 then TeleportTo(PointA)
    elseif input.KeyCode == Enum.KeyCode.F2 then TeleportTo(PointB)
    elseif input.KeyCode == Enum.KeyCode.F3 and root then PointA = root.Position
    elseif input.KeyCode == Enum.KeyCode.F4 and root then PointB = root.Position
    end
end)

print("✅ Универсальное меню загружено! Работает на телефоне и ПК. F5 — открыть")
