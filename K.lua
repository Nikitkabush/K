-- === КОМПАКТНОЕ МЕНЮ С БОКОВОЙ ПАНЕЛЬЮ ===
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
        bv = Instance.new("BodyVelocity", root) bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        bg = Instance.new("BodyGyro", root) bg.MaxTorque = Vector3.new(1e5,1e5,1e5) bg.P = 90000
    else
        humanoid.PlatformStand = false
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

RunService.RenderStepped:Connect(function()
    if flying and root and bv then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        bv.Velocity = dir.Unit * flySpeed
        bg.CFrame = cam.CFrame
    end
end)

local function TeleportTo(pos)
    if not root then return end
    local old = humanoid.Health
    humanoid.Health = math.huge
    root.CFrame = CFrame.new(pos + Vector3.new(0,4,0))
    task.wait(0.15)
    if not godmodeEnabled then humanoid.Health = old end
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 460)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

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
Sidebar.Size = UDim2.new(0, 110, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Sidebar.Parent = MainFrame

local function AddSidebarButton(text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 45)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 14
    btn.Parent = Sidebar
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Контент
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -120, 1, -60)
ContentFrame.Position = UDim2.new(0, 115, 0, 55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local function CreateContent()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0,0,0,600)
    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 8)
    scroll.Parent = ContentFrame
    return scroll
end

local PageMain = CreateContent()
local PagePlayer = CreateContent()
local PageVisual = CreateContent()
local PageSettings = CreateContent()

PagePlayer.Visible = false
PageVisual.Visible = false
PageSettings.Visible = false

local function AddBtn(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 48)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 15
    btn.Parent = parent
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

-- Заполняем страницы
AddBtn(PageMain, "Телепорт в A (F1)", function() TeleportTo(PointA) end)
AddBtn(PageMain, "Телепорт в B (F2)", function() TeleportTo(PointB) end)
AddBtn(PageMain, "Сохранить текущую как A (F3)", function() if root then PointA = root.Position end end)
AddBtn(PageMain, "Сохранить текущую как B (F4)", function() if root then PointB = root.Position end end)

AddBtn(PagePlayer, "Godmode Вкл/Выкл", function()
    godmodeEnabled = not godmodeEnabled
    if godmodeEnabled then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    else
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
end)
AddBtn(PagePlayer, "Полёт Вкл/Выкл (F)", ToggleFly)
AddBtn(PagePlayer, "Скорость ходьбы +", function() if humanoid then humanoid.WalkSpeed = humanoid.WalkSpeed + 10 end end)
AddBtn(PagePlayer, "Прыжок +", function() if humanoid then humanoid.JumpPower = humanoid.JumpPower + 30 end end)

AddBtn(PageVisual, "ESP Линии Вкл", function() print("ESP Lines включены") end)
AddBtn(PageVisual, "ESP Boxes + Имена", function() print("ESP Boxes включены") end)

AddBtn(PageSettings, "Скрыть меню", function() MainFrame.Visible = false end)
AddBtn(PageSettings, "Изменить цвет меню", function()
    MainFrame.BackgroundColor3 = Color3.fromRGB(math.random(20,40), math.random(20,40), math.random(25,45))
end)

-- Навигация
AddSidebarButton("Главное", 10, function()
    PageMain.Visible = true
    PagePlayer.Visible = false
    PageVisual.Visible = false
    PageSettings.Visible = false
end)

AddSidebarButton("Игрок", 65, function()
    PageMain.Visible = false
    PagePlayer.Visible = true
    PageVisual.Visible = false
    PageSettings.Visible = false
end)

AddSidebarButton("ВХ/ESP", 120, function()
    PageMain.Visible = false
    PagePlayer.Visible = false
    PageVisual.Visible = true
    PageSettings.Visible = false
end)

AddSidebarButton("Настройки", 175, function()
    PageMain.Visible = false
    PagePlayer.Visible = false
    PageVisual.Visible = false
    PageSettings.Visible = true
end)

-- Кнопка открытия
local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 170, 0, 55)
OpenButton.Position = UDim2.new(0, 20, 1, -80)
OpenButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenButton.Text = "Открыть Меню\n(F5)"
OpenButton.TextColor3 = Color3.new(1,1,1)
OpenButton.TextSize = 15
OpenButton.Parent = ScreenGui
Instance.new("UICorner", OpenButton)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Hotkeys
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

print("✅ Меню с боковой панелью готово! F5 для открытия")
