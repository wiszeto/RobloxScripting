local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the player's character
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to wait for the Hearts GUI
local function waitForHeartsGUI(horse, timeout)
    local startTime = tick()
    while tick() - startTime < timeout do
        local heartsContainer = horse:FindFirstChild("TamingOverheadUI", true)
            and horse.TamingOverheadUI.InnerFrame.HeartsContainer
        if heartsContainer then
            return heartsContainer
        end
        task.wait()
    end
    warn("HeartsContainer did not appear for:", horse.Name)
    return nil
end

-- Function to check remaining hearts
local function checkHearts(heartsContainer)
    local heartsLeft = 0
    for _, heart in ipairs(heartsContainer:GetChildren()) do
        if heart:IsA("GuiObject") and heart.Name == "Heart" then
            local fill = heart:FindFirstChild("Fill")
            if fill and fill:IsA("GuiObject") and not fill.Visible then
                heartsLeft = heartsLeft + 1
            end
        end
    end
    return heartsLeft
end

-- Function to tame a horse
local function tameHorse(horse)
    local tameEvent = horse:FindFirstChild("TameEvent")
    if not tameEvent then
        warn("TameEvent not found on:", horse.Name)
        return
    end

    -- Teleport to the horse
    if character and character.PrimaryPart then
        character:SetPrimaryPartCFrame(CFrame.new(horse.Position))
        print("Teleported to:", horse.Name)
    else
        warn("Character or PrimaryPart not found!")
        return
    end

    task.wait(0.2) -- Small initial delay to ensure position/replication is stable

    -- Begin taming
    tameEvent:FireServer("Begin")
    task.wait(0.1)


    -- Wait for HeartsContainer to appear
    local heartsContainer = waitForHeartsGUI(horse, 5)
    if not heartsContainer then return end

    -- Track heart changes
    local lastHearts = checkHearts(heartsContainer)
    local sameHeartsTime = tick()
    local continueLoop = false
    local firstTime = true
    while true do
        local currentHearts = checkHearts(heartsContainer)
        print("Hearts remaining:", currentHearts)

        tameEvent = horse:FindFirstChild("TameEvent")
        if currentHearts == 0 or not tameEvent then
            print("Horse tamed successfully!")
            break
        end

        -- Check if hearts decreased
        if currentHearts < lastHearts then
            lastHearts = currentHearts
            sameHeartsTime = tick()
            continueLoop = true
        elseif currentHearts == lastHearts then
            continueLoop = false

            if tick() - sameHeartsTime > 5 then
                print("Hearts did not decrease for 5 seconds. Moving on...")
                break
            else
                task.wait(0.1)
            end

            if firstTime then

                tameEvent:FireServer("SuccessfulFeed")
                print("Fired TameEvent with SuccessfulFeed")
                firstTime = false
            end
        end

        if continueLoop then
        ReplicatedStorage.Remotes.PurchaseItemRemote:InvokeServer("WovenLasso", 1)
        task.wait(0.45)
        tameEvent:FireServer("SuccessfulFeed")
        print("Fired TameEvent with SuccessfulFeed")

        end
    end

    -- Cleanup / close GUIs
    local args = { [1] = { [1] = "1" } }
    game:GetService("ReplicatedStorage").Remotes.SellSlotsRemote:InvokeServer(unpack(args))
    local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("DisplayAnimalGui")
    if gui then
        gui.Enabled = false
        print("Disabled DisplayAnimalGui")
    end
end

-- Main loop
while true do 


    for _, mob in ipairs(Workspace.MobFolder:GetChildren()) do


        if mob:FindFirstChild("TameEvent") and mob.Name == "Horse" then
            print("Found tamable horse:", mob.Name)
            tameHorse(mob)
            task.wait()
        end
    end
    wait()
end
