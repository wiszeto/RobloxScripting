-- Define the path to the items
local collectionsFolder = game:GetService("Workspace").Minigames.Collectiongame2.Collections

-- Define the target position to teleport items
local targetPosition = Vector3.new(0, 50, 0) -- Change this to your desired location

-- Function to teleport all items
local function teleportItems(folder, targetPos)
    for _, item in ipairs(folder:GetChildren()) do
        -- Check if the object has a PrimaryPart (for models) or is a BasePart
        if item:IsA("Model") and item.PrimaryPart then
            item:SetPrimaryPartCFrame(CFrame.new(targetPos))
        elseif item:IsA("BasePart") then
            item.Position = targetPos
        end
    end
end

-- Call the function
teleportItems(collectionsFolder, targetPosition)
