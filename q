local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/relr-prog/qmain/refs/heads/main/advqmain"
local MAX_RETRIES = 5
local RETRY_DELAY = 2

local function showNotification(text, color)
    color = color or Color3.fromRGB(255, 0, 0)
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "NotifGUI"
    notifGui.Parent = playerGui
    notifGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 40)
    frame.Position = UDim2.new(0.5, -150, 0.85, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = notifGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame

    game:GetService("Debris"):AddItem(notifGui, 3)
end

local function checkEnvironment()
    local byfronDetected = false
    local antiExploitDetected = false

    pcall(function()
        local coreGui = game:GetService("CoreGui")
        if coreGui and coreGui:FindFirstChild("RobloxGui") then
            byfronDetected = true
        end
    end)

    local remotePatterns = {
        "AntiExploit", "AntiCheat", "Byfron", "Security", "Protection",
        "ExploitDetector", "BanHandler", "KickHandler", "RemoteChecker",
        "Admin", "Moderation", "AC", "Anticheat", "Anti-Exploit",
        "Hyperion", "ByfronBypass", "ProtectionSystem"
    }

    local containers = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Workspace"),
        game:GetService("ServerScriptService")
    }

    for _, container in ipairs(containers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    for _, pattern in ipairs(remotePatterns) do
                        if child.Name:find(pattern) or child.Name:lower():find(pattern:lower()) then
                            antiExploitDetected = true
                            break
                        end
                    end
                end
            end
        end
    end

    return {
        byfron = byfronDetected,
        antiExploit = antiExploitDetected,
        safe = not byfronDetected and not antiExploitDetected
    }
end

local function loadMainScript()
    local success, result = pcall(function()
        local script = loadstring(game:HttpGet(MAIN_SCRIPT_URL))
        if script then
            script()
            return true
        else
            return false
        end
    end)
    return success
end

local function main()
    print("[Starter] Checking environment...")
    local env = checkEnvironment()

    if not env.safe then
        warn("[Starter] Environment not safe. Byfron: " .. tostring(env.byfron) .. ", Anti-Exploit: " .. tostring(env.antiExploit))
        showNotification("Environment not safe. Retrying...", Color3.fromRGB(255, 200, 0))
    end

    local retryCount = 0
    local loaded = false

    while retryCount < MAX_RETRIES and not loaded do
        retryCount = retryCount + 1
        warn("[Starter] Attempt " .. retryCount .. " to load main script...")
        loaded = loadMainScript()

        if loaded then
            print("[Starter] Main script loaded successfully!")
            showNotification("Script Loaded!", Color3.fromRGB(0, 255, 0))
            break
        else
            warn("[Starter] Attempt " .. retryCount .. " failed.")
            if retryCount < MAX_RETRIES then
                wait(RETRY_DELAY)
            end
        end
    end

    if not loaded then
        print("[Starter] Failed to load main script after " .. MAX_RETRIES .. " attempts.")
        showNotification("Try again later", Color3.fromRGB(255, 0, 0))
        return
    end

    if loaded then
        task.wait(1)
        script:Destroy()
    end
end

local success, err = pcall(main)
if not success then
    warn("[Starter] Fatal error: " .. tostring(err))
    showNotification("Error: " .. tostring(err), Color3.fromRGB(255, 0, 0))
end
