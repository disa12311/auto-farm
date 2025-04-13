--[[
    Dead Rail - Full Auto Script Pro
    Tính năng:
    - Auto Farm Bonds (tùy chỉnh tốc độ)
    - Anti-AFK
    - Auto Rejoin khi bị kick/disconnect
    - Anti-detection (teleport & delay ngẫu nhiên, jitter)
    - GUI chọn RemoteEvent cho farm & upgrade & sell
    - Auto Upgrade thông minh theo config
    - Auto Sell khi đủ threshold
    - ESP cơ bản cho Bonds
    - Multi-threading với coroutine + pcall
]]

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Global variables
getgenv().AutoFarm       = false
getgenv().FarmSpeed      = 1
getgenv().RemoteEvent    = nil
getgenv().AutoUpgrade    = false
getgenv().UpgradeRemote  = nil
getgenv().AutoSell       = false
getgenv().SellThreshold  = 1000
getgenv().SellRemote     = nil
getgenv().AutoESP        = false
getgenv().UpgradeConfig  = ReplicatedStorage:FindFirstChild("Upgrades") and ReplicatedStorage.Upgrades:FindFirstChild("Config") or nil
getgenv().Priority       = {"Speed","Capacity","Damage"}

-- Anti-AFK
local vu = game:service('VirtualUser')
LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Auto Rejoin
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Failed or State == Enum.TeleportState.Started then
        wait(2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- Utility: Random delay (triangular distribution)
local function randomDelay(min, peak, max)
    local u = math.random()
    if u < (peak-min)/(max-min) then
        return min + math.sqrt(u*(max-min)*(peak-min))
    else
        return max - math.sqrt((1-u)*(max-min)*(max-peak))
    end
end

-- Anti-detection teleport & jitter
local function antiDetectTeleport(hrp, targetCFrame)
    local angles = Vector3.new(
        math.random(-5,5),
        math.random(-180,180),
        0
    )
    local jittered = targetCFrame * CFrame.Angles(math.rad(angles.X), math.rad(angles.Y), 0)
    if math.random() < 0.5 and hrp.Parent:FindFirstChild("Humanoid") then
        hrp.Parent.Humanoid:MoveTo(jittered.Position)
    else
        hrp.CFrame = jittered + Vector3.new(0,3,0)
    end
    wait(randomDelay(0.2,0.5,1))
end

-- Safe coroutine spawn
local function safeSpawn(fn)
    coroutine.wrap(function()
        while true do
            local ok, err = pcall(fn)
            if not ok then warn("Error in thread: ", err) end
            wait(0.1)
        end
    end)()
end

-- Find all RemoteEvents in ReplicatedStorage
local function findAllRemotes()
    local remotes = {}
    local function scan(obj)
        for _,v in pairs(obj:GetChildren()) do
            if v:IsA("RemoteEvent") then table.insert(remotes, v) end
            scan(v)
        end
    end
    scan(ReplicatedStorage)
    return remotes
end

-- Get sorted bonds by distance
local function getSortedBonds()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not workspace:FindFirstChild("Bonds") then return {} end
    local list = {}
    for _,bond in pairs(workspace.Bonds:GetChildren()) do
        if bond:FindFirstChild("HumanoidRootPart") then table.insert(list, bond) end
    end
    table.sort(list, function(a,b)
        return (a.HumanoidRootPart.Position - hrp.Position).Magnitude <
               (b.HumanoidRootPart.Position - hrp.Position).Magnitude
    end)
    return list
end

-- Interact via RemoteEvent
local function interactWithRemote(target)
    if getgenv().RemoteEvent and getgenv().RemoteEvent:IsA("RemoteEvent") then
        getgenv().RemoteEvent:FireServer(target)
    end
end

-- Farming logic
local function farmBonds()
    local hrp
    while getgenv().AutoFarm do
        hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, bond in ipairs(getSortedBonds()) do
                antiDetectTeleport(hrp, bond.HumanoidRootPart.CFrame)
                wait(math.random(1,2)/10)
                interactWithRemote(bond)
                wait(getgenv().FarmSpeed)
            end
        end
        wait(1)
    end
end

-- Smart Auto Upgrade
local function autoUpgradeSmart()
    if not UpgradeConfig then return end
    local stats = LocalPlayer:FindFirstChild("Stats")
    if not stats then return end
    for _, statName in ipairs(getgenv().Priority) do
        local conf = UpgradeConfig:FindFirstChild(statName)
        local stat = stats:FindFirstChild(statName)
        if conf and stat and stat.Value < conf.MaxValue and stats.Money.Value >= conf.Cost then
            getgenv().UpgradeRemote:FireServer(statName)
            wait(randomDelay(0.5,1,2))
        end
    end
end

-- Auto Sell logic
local function autoSell()
    local stats = LocalPlayer:FindFirstChild("Stats")
    if not stats or not stats:FindFirstChild("Money") then return end
    while getgenv().AutoSell do
        if stats.Money.Value >= getgenv().SellThreshold and getgenv().SellRemote then
            getgenv().SellRemote:FireServer()
        end
        wait(5)
    end
end

-- Basic ESP
local espFolder = Instance.new("Folder", LocalPlayer:WaitForChild("PlayerGui"))
espFolder.Name = "ESP"
local function runESP()
    for _, bond in pairs(workspace:FindFirstChild("Bonds") and workspace.Bonds:GetChildren() or {}) do
        if bond:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(bond.HumanoidRootPart.Position)
            local box = espFolder:FindFirstChild(bond.Name) or Drawing.new("Square")
            box.Visible = onScreen and getgenv().AutoESP
            box.Size = Vector2.new(30,30)
            box.Position = Vector2.new(screenPos.X-15, screenPos.Y-15)
            box.Thickness = 1
        end
    end
end

-- GUI
local Window = Rayfield:CreateWindow({
    Name = "Dead Rail - Full Auto Pro",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by YourName",
    ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "DeadRailPro" },
    KeySystem = false,
})

