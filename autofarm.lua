--// Load Rayfield UI
loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- GUI Setup
local Window = Rayfield:CreateWindow({
    Name = "Dead Rail - Auto Script Pro",
    LoadingTitle = "Auto Farming System",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "DeadRailFullAuto"
    },
    KeySystem = false,
})

-- Biến toàn cục
getgenv().AutoFarm = false
getgenv().FarmSpeed = 1
getgenv().RemoteEvent = nil
getgenv().AutoUpgrade = false
getgenv().UpgradeRemote = nil

-- Anti-AFK
local vu = game:service'VirtualUser'
LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Auto Rejoin nếu bị kick
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Failed or State == Enum.TeleportState.Started then
        wait(2)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Tìm RemoteEvent
function findAllRemotes()
    local remotes = {}
    local function scan(obj)
        for _,v in pairs(obj:GetChildren()) do
            if v:IsA("RemoteEvent") then
                table.insert(remotes, v)
            end
            scan(v)
        end
    end
    scan(ReplicatedStorage)
    return remotes
end

-- Tự động tương tác khi tìm được Remote
function interactWithRemote(target)
    if getgenv().RemoteEvent and getgenv().RemoteEvent:IsA("RemoteEvent") then
        getgenv().RemoteEvent:FireServer(target)
    end
end

-- Teleport ẩn (anti-ban)
function safeTeleport(hrp, targetPos)
    local tween = game:GetService("TweenService"):Create(
        hrp,
        TweenInfo.new(math.random(1,2), Enum.EasingStyle.Linear),
        {CFrame = targetPos + Vector3.new(0, 3, 0)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Auto Farm
function farmBonds()
    while getgenv().AutoFarm do
        local folder = workspace:FindFirstChild("Bonds")
        if folder then
            for _, bond in pairs(folder:GetChildren()) do
                if bond:IsA("Model") and bond:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        safeTeleport(hrp, bond.HumanoidRootPart.CFrame)
                        wait(math.random(0.3, 0.6)) -- random delay chống phát hiện
                        interactWithRemote(bond)
                        wait(getgenv().FarmSpeed)
                    end
                end
            end
        end
        wait(1)
    end
end

-- Auto Upgrade (ví dụ: gửi remote nếu tiền > ngưỡng)
function autoUpgrade()
    while getgenv().AutoUpgrade do
        local stats = LocalPlayer:FindFirstChild("Stats") or LocalPlayer:WaitForChild("Stats")
        local money = stats:FindFirstChild("Money")
        if money and money.Value >= 500 then
            if getgenv().UpgradeRemote then
                getgenv().UpgradeRemote:FireServer() -- tuỳ game có args không
            end
        end
        wait(5)
    end
end

-- GUI Setup
local tab = Window:CreateTab("Auto Farm", 4483362458)

tab:CreateToggle({
    Name = "Auto Farm Bonds",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
        if Value then farmBonds() end
    end,
})

tab:CreateSlider({
    Name = "Tốc độ Farm (giây)",
    Range = {0.2, 5},
    Increment = 0.1,
    CurrentValue = 1,
    Callback = function(Value)
        getgenv().FarmSpeed = Value
    end,
})

tab:CreateDropdown({
    Name = "Chọn RemoteEvent",
    Options = (function()
        local list = {}
        for _, r in pairs(findAllRemotes()) do table.insert(list, r.Name) end
        return list
    end)(),
    CurrentOption = nil,
    Callback = function(Option)
        local found = ReplicatedStorage:FindFirstChild(Option, true)
        if found then
            getgenv().RemoteEvent = found
            Rayfield:Notify({
                Title = "RemoteEvent chọn",
                Content = "Đã chọn: " .. found.Name,
                Duration = 5,
            })
        end
    end,
})

tab:CreateToggle({
    Name = "Auto Upgrade khi đủ tiền",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoUpgrade = Value
        if Value then autoUpgrade() end
    end,
})

tab:CreateDropdown({
    Name = "Chọn RemoteEvent Upgrade",
    Options = (function()
        local list = {}
        for _, r in pairs(findAllRemotes()) do table.insert(list, r.Name) end
        return list
    end)(),
    CurrentOption = nil,
    Callback = function(Option)
        local found = ReplicatedStorage:FindFirstChild(Option, true)
        if found then
            getgenv().UpgradeRemote = found
            Rayfield:Notify({
                Title = "Upgrade Remote",
                Content = "Đã chọn: " .. found.Name,
                Duration = 5,
            })
        end
    end,
})
