-- Code made by Amokah, Refined by OpenAI

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local workspace = game.Workspace

local Player = Players.LocalPlayer
repeat wait(0.1) until Player.Character

local Character = Player.Character
Character.Archivable = true

local IsInvis = false
local IsRunning = true
local InvisibleCharacter = Character:Clone()
InvisibleCharacter.Parent = Lighting
InvisibleCharacter.Name = ""
local Void = workspace.FallenPartsDestroyHeight
local CF

-- Ensure InvisibleCharacter parts are semi-transparent
for _, v in pairs(InvisibleCharacter:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0.5
        v.CanCollide = false
    end
end

-- Respawn handler
local function Respawn()
    IsRunning = false
    if IsInvis then
        pcall(function()
            Player.Character = Character
            wait()
            Character.Parent = workspace
            Character:FindFirstChildWhichIsA("Humanoid"):Destroy()
            IsInvis = false
            InvisibleCharacter.Parent = nil
        end)
    else
        pcall(function()
            Player.Character = Character
            wait()
            Character.Parent = workspace
            Character:FindFirstChildWhichIsA("Humanoid"):Destroy()
        end)
    end
end

InvisibleCharacter:FindFirstChildWhichIsA("Humanoid").Died:Connect(Respawn)

-- Fix Camera
local function FixCam()
    workspace.CurrentCamera.CameraSubject = Player.Character:FindFirstChildWhichIsA("Humanoid")
    workspace.CurrentCamera.CFrame = CF
end

local function FreezeCamera(freeze)
    if freeze then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    else
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end
end

-- Turn invisible
local function TurnInvisible()
    if IsInvis then return end
    IsInvis = true
    CF = workspace.CurrentCamera.CFrame
    local rootCFrame = Character.HumanoidRootPart.CFrame

    -- Move character out of bounds
    Character:MoveTo(Vector3.new(0, math.pi * 1000000, 0))

    -- Freeze and unfreeze camera
    FreezeCamera(true)
    wait(0.2)
    FreezeCamera(false)

    -- Swap characters
    Character.Parent = Lighting
    InvisibleCharacter.Parent = workspace
    InvisibleCharacter.HumanoidRootPart.CFrame = rootCFrame
    Player.Character = InvisibleCharacter
    FixCam()

    -- Reset animations
    Player.Character.Animate.Disabled = true
    Player.Character.Animate.Disabled = false
end

-- Turn visible
local function TurnVisible()
    if not IsInvis then return end
    CF = workspace.CurrentCamera.CFrame
    local rootCFrame = InvisibleCharacter.HumanoidRootPart.CFrame

    -- Swap characters back
    InvisibleCharacter.Parent = Lighting
    Character.Parent = workspace
    Character.HumanoidRootPart.CFrame = rootCFrame
    Player.Character = Character

    IsInvis = false
    FixCam()

    -- Reset animations
    Player.Character.Animate.Disabled = true
    Player.Character.Animate.Disabled = false
end

-- Toggle invisibility using the "X" key
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end -- Ignore if input is already handled
    if input.KeyCode == Enum.KeyCode.X then
        if IsInvis then
            TurnVisible()
        else
            TurnInvisible()
        end
    end
end)

-- Monitor void and respawn if needed
RunService.Stepped:Connect(function()
    pcall(function()
        local rootPosition = Player.Character:FindFirstChild("HumanoidRootPart").Position
        local yPosition = rootPosition.Y
        if (Void < 0 and yPosition <= Void) or (Void > 0 and yPosition >= Void) then
            Respawn()
        end
    end)
end)

-- Handle character resets
Player.CharacterAdded:Connect(function()
    if Player.Character == InvisibleCharacter then return end

    repeat wait(0.1) until Player.Character:FindFirstChildWhichIsA("Humanoid")
    if not IsRunning then
        IsInvis = false
        IsRunning = true
        Character = Player.Character
        Character.Archivable = true
        InvisibleCharacter = Character:Clone()
        InvisibleCharacter.Parent = Lighting
        InvisibleCharacter.Name = ""

        -- Set transparency for cloned character
        for _, v in pairs(InvisibleCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = v.Name == "HumanoidRootPart" and 1 or 0.5
                v.CanCollide = false
            end
        end

        InvisibleCharacter:FindFirstChildWhichIsA("Humanoid").Died:Connect(Respawn)
    end
end)

print("Invisibility toggle script loaded. Press 'X' to toggle invisibility.")