local tab = Window:CreateTab("Main", 4483362458)

-- Farm Toggle & Speed
tab:CreateToggle({ Name = "Auto Farm Bonds", CurrentValue = false, Flag = "AutoFarm", Callback = function(v)
    getgenv().AutoFarm = v
    if v then safeSpawn(farmBonds) end
end })

tab:CreateSlider({ Name = "Farm Speed (s)", Range = {0.2,5}, Increment = 0.1, CurrentValue = 1, Flag = "FarmSpeed", Callback = function(v)
    getgenv().FarmSpeed = v
end })

-- Remote selection for farming
local remoteNames = {}
for _, r in ipairs(findAllRemotes()) do table.insert(remoteNames, r.Name) end
tab:CreateDropdown({ Name = "Chọn Remote Farm", Options = remoteNames, CurrentOption = nil, Callback = function(opt)
    getgenv().RemoteEvent = ReplicatedStorage:FindFirstChild(opt, true)
    Rayfield:Notify({ Title = "Remote Farm", Content = "Đã chọn: "..opt, Duration = 4 })
end })

-- Auto Upgrade
tab:CreateToggle({ Name = "Auto Upgrade Smart", CurrentValue = false, Flag = "AutoUp", Callback = function(v)
    getgenv().AutoUpgrade = v
    if v then safeSpawn(autoUpgradeSmart) end
end })

tab:CreateDropdown({ Name = "Chọn Remote Upgrade", Options = remoteNames, CurrentOption = nil, Callback = function(opt)
    getgenv().UpgradeRemote = ReplicatedStorage:FindFirstChild(opt, true)
    Rayfield:Notify({ Title = "Remote Upgrade", Content = "Đã chọn: "..opt, Duration = 4 })
end })

-- Auto Sell
tab:CreateToggle({ Name = "Auto Sell", CurrentValue = false, Flag = "AutoSell", Callback = function(v)
    getgenv().AutoSell = v
    if v then safeSpawn(autoSell) end
end })

tab:CreateSlider({ Name = "Sell Threshold", Range = {100,10000}, Increment = 100, CurrentValue = 1000, Flag = "SellThres", Callback = function(v)
    getgenv().SellThreshold = v
end })

tab:CreateDropdown({ Name = "Chọn Remote Sell", Options = remoteNames, CurrentOption = nil, Callback = function(opt)
    getgenv().SellRemote = ReplicatedStorage:FindFirstChild(opt, true)
    Rayfield:Notify({ Title = "Remote Sell", Content = "Đã chọn: "..opt, Duration = 4 })
end })

-- ESP Toggle
tab:CreateToggle({ Name = "ESP Bonds", CurrentValue = false, Flag = "ESP", Callback = function(v)
    getgenv().AutoESP = v
end })

-- Run ESP on RenderStepped
RunService.RenderStepped:Connect(function()
    if getgenv().AutoESP then pcall(runESP) end
end)

-- End of script
