local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Beamware",
    Icon = 0,
    LoadingTitle = "Beam Hub",
    LoadingSubtitle = "by willievibes",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Beamware"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "No method of obtaining the key is provided",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local MainTab = Window:CreateTab("Main")
local delayValue = 1.3 -- Set default value

MainTab:CreateSlider({
    Name = "Set deselect time",
    Range = {0.5, 2.5},
    Increment = 0.01,
    Suffix = "seconds",
    CurrentValue = delayValue,
    Callback = function(Value)
        delayValue = Value
    end,
})

-- Cache Knit Services
local KnitServices = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.5.1"].knit.Services

-- Fetch pet data
local petDataResponse = KnitServices.PlayerDataService.RF.GetAllData:InvokeServer()

local petOptions = {}
local petUUIDs = {}

if petDataResponse.Pets and typeof(petDataResponse.Pets) == "table" then
    for _, petData in pairs(petDataResponse.Pets) do
        if typeof(petData) == "table" then
            local shortenedUUID = string.sub(petData.UUID, 1, 8)
            local optionStr = "Pet: " .. petData.PetID .. " - Evo: " .. tostring(petData.Evolution) .. " - Size: " .. tostring(petData.Size) .. " - UUID: " .. shortenedUUID
            table.insert(petOptions, optionStr)
            petUUIDs[optionStr] = petData.UUID
        end
    end
else
    print("No 'Pets' key or it's not a table.")
end

local selectedPetUUIDs = {}
local previousOptions = {}

local function shallowCopy(original)
    local copy = {}
    for _, v in ipairs(original) do
        table.insert(copy, v)
    end
    return copy
end

MainTab:CreateDropdown({
    Name = "Select Pets",
    Options = petOptions,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "PetDropdown",
    Callback = function(Options)
        local newOptionMap = {}
        for _, option in ipairs(Options) do
            newOptionMap[option] = true
        end

        local previousOptionMap = {}
        for _, option in ipairs(previousOptions) do
            previousOptionMap[option] = true
        end

        -- Find newly selected options
        for _, option in ipairs(Options) do
            if not previousOptionMap[option] then
                local uuid = petUUIDs[option]
                if uuid then
                    print("Selecting pet with UUID:", uuid)
                    KnitServices.TradeService.RE.TradeSelectPet:FireServer(uuid)
                end
            end
        end

        -- Find deselected options
        for _, option in ipairs(previousOptions) do
            if not newOptionMap[option] then
                local uuid = petUUIDs[option]
                if uuid then
                    print("Deselecting pet with UUID:", uuid)
                    KnitServices.TradeService.RE.TradeDeselectPet:FireServer(uuid)
                end
            end
        end

        previousOptions = shallowCopy(Options)
        selectedPetUUIDs = {}
        for _, option in ipairs(Options) do
            local uuid = petUUIDs[option]
            if uuid then
                table.insert(selectedPetUUIDs, uuid)
            end
        end

        print("Selected Pet UUIDs:", table.concat(selectedPetUUIDs, ", "))
    end,
})

MainTab:CreateButton({
    Name = "Accepting Trade (do not click twice during trade)",
    Callback = function()
        print("Accepting Trade")
        KnitServices.TradeService.RE.TradeAccept:FireServer()

        local countdownDuration = 5
        local timeToWait = math.max(0, countdownDuration - delayValue)

        delay(timeToWait, function()
            if #selectedPetUUIDs > 0 then
                print("Deselecting pets at " .. string.format("%.2f", delayValue) .. " seconds before countdown ends:")
                for _, uuid in ipairs(selectedPetUUIDs) do
                    print("Deselecting UUID:", uuid)
                    KnitServices.TradeService.RE.TradeDeselectPet:FireServer(uuid)
                end
            else
                print("No pets selected.")
            end
        end)
    end,
})

MainTab:CreateButton({
    Name = "Unready Trade",
    Callback = function()
        print("Unready Trade")
        KnitServices.TradeService.RE.TradeUnaccept:FireServer()
    end,
})

