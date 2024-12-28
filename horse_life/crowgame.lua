while true do 
    game:GetService("ReplicatedStorage").Remotes.StartCrowMinigame:InvokeServer()
    
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    
    -- Get the player and their character
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    
    -- Define the folder
    local targetFolder = Workspace:FindFirstChild("Events")
        and Workspace.Events:FindFirstChild("Christmas")
        and Workspace.Events.Christmas:FindFirstChild("CrowPlayers")
        and Workspace.Events.Christmas.CrowPlayers:FindFirstChild("FNwillie")
    
    if not targetFolder then
        warn("Target folder not found!")
        return
    end
    
    -- Function to teleport a part to the character
    local function teleportPartToCharacter(part)
        if character and character.PrimaryPart then
            local targetPosition = character.PrimaryPart.Position + Vector3.new(0, 5, 0) -- Offset above the character
            part.CFrame = CFrame.new(targetPosition)
            print("Teleported part:", part.Name, "to character")
        else
            warn("Character or PrimaryPart not found!")
        end
    end
    
    -- Loop through the folder and teleport each part to the character until the folder is empty
    while #targetFolder:GetChildren() > 0 do
        for _, part in ipairs(targetFolder:GetChildren()) do
            if part:IsA("BasePart") then
                teleportPartToCharacter(part)
                wait(0.5) -- Adjust delay to control loop speed
            end
        end
    end
    
    print("All parts in the folder have been teleported to the character!")
    
    wait(1)
    end