-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Settings
local radius = 20 -- Detection radius for locking onto a player
local enabled = false -- Variable to toggle the script
local targetPlayer = nil -- Variable to store the locked target player
local spherePart = nil -- Sphere for visualization
local lockOffset = 4 -- Distance behind the target to lock onto

-- Variables to track character and humanoid root part
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Function to handle character updates on respawn
local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    updateSpherePosition() -- Ensure the sphere follows the new character
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Function to create a sphere for visualization
local function createSphere()
    if not spherePart then
        spherePart = Instance.new("Part")
        spherePart.Shape = Enum.PartType.Ball
        spherePart.Size = Vector3.new(radius * 2, radius * 2, radius * 2)
        spherePart.Anchored = true
        spherePart.CanCollide = false
        spherePart.Material = Enum.Material.SmoothPlastic
        spherePart.Transparency = 0.7
        spherePart.Color = Color3.fromRGB(0, 255, 0)
        spherePart.Parent = workspace
    end
end

-- Update the position of the sphere to follow the player
local function updateSpherePosition()
    if spherePart and humanoidRootPart then
        spherePart.Position = humanoidRootPart.Position
    end
end

-- Function to lock onto a position 4 studs behind the target and match look vector
local function teleportToBehindTarget(targetPosition, targetLookVector)
    if humanoidRootPart then
        -- Calculate the position 4 studs behind the target based on their look direction
        local behindPosition = targetPosition - (targetLookVector.Unit * lockOffset)
        -- Set the player's CFrame to the behind position, facing the same direction as the target
        humanoidRootPart.CFrame = CFrame.new(behindPosition, behindPosition + targetLookVector)
    end
end

-- Function to lock onto a player within the radius
local function lockOntoPlayer()
    if not enabled or targetPlayer then return end -- Only check if the script is enabled and no player is locked

    if humanoidRootPart then
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local otherHumanoidRootPart = otherPlayer.Character.HumanoidRootPart
                local distance = (humanoidRootPart.Position - otherHumanoidRootPart.Position).magnitude
                
                -- Lock onto the player if they are within the radius
                if distance <= radius then
                    targetPlayer = otherPlayer
                    print("Locked onto:", targetPlayer.Name)
                    return
                end
            end
        end
    end
end

-- Function to track the locked player and teleport behind them
local function trackTargetPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetHumanoidRootPart = targetPlayer.Character.HumanoidRootPart
        local targetPosition = targetHumanoidRootPart.Position
        local targetLookVector = targetHumanoidRootPart.CFrame.LookVector
        teleportToBehindTarget(targetPosition, targetLookVector)
    end
end

-- Function to toggle the script on and off
local function toggleScript()
    enabled = not enabled
    if enabled then
        print("Script enabled")
    else
        print("Script disabled")
        targetPlayer = nil -- Clear the target when disabling the script
    end
end


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- Ignore input if it's already processed by the game
    if input.KeyCode == Enum.KeyCode.LeftShift then
        toggleScript()
    end
end)

-- Continuously check for nearby players and lock onto them
RunService.Heartbeat:Connect(function()
    if enabled then
        if not targetPlayer then
            lockOntoPlayer()
        else
            trackTargetPlayer() -- Follow the locked target
        end
    end
    updateSpherePosition()
end)

-- Create the sphere when the script starts
createSphere()