MainTab:CreateButton({
    Name = "Fire All Selected Pets",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            print("Re-selecting pet with UUID:", uuid)
            KnitServices.TradeService.RE.TradeSelectPet:FireServer(uuid)
        end
    end,
})

MainTab:CreateButton({
    Name = "Make Void (select 1 evo 2 pet from dropdown)",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            KnitServices.VoidService.RE.StartCraft:FireServer(uuid)
        end
    end,
})

MainTab:CreateButton({
    Name = "Claim Void (wait 5 hours)",
    Callback = function()
        local x = KnitServices.PlayerDataService.RF.GetAllData:InvokeServer()
        if x.PetsInVoidSlot and typeof(x.PetsInVoidSlot) == "table" then
            for _, petData in pairs(x.PetsInVoidSlot) do
                if typeof(petData) == "table" and petData.UUID then
                    print("Claiming Void pet with UUID:", petData.UUID)
                    KnitServices.VoidService.RE.ClaimPet:FireServer(petData.UUID)
                end
            end
        else
            print("No pets in Void Slot.")
        end
    end,
})

MainTab:CreateButton({
    Name = "Make Titan (select 1 size 2 pet from dropdown)",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            KnitServices.TitanService.RE.StartCraft:FireServer(tostring(uuid))
        end
    end,
})

MainTab:CreateButton({
    Name = "Claim Titan (wait 5 hours)",
    Callback = function()
        local x = KnitServices.PlayerDataService.RF.GetAllData:InvokeServer()
        if x.PetsInTitanSlot and typeof(x.PetsInTitanSlot) == "table" then
            for _, petData in pairs(x.PetsInTitanSlot) do
                if typeof(petData) == "table" and petData.UUID then
                    print("Claiming Titan pet with UUID:", petData.UUID)
                    KnitServices.TitanService.RE.ClaimPet:FireServer(petData.UUID)
                end
            end
        else
            print("No pets in Titan Slot.")
        end
    end,
})





-- farming Tab
local RaceTab = Window:CreateTab("farming")
local threadsValue = 1 -- Default value for threads
local isRunning = false
local threads = {} -- Table to keep track of threads
local isContestThreadRunning = false -- Control for the separate thread

RaceTab:CreateSlider({
    Name = "Threads",
    Range = {1, 50},
    Increment = 1,
    Suffix = "threads",
    CurrentValue = threadsValue,
    Callback = function(Value)
        local previousThreadsValue = threadsValue
        threadsValue = Value

        if isRunning then
            if threadsValue > previousThreadsValue then
                -- Add more threads
                for i = previousThreadsValue + 1, threadsValue do
                    threads[i] = { isThreadRunning = true }
                    task.spawn(function()
                        local threadIndex = i
                        while isRunning and threads[threadIndex] and threads[threadIndex].isThreadRunning do
                            local args = {
                                [1] = "WinGate_16"
                            }
                            KnitServices.FightService.RE.GetWinsEvent:FireServer(unpack(args))
                            task.wait()
                        end
                    end)
                end
            elseif threadsValue < previousThreadsValue then
                -- Stop extra threads
                for i = threadsValue + 1, previousThreadsValue do
                    if threads[i] then
                        threads[i].isThreadRunning = false
                        threads[i] = nil
                    end
                end
            end
        end
    end,
})

