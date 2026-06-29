-- === LUXY-STYLE TELEPORT MENU ===
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character, root, humanoid

local PointA = Vector3.new(0, 5, 0)
local PointB = Vector3.new(100, 5, 100)

local godmodeEnabled = false
local flying = false
local flySpeed = 50

local function UpdateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end
UpdateCharacter()
player.CharacterAdded:Connect(UpdateCharacter)

-- Полёт
local bodyVelocity, bodyGyro
local function StartFly()
    if flying or not root then return end
    flying = true
    humanoid.PlatformStand = true
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0,0,0)
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 90000
    bodyGyro.Parent = root
end

local function StopFly()
    if not flying then return end
    flying = false
    humanoid.PlatformStand = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

local function UpdateFly()
    if not flying or not root then return end
    local cam = workspace.CurrentCamera
    local moveDir = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
    
    bodyVelocity.Velocity = moveDir.Unit * flySpeed
    bodyGyro.CFrame = cam.CFrame
end

RunService.RenderStepped:Connect(UpdateFly)

local function TeleportTo(pos)
    if not root then return end
    local old = humanoid and humanoid.Health
    if humanoid then humanoid.Health = math.huge end
    root.CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))
    task.wait(0.2)
    if humanoid and not godmodeEnabled then humanoid.Health = old or 100 end
end

-- GUI (в стиле Luxy Hub)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 780, 0, 520)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Sidebar.Parent = MainFrame

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 70)
Logo.BackgroundTransparency = 1
Logo.Text = "TELEPORT HUB"
Logo.TextColor3 = Color3.fromRGB(0, 170, 255)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold
Logo.Parent = Sidebar

local function AddSidebarBtn(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, 0) -- будет сдвигаться ListLayout
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = Sidebar
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local MainBtn = AddSidebarBtn("Main", function() end)
local PlayerBtn = AddSidebarBtn("Игрок", function() end)
local VisualBtn = AddSidebarBtn("ВХ/ESP", function() end)
local SettingsBtn = AddSidebarBtn("Настройки", function() end)

-- Main Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -190, 1, 0)
Content.Position = UDim2.new(0, 190, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- Функция создания страницы
local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 6
    page.CanvasSize = UDim2.new(0,0,0,800)
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    page.Parent = Content
    return page
end

local PageMain = CreatePage()
local PagePlayer = CreatePage()
local PageVisual = CreatePage()
local PageSettings = CreatePage()

PagePlayer.Visible = false
PageVisual.Visible = false
PageSettings.Visible = false

-- Main Page (Телепорт)
local function AddBigBtn(parent, text, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 60)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 215)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

AddBigBtn(PageMain, "Телепорт в Точку A (F1)", Color3.fromRGB(0, 170, 100), function() TeleportTo(PointA) end)
AddBigBtn(PageMain, "Телепорт в Точку B (F2)", Color3.fromRGB(0, 170, 100), function() TeleportTo(PointB) end)
AddBigBtn(PageMain, "Сохранить A (F3)", Color3.fromRGB(70, 70, 80), function() if root then PointA = root.Position end end)
AddBigBtn(PageMain, "Сохранить B (F4)", Color3.fromRGB(70, 70, 80), function() if root then PointB = root.Position end end)

-- Player Page
AddBigBtn(PagePlayer, "Godmode Вкл/Выкл", Color3.fromRGB(200, 50, 50), function()
    godmodeEnabled = not godmodeEnabled
    if godmodeEnabled then humanoid.MaxHealth = math.huge; humanoid.Health = math.huge
    else humanoid.MaxHealth = 100; humanoid.Health = 100 end
end)

AddBigBtn(PagePlayer, "Полёт Вкл/Выкл (F)", Color3.fromRGB(0, 150, 200), function()
    if flying then StopFly() else StartFly() end
end)

-- Speed & Jump (удобные TextBox)
local function AddSetting(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.35, 0, 1, 0)
    box.Position = UDim2.new(0.65, 0, 0, 0)
    box.Text = tostring(default)
    box.Parent = frame
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function() callback(tonumber(box.Text) or default) end)
end

AddSetting(PagePlayer, "Скорость ходьбы", 16, function(v) if humanoid then humanoid.WalkSpeed = v end end)
AddSetting(PagePlayer, "Сила прыжка", 50, function(v) if humanoid then humanoid.JumpPower = v end end)
AddSetting(PagePlayer, "Скорость полёта", 50, function(v) flySpeed = v end)

-- Visuals
AddBigBtn(PageVisual, "Включить ESP Линии", Color3.fromRGB(100, 100, 200), function() print("ESP Lines ON") end)
AddBigBtn(PageVisual, "Включить ESP Boxes + Имена", Color3.fromRGB(100, 100, 200), function() print("ESP Boxes ON") end)

-- Settings
AddBigBtn(PageSettings, "Скрыть меню", Color3.fromRGB(80, 80, 80), function() MainFrame.Visible = false end)
AddBigBtn(PageSettings, "Случайный цвет темы", Color3.fromRGB(120, 60, 180), function()
    MainFrame.BackgroundColor3 = Color3.fromRGB(math.random(15,35), math.random(15,35), math.random(20,40))
end)

-- Sidebar Navigation
MainBtn.MouseButton1Click:Connect(function() PageMain.Visible = true; PagePlayer.Visible = false; PageVisual.Visible = false; PageSettings.Visible = false end)
PlayerBtn.MouseButton1Click:Connect(function() PageMain.Visible = false; PagePlayer.Visible = true; PageVisual.Visible = false; PageSettings.Visible = false end)
VisualBtn.MouseButton1Click:Connect(function() PageMain.Visible = false; PagePlayer.Visible = false; PageVisual.Visible = true; PageSettings.Visible = false end)
SettingsBtn.MouseButton1Click:Connect(function() PageMain.Visible = false; PagePlayer.Visible = false; PageVisual.Visible = false; PageSettings.Visible = true end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F5 then MainFrame.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.F then
        if flying then StopFly() else StartFly() end
    elseif input.KeyCode == Enum.KeyCode.F1 then TeleportTo(PointA)
    elseif input.KeyCode == Enum.KeyCode.F2 then TeleportTo(PointB)
    elseif input.KeyCode == Enum.KeyCode.F3 and root then PointA = root.Position
    elseif input.KeyCode == Enum.KeyCode.F4 and root then PointB = root.Position
    end
end)

print("✅ Luxy-style меню загружено! F5 - открыть/закрыть | F - полёт")
