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

MainTab:CreateButton({
    Name = "Join W3 (rejoin after clicking)",
    Callback = function()
        KnitServices.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_3")
    end,
})

MainTab:CreateButton({
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

local isActive = false

MainTab:CreateToggle({
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


local RaceTab = Window:CreateTab("Racing")
local threadsValue = 1 -- Default value for threads

RaceTab:CreateSlider({
    Name = "Threads",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "threads",
    CurrentValue = threadsValue,
    Callback = function(Value)
        threadsValue = Value
    end,
})

local isRunning = false

RaceTab:CreateToggle({
    Name = "Start Farming Wins",
    CurrentValue = false,
    Callback = function(Value)
        isRunning = Value
        if isRunning then
            for i = 1, threadsValue do
                task.spawn(function()
                    while isRunning do
                        local args = {
                            [1] = "WinGate_16"
                        }
                        game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.FightService.RE.GetWinsEvent:FireServer(unpack(args))
                        task.wait()
                    end
                end)
            end
        end
    end,
})