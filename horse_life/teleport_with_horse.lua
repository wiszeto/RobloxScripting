local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- The target part (in this case, the wild horse)

-- Distance behind the target
local distanceBehind = 15

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

-- Function to teleport the player (or their mount) behind the target horse
local function teleportToTarget(targetPart)
    if not (targetPart and targetPart:IsDescendantOf(workspace)) then
        warn("Target horse does not exist!")
        return
    end

    local targetPos = targetPart.Position
    local targetLook = targetPart.CFrame.LookVector

    -- Calculate the position behind the target
    local behindPosition = targetPos - (targetLook * distanceBehind)

    -- Determine if the player is mounted
    local ridingHorse = getRidingHorse()
    if ridingHorse and ridingHorse.PrimaryPart then
        -- Teleport the horse the player is riding
        ridingHorse:SetPrimaryPartCFrame(CFrame.new(behindPosition))
    else
        -- Teleport the player if not mounted
        humanoidRootPart.CFrame = CFrame.new(behindPosition)
    end
end

for x=1, 1 do 
for i, v in ipairs(game:GetService("Workspace").MobFolder:GetChildren()) do 
teleportToTarget(v)
wait(1)
end

wait()
end