
-- Roblox Executor Script with CDN Support + Fallback
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

-- Core AutoFarm (placeholder)
local core = [[bG9jYWwgUnVuU2VydmljZSA9IGdhbWU6R2V0U2VydmljZSgiUnVuU2VydmljZSIpCmxvY2FsIFBsYXllcnMg...]]
pcall(function() loadstring(decodeBase64(core))() end)

-- CDN Loader

-- Module Loader with CDN fallback
local HttpService = game:GetService("HttpService")

local function tryLoad(url, fallback)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result and result ~= "" then
        local ok, err = pcall(function()
            loadstring(result)()
        end)
        if not ok then
            warn("Error loading from CDN:", err)
        end
    else
        loadstring(fallback)()
    end
end


-- Load modules with CDN fallback
pcall(function() tryLoad("https://pastebin.com/raw/example_esp", decodeBase64([[CmxvY2FsIFBsYXllcnMgPSBnYW1lOkdldFNlcnZpY2UoIlBsYXllcnMiKQpsb2NhbCBmdW5jdGlvbiBoaWdobGlnaHQodGFyZ2V0KQogICAgbG9jYWwgZXNwID0gSW5zdGFuY2UubmV3KCJIaWdobGlnaHQiKQogICAgZXNwLkZpbGxDb2xvciA9IENvbG9yMy5mcm9tUkdCKDI1NSwgMCwgMCkKICAgIGVzcC5PdXRsaW5lQ29sb3IgPSBDb2xvcjMubmV3KDEsMSwxKQogICAgZXNwLkZpbGxUcmFuc3BhcmVuY3kgPSAwLjUKICAgIGVzcC5PdXRsaW5lVHJhbnNwYXJlbmN5ID0gMAogICAgZXNwLkFkb3JuZWUgPSB0YXJnZXQKICAgIGVzcC5QYXJlbnQgPSB0YXJnZXQKZW5kCmZvciBfLCBwbGF5ZXIgaW4gcGFpcnMoUGxheWVyczpHZXRQbGF5ZXJzKCkpIGRvCiAgICBpZiBwbGF5ZXIgfj0gUGxheWVycy5Mb2NhbFBsYXllciB0aGVuCiAgICAgICAgbG9jYWwgY2hhciA9IHBsYXllci5DaGFyYWN0ZXIgb3IgcGxheWVyLkNoYXJhY3RlckFkZGVkOldhaXQoKQogICAgICAgIGhpZ2hsaWdodChjaGFyKQogICAgZW5kCmVuZAo=]])) end)
pcall(function() tryLoad("https://pastebin.com/raw/example_quest", decodeBase64([[CmxvY2FsIFJlcGxpY2F0ZWRTdG9yYWdlID0gZ2FtZTpHZXRTZXJ2aWNlKCJSZXBsaWNhdGVkU3RvcmFnZSIpCmxvY2FsIHF1ZXN0UmVtb3RlID0gUmVwbGljYXRlZFN0b3JhZ2U6RmluZEZpcnN0Q2hpbGQoIlF1ZXN0UmVtb3RlIikgb3IgZXJyb3IoIlF1ZXN0UmVtb3RlIG5vdCBmb3VuZCIpCndoaWxlIHdhaXQoMTApIGRvCiAgICBwY2FsbChmdW5jdGlvbigpCiAgICAgICAgcXVlc3RSZW1vdGU6RmlyZVNlcnZlcigiQWNjZXB0UXVlc3QiKQogICAgICAgIHF1ZXN0UmVtb3RlOkZpcmVTZXJ2ZXIoIkNvbXBsZXRlUXVlc3QiKQogICAgZW5kKQplbmQK]])) end)
pcall(function() tryLoad("https://pastebin.com/raw/example_sell", decodeBase64([[CmxvY2FsIFJlcGxpY2F0ZWRTdG9yYWdlID0gZ2FtZTpHZXRTZXJ2aWNlKCJSZXBsaWNhdGVkU3RvcmFnZSIpCmxvY2FsIHNlbGxSZW1vdGUgPSBSZXBsaWNhdGVkU3RvcmFnZTpGaW5kRmlyc3RDaGlsZCgiU2VsbFJlbW90ZSIpIG9yIGVycm9yKCJTZWxsUmVtb3RlIG5vdCBmb3VuZCIpCndoaWxlIHdhaXQoNSkgZG8KICAgIHBjYWxsKGZ1bmN0aW9uKCkKICAgICAgICBzZWxsUmVtb3RlOkZpcmVTZXJ2ZXIoKQogICAgZW5kKQplbmQK]])) end)
