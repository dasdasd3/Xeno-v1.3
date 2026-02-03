-- TOGA overlay only, with the TOGA text moved a bit higher on the screen
-- Put this LocalScript in StarterPlayerScripts or run with an executor.
-- Press R while pointing at a player to lock camera on them; when locking the TOGA flame animation appears a bit higher on screen.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local plr = Players.LocalPlayer

-- Replace this with your flame asset id if you have a better one
local flameAsset = "rbxassetid://15110444878"

local isLocked = false
local lockTarget = nil
local animPlaying = false

-- ====== GUI Overlay (TOGA only, positioned higher) ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TOGA_OverlayOnly_High"
screenGui.ResetOnSpawn = false
screenGui.Parent = plr:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1,0,1,0)
overlay.Position = UDim2.new(0,0,0,0)
overlay.BackgroundTransparency = 1
overlay.ZIndex = 50
overlay.Parent = screenGui

local togaText = Instance.new("TextLabel")
togaText.Name = "TogaText"
togaText.AnchorPoint = Vector2.new(0.5, 0.5)
togaText.Size = UDim2.new(0.9, 0, 0.45, 0)
-- Moved a bit higher on the screen (smaller Y value)
togaText.Position = UDim2.new(0.5, 0, 0.28, 0) -- <<--- higher than before
togaText.BackgroundTransparency = 1
togaText.Text = "TOGA"
togaText.Font = Enum.Font.GothamBlack
togaText.TextScaled = true
togaText.TextColor3 = Color3.fromRGB(255,180,55)
togaText.TextStrokeColor3 = Color3.fromRGB(180,40,0)
togaText.TextTransparency = 1
togaText.TextStrokeTransparency = 1
togaText.Visible = false
togaText.ZIndex = 51
togaText.Parent = overlay

local togaStroke = Instance.new("UIStroke", togaText)
togaStroke.Color = Color3.fromRGB(255,110,40)
togaStroke.Thickness = 18
togaStroke.Transparency = 1

local flameImg = Instance.new("ImageLabel")
flameImg.Name = "Flame"
flameImg.AnchorPoint = Vector2.new(0.5, 0)
flameImg.Size = UDim2.new(0.95, 0, 0.35, 0)
-- moved higher to stay above/around the higher TOGA
flameImg.Position = UDim2.new(0.5, 0, 0.12, 0) -- <<--- higher than before
flameImg.BackgroundTransparency = 1
flameImg.Image = flameAsset
flameImg.ImageTransparency = 1
flameImg.Visible = false
flameImg.ZIndex = 52
flameImg.Parent = overlay

-- ====== Helpers ======
local function getPlayerUnderMouse()
    local mouse = plr:GetMouse()
    local target = mouse.Target
    if not target then return nil end
    local model = target:FindFirstAncestorOfClass("Model")
    if model and Players:GetPlayerFromCharacter(model) and model ~= plr.Character then
        return Players:GetPlayerFromCharacter(model)
    end
    return nil
end

local function playTogaAnimation()
    if animPlaying then return end
    animPlaying = true
    togaText.Visible = true
    flameImg.Visible = true

    -- prepare
    togaText.TextTransparency = 1
    togaText.TextStrokeTransparency = 1
    togaStroke.Transparency = 1
    flameImg.ImageTransparency = 1
    -- start slightly above then move into place (already positioned higher)
    flameImg.Position = UDim2.new(0.5, 0, -0.15, 0)

    -- entrance
    TweenService:Create(togaText, TweenInfo.new(0.28, Enum.EasingStyle.Back), {TextTransparency = 0, TextStrokeTransparency = 0.06}):Play()
    TweenService:Create(flameImg, TweenInfo.new(0.32, Enum.EasingStyle.Quad), {ImageTransparency = 0.12, Position = UDim2.new(0.5,0,0.12,0)}):Play()
    TweenService:Create(togaStroke, TweenInfo.new(0.32), {Transparency = 0.12}):Play()

    -- flicker/jitter loop
    for i = 1, 14 do
        local jitterY = (math.sin(i*0.9)+math.random()*0.6)*0.008 -- slightly smaller jitter because higher looks better subtle
        local rot = math.random(-7,7)
        local scaleOffset = 1 + (math.sin(i*1.1)*0.012) + (math.random()-0.5)*0.01

        TweenService:Create(togaText, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {
            Rotation = rot,
            TextColor3 = Color3.fromRGB(255, 170 + math.random(-8,14), 40 + math.random(-8,20))
        }):Play()

        TweenService:Create(flameImg, TweenInfo.new(0.06, Enum.EasingStyle.Linear), {
            Position = UDim2.new(0.5,0, 0.12 + jitterY, 0),
            Size = UDim2.new(0.95 * scaleOffset, 0, 0.35 * scaleOffset, 0),
            ImageTransparency = 0.08 + math.random()*0.06
        }):Play()

        wait(0.06)
    end

    -- fade out
    TweenService:Create(togaText, TweenInfo.new(0.36, Enum.EasingStyle.Quad), {TextTransparency = 1, TextStrokeTransparency = 1, Rotation = 0}):Play()
    TweenService:Create(flameImg, TweenInfo.new(0.36, Enum.EasingStyle.Quad), {ImageTransparency = 1, Position = UDim2.new(0.5,0, -0.15, 0)}):Play()
    TweenService:Create(togaStroke, TweenInfo.new(0.36), {Transparency = 1}):Play()
    wait(0.38)

    flameImg.Visible = false
    togaText.Visible = false
    animPlaying = false
end

-- ====== Lock behavior ======
local function startLock(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    isLocked = true
    lockTarget = targetPlayer
    -- play TOGA animation (overlay higher)
    spawn(function() pcall(playTogaAnimation) end)
end

local function stopLock()
    isLocked = false
    lockTarget = nil
    if plr.Character and plr.Character:FindFirstChildWhichIsA("Humanoid") then
        workspace.CurrentCamera.CameraSubject = plr.Character:FindFirstChildWhichIsA("Humanoid")
    end
end

-- Keybind R: toggle lock
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.R then
        if isLocked then
            stopLock()
        else
            local targ = getPlayerUnderMouse()
            if targ then
                startLock(targ)
            end
        end
    end
end)

-- Camera follow while locked
RunService.RenderStepped:Connect(function()
    if isLocked and lockTarget and lockTarget.Character and lockTarget.Character:FindFirstChild("HumanoidRootPart") then
        local cam = workspace.CurrentCamera
        local fromPos = cam.CFrame.Position
        local targetPos = lockTarget.Character.HumanoidRootPart.Position
        cam.CFrame = CFrame.new(fromPos, targetPos)
    end
end)

-- End