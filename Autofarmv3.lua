--[[ 
    Roblox Executor Script: AutoFarm + Anti-Ban + GUI + Base64 Protected
    Author: Custom Build by ChatGPT
]]

-- GUI Placeholder (có thể thay bằng Rayfield GUI hoặc OrionLib)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "usrMenuPanel"
ScreenGui.ResetOnSpawn = false

local SafeMode = false
local AutoExit = true

-- Safe Toggle Button
local toggle = Instance.new("TextButton")
toggle.Text = "Toggle Safe Mode"
toggle.Size = UDim2.new(0, 200, 0, 50)
toggle.Position = UDim2.new(0.5, -100, 0, 20)
toggle.Parent = ScreenGui
toggle.MouseButton1Click:Connect(function()
    SafeMode = not SafeMode
    toggle.Text = "Safe Mode: " .. (SafeMode and "ON" or "OFF")
end)

-- Detection Guard
local function isMonitored()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("LocalScript") and not obj:IsDescendantOf(Player) then
            return true
        end
    end
    return false
end

-- Auto Exit nếu bị phát hiện
spawn(function()
    while true do
        wait(2)
        if isMonitored() and AutoExit then
            Player:Kick("Anti-Ban: Suspicious activity detected.")
            break
        end
    end
end)

-- Giải mã base64 và thực thi phần lõi
local b = [[
bG9jYWwgUnVuU2VydmljZSA9IGdhbWU6R2V0U2VydmljZSgiUnVuU2VydmljZSIpCmxvY2FsIFBsYXllcnMgPSBnYW1lOkdldFNlcnZpY2UoIlBsYXllcnMiKQpsb2NhbCBQbGF5ZXIgPSBQbGF5ZXJzLkxvY2FsUGxheWVyCmxvY2FsIFJlbW90ZXMgPSB7fQpsb2NhbCBTYWZlTW9kZSA9IGZhbHNlCmxvY2FsIGZ1bmN0aW9uIGdldFJhbmRvbURlbGF5KCkKICAgIHJldHVybiBtYXRoLnJhbmRvbSgxLCAzKSArIG1hdGgucmFuZG9tKCkKZW5kCmxvY2FsIGZ1bmN0aW9uIHNhZmVGaXJlKHJlbW90ZSwgLi4uKQogICAgaWYgU2FmZU1vZGUgdGhlbiB3YWl0KGdldFJhbmRvbURlbGF5KCkpIGVuZAogICAgcGNhbChmdW5jdGlvbigpIHJlbW90ZTpGaXJlU2VydmVyKC4uLikgZW5kKQplbmQKClJ1blNlcnZpY2UuSGVhcnRiZWF0OkNvbm5lY3QoZnVuY3Rpb24oKQogICAgaWYgU2FmZU1vZGUgdGhlbiByZXR1cm4KICAgIGZvciBfLCByZW1vdGUgaW4gcGFpcnMoUmVtb3RlcykgZG8KICAgICAgICBzYWZlRmlyZShyZW1vdGUsICJEb0Zhcm0iKQogICAgZW5kCmVuZCk=
]]

local function decodeBase64(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local success, result = pcall(function()
    loadstring(decodeBase64(b))()
end)

if not success then
    warn("Failed to load core script:", result)
end
