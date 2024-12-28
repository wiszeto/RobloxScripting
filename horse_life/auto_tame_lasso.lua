game:GetService("Players").FNwillie.PlayerGui.HUDGui.Enabled = false

while true do 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local mobFolder = Workspace:FindFirstChild("MobFolder")
if not mobFolder then
    warn("MobFolder not found!")
    return
end

-- The target part (wild horse)
local targetPart = mobFolder:FindFirstChild("Horse")
if not targetPart then
    warn("No 'Horse' found in MobFolder!")
    return
end

local distanceBehind = 1
local camera = Workspace.CurrentCamera

-- Function to check if the player is currently riding a horse
local function getRidingHorse()
    local seatPart = humanoid.SeatPart
    if seatPart and seatPart.Parent then
        local mount = seatPart.Parent
        if mount:FindFirstChild("HumanoidRootPart") then
            return mount
        end
    end
    return nil
end

-- Function to position and face the character (or their mount) towards the target part
local function faceAndStandBehindTarget()
    if not (targetPart and targetPart:IsDescendantOf(Workspace)) then 
        return 
    end

    local targetPos = targetPart.Position
    local targetLook = targetPart.CFrame.LookVector
    local behindPosition = targetPos - (targetLook * distanceBehind)
    
    local ridingHorse = getRidingHorse()
    if ridingHorse and ridingHorse.PrimaryPart then
        ridingHorse:SetPrimaryPartCFrame(CFrame.new(behindPosition, targetPos))
    else
        humanoidRootPart.CFrame = CFrame.new(behindPosition, targetPos)
    end
end

-- Function to simulate clicking on the target part
local lastClickTime = 0
local clickInterval = 0.1  -- Adjust as needed

local function clickOnTarget()
    if not (targetPart and targetPart:IsDescendantOf(Workspace)) then
        return
    end

    -- Throttle clicks so we don't click every frame
    if os.clock() - lastClickTime < clickInterval then
        return
    end
    lastClickTime = os.clock()

    local screenPosition = camera:WorldToViewportPoint(targetPart.Position)
    -- Move the mouse to the mob's screen position
    VirtualInputManager:SendMouseMoveEvent(screenPosition.X, screenPosition.Y, game)

    -- Simulate two quick clicks
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, true, game, 0)  -- Press
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, false, game, 0) -- Release
    wait()
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, true, game, 0)  -- Press
    VirtualInputManager:SendMouseButtonEvent(screenPosition.X, screenPosition.Y, 0, false, game, 0) -- Release
end

-- Continuously update position/orientation and click
local connection
connection = RunService.RenderStepped:Connect(function()
    -- Check if the target part still exists
    if not (targetPart and targetPart:IsDescendantOf(Workspace)) then
        -- Target gone, stop
        if connection then
            
            connection:Disconnect()
            connection = nil
        end
        return
    end

    -- If target exists, lock on and click
    faceAndStandBehindTarget()
    clickOnTarget()
end)


    local args = {
    [1] = {
        [1] = "1"
    }
}

game:GetService("ReplicatedStorage").Remotes.SellSlotsRemote:InvokeServer(unpack(args))

game:GetService("Players").FNwillie.PlayerGui.DisplayAnimalGui.Enabled = false

local args = {
    [1] = "StringLasso",
    [2] = 1
}

game:GetService("ReplicatedStorage").Remotes.PurchaseItemRemote:InvokeServer(unpack(args))


wait()

end