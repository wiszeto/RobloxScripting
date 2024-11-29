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
        Enabled = true,
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

local delayValue = 0

-- Create Slider
MainTab:CreateSlider({
    Name = "Set deselect time",
    Range = {0.5, 2.5},
    Increment = 0.01,
    Suffix = "seconds",
    CurrentValue = 1.3,
    Callback = function(Value)
        delayValue = Value
    end,
})

-- Fetch pet data
local petDataResponse = game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.PlayerDataService.RF.GetAllData:InvokeServer()

local petOptions = {}
local petUUIDs = {}

-- Check if 'Pets' exist and populate the dropdown options
if petDataResponse.Pets and typeof(petDataResponse.Pets) == "table" then
    for key, petData in pairs(petDataResponse.Pets) do
        if typeof(petData) == "table" then
            local optionStr = "Pet: " .. petData.PetID .. " - Evo: " .. tostring(petData.Evolution) .. " - Size: " .. tostring(petData.Size)
            table.insert(petOptions, optionStr)
            petUUIDs[optionStr] = petData.UUID
        end
    end
else
    print("No 'Pets' key or it's not a table.")
end

-- Variable to store the selected pets' UUIDs
local selectedPetUUIDs = {}
local previousOptions = {} -- To keep track of previous selections

-- Function to shallow copy a table
local function shallowCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        table.insert(copy, v)
    end
    return copy
end

-- Create Dropdown with multiple options enabled
local Dropdown = MainTab:CreateDropdown({
    Name = "Select Pets",
    Options = petOptions,
    CurrentOption = {}, -- No default selection
    MultipleOptions = true,
    Flag = "PetDropdown",
    Callback = function(Options)
        -- Create a map for the new options for faster lookup
        local newOptionMap = {}
        for _, option in ipairs(Options) do
            newOptionMap[option] = true
        end

        -- Create a map for the previous options
        local previousOptionMap = {}
        for _, option in ipairs(previousOptions) do
            previousOptionMap[option] = true
        end

        -- Find newly selected options
        for _, option in ipairs(Options) do
            if not previousOptionMap[option] then
                -- This is a newly selected option
                local uuid = petUUIDs[option]
                if uuid then
                    -- Run the TradeSelectPet function
                    local args = {uuid}
                    print("Selecting pet with UUID:", uuid) -- Debug print
                    game:GetService("ReplicatedStorage").Packages._Index
                        :FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TradeService.RE.TradeSelectPet
                        :FireServer(unpack(args))
                end
            end
        end

        -- Find deselected options
        for _, option in ipairs(previousOptions) do
            if not newOptionMap[option] then
                -- This option was deselected
                local uuid = petUUIDs[option]
                if uuid then
                    -- Run the TradeDeselectPet function
                    local args = {uuid}
                    print("Deselecting pet with UUID:", uuid) -- Debug print
                    game:GetService("ReplicatedStorage").Packages._Index
                        :FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TradeService.RE.TradeDeselectPet
                        :FireServer(unpack(args))
                end
            end
        end

        -- Update previousOptions with a copy of Options
        previousOptions = shallowCopy(Options)

        -- Update selectedPetUUIDs
        selectedPetUUIDs = {}
        for _, option in ipairs(Options) do
            local uuid = petUUIDs[option]
            if uuid then
                table.insert(selectedPetUUIDs, uuid)
            end
        end

        -- Print selected UUIDs
        print("Selected Pet UUIDs:", table.concat(selectedPetUUIDs, ", "))
    end,
})

MainTab:CreateButton({
    Name = "Accepting Trade",
    Callback = function()
        print("Accepting Trade")
        game:GetService("ReplicatedStorage").Packages._Index
            :FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TradeService.RE.TradeAccept
            :FireServer()

        local countdownDuration = 5

        -- Calculate the time to wait before printing
        local timeToWait = countdownDuration - delayValue
        if timeToWait < 0 then
            timeToWait = 0
        end

        -- Schedule the print of the UUIDs
        delay(timeToWait, function()
            if #selectedPetUUIDs > 0 then
                print("Printing UUIDs at " .. string.format("%.2f", delayValue) .. " seconds before countdown ends:")
                for _, uuid in ipairs(selectedPetUUIDs) do
                    print(uuid)
                    local args = {
                        [1] = tostring(uuid)
                    }

                    game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TradeService.RE.TradeDeselectPet:FireServer(unpack(args))

                end
            else
                print("No pets selected.")
            end
        end)
    end,
})



-- Create "Unready Trade" Button
MainTab:CreateButton({
    Name = "Unready Trade",
    Callback = function()
        print("Unready Trade")
        game:GetService("ReplicatedStorage").Packages._Index
            :FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TradeService.RE.TradeUnaccept
            :FireServer()
    end,
})


-- Add Fire All Selected Pets Button
MainTab:CreateButton({
    Name = "Fire All Selected Pets",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            -- Re-select each pet
            local args = {uuid}
            print("Re-firing pet with UUID:", uuid) -- Debug print
            game:GetService("ReplicatedStorage").Packages._Index
                :FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TradeService.RE.TradeSelectPet
                :FireServer(unpack(args))
        end
    end,
})

-- Add Fire All Selected Pets Button
MainTab:CreateButton({
    Name = "Make Void",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            -- Re-select each pet
            local args = {uuid}

game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.VoidService.RE.StartCraft:FireServer(unpack(args))

        end
    end,
})

MainTab:CreateButton({
    Name = "Claim Void (wait 1 day or smtg)",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            -- Re-select each pet
            local args = {uuid}

game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.VoidService.RE.ClaimPet:FireServer(unpack(args))

        end
    end,
})

-- Add Fire All Selected Pets Button
MainTab:CreateButton({
    Name = "Make Titan",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            -- Re-select each pet
            local args = {uuid}

game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TitanService.RE.StartCraft:FireServer(unpack(args))

        end
    end,
})

MainTab:CreateButton({
    Name = "Claim Titan (wait 1 day or smtg)",
    Callback = function()
        for _, uuid in ipairs(selectedPetUUIDs) do
            -- Re-select each pet
            local args = {uuid}


game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.TitanService.RE.ClaimPet:FireServer(unpack(args))

        end
    end,
})
