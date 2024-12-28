local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

-- Get the player and their character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Get the ResourceNodes folder
local resourceNodesFolder = Workspace:FindFirstChild("ResourceNodes")
if not resourceNodesFolder then
    warn("ResourceNodes folder not found!")
    return
end

-- Find the closest part
local closestPart = nil
local shortestDistance = math.huge

for _, part in ipairs(resourceNodesFolder:GetChildren()) do
    if part:IsA("BasePart") then -- Ensure it's a part
        local distance = (character.PrimaryPart.Position - part.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            closestPart = part
        end
    end
end

-- Simulate a click on the closest part
if closestPart then
    print("Closest part found:", closestPart.Name, "at distance:", shortestDistance)
    print(character.PrimaryPart.Position)

    -- Convert the part's position to screen coordinates
    local camera = Workspace.CurrentCamera
    local screenPosition = camera:WorldToViewportPoint(closestPart.Position)

    -- Move the mouse to the part's screen position
    VirtualInputManager:SendMouseMoveEvent(screenPosition.X, screenPosition.Y, game)

    -- Simulate a mouse click
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, true, game, 0) -- Press
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, false, game, 0) -- Release
    wait()
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, true, game, 0) -- Press
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, false, game, 0) -- Release
else
    warn("No parts found in the ResourceNodes folder!")
end