RaceTab:CreateToggle({
    Name = "Start Farming Wins",
    CurrentValue = false,
    Callback = function(Value)
        isRunning = Value
        if isRunning then
            -- Start threads up to threadsValue
            for i = 1, threadsValue do
                threads[i] = { isThreadRunning = true }
                task.spawn(function()
                    local threadIndex = i
                    while isRunning and threads[threadIndex] and threads[threadIndex].isThreadRunning do
                        local args = {
                            [1] = "WinGate_16"
                        }
                        KnitServices.FightService.RE.GetWinsEvent:FireServer(unpack(args))
                        task.wait()
                    end
                end)
            end

            -- Start the separate thread that runs your provided code every 1 second
            isContestThreadRunning = true
            task.spawn(function()
                while isRunning and isContestThreadRunning do
                    local x = KnitServices.PlayerDataService.RF.GetAllData:InvokeServer()
                    -- Check if 'x' is a table
                    if typeof(x) == "table" then
                        local playerLocation = x["PlayerLocation"]
                        if playerLocation then
                            print(playerLocation)
                            KnitServices.FightService.RE.StartContest:FireServer(tostring(playerLocation))
                            task.wait()
                            KnitServices.FightService.RE.JoinContest:FireServer(tostring(playerLocation))
                        end
                    end
                    task.wait(1) -- Wait 1 second before next iteration
                end
            end)
        else
            -- Stop all threads
            for i = 1, #threads do
                if threads[i] then
                    threads[i].isThreadRunning = false
                end
            end
            threads = {}
            isContestThreadRunning = false

            -- Trigger the script when toggled off
            local x = KnitServices.PlayerDataService.RF.GetAllData:InvokeServer()
            if typeof(x) == "table" then
                local playerLocation = x["PlayerLocation"]
                if playerLocation then
                    print(playerLocation)
                    KnitServices.FightService.RE.QuitContestEvent:FireServer(tostring(playerLocation))
                end
            end
        end
    end,
})

local isActive1 = false

RaceTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "Toggle2",
    Callback = function(Value)
        isActive1 = Value
        print("Toggle State Changed:", Value)
        if isActive1 then
            task.spawn(function()
                while isActive1 do
                    KnitServices.RebirthService.RF.Rebirth:InvokeServer()
                    task.wait(1)
                end
            end)
        end
    end,
})

local isActive2 = false

RaceTab:CreateToggle({
    Name = "Auto Quest Egg",
    CurrentValue = false,
    Flag = "Toggle3",
    Callback = function(Value)
        isActive2 = Value
        print("Toggle State Changed:", Value)
        if isActive2 then
            task.spawn(function()
                while isActive2 do
                    KnitServices.OnlineRewardService.RF.ClaimOnlineQuestReward:InvokeServer()
                    
                    task.wait(1)
                end
            end)
        end
    end,
})

--Misc Tab
local MiscTab = Window:CreateTab("Misc")

local isActive = false

MiscTab:CreateToggle({
    Name = "Potion Spam",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        isActive = Value
        print("Toggle State Changed:", Value)
        if isActive then
            task.spawn(function()
                while isActive do
                    KnitServices.ChestService.RF.ClaimDailyChest:InvokeServer()
                    task.wait()
                end
            end)
        end
    end,
})
MiscTab:CreateButton({
    Name = "Join W2 (rejoin after clicking)",
    Callback = function()
        KnitServices.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_2")
    end,
})

MiscTab:CreateButton({
    Name = "Join W3 (rejoin after clicking)",
    Callback = function()
        KnitServices.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_3")
    end,
})

MiscTab:CreateButton({
    Name = "Super Rebirth (30+ Rebirths I think)",
    Callback = function()
        KnitServices.RebirthService.RF.SuperRebirth:InvokeServer()

    end,
})

MiscTab:CreateButton({
    Name = "Super Rebirth Upgrades",
    Callback = function()
        local x = game:GetService("Players").Cupcak3Girl2020.PlayerGui.RebirthUpgradeGui
        x.Enabled = true
    end,
})

MiscTab:CreateButton({
    Name = "Save Data",
    Callback = function()
        local x = KnitServices.PlayerDataService.RF.GetAllData:InvokeServer()
        local outputData = {}

        local function recursivePrint(tbl, indent)
            indent = indent or ""
            for key, value in pairs(tbl or {}) do
                if typeof(value) == "table" then
                    table.insert(outputData, indent .. tostring(key) .. ":")
                    recursivePrint(value, indent .. "  ")
                else
                    table.insert(outputData, indent .. tostring(key) .. ": " .. tostring(value))
                end
            end
        end

        if typeof(x) == "table" then
            recursivePrint(x)
        else
            table.insert(outputData, "'x' is not a table.")
        end

        writefile("PlayerData.txt", table.concat(outputData, "\n"))
        print("Data written to PlayerData.txt")
    end,
})

MiscTab:CreateLabel("Discord: willievibes")