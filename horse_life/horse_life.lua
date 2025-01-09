wait(5)
---------------------------------------------------------------------
--// CONFIG SYSTEM
---------------------------------------------------------------------
local HttpService = game:GetService("HttpService")
local configPath = "beamware.json"

local function readFile(path)
    local success, result = pcall(function()
        return readfile(path)
    end)
    if success then
        return result
    end
    return nil
end

local function writeFile(path, content)
    local success, err = pcall(function()
        writefile(path, content)
    end)
    if not success then
        warn("Failed to write to file:", err)
    end
end

local defaultFoods = {
    "Helianthus", "OatMuffin", "Fawnberry", "BasicFeed", "BrightPansies", "ChocolateCookie",
    "Pineberry", "Pansies", "HayCubes", "SugarCubes", "Peach", "OatTreats", "Mints", "PeppermintCookie",
    "Daylilies", "WhiteCarrot", "CarrotMuffin", "AlfalfaCubes", "AppleMuffin", "Strawberry", "Apple", "Candycanes",
    "WhitePeach", "Carrot", "GreenApple", "Peppermint", "PinkPrincessApple", "VibrantDaylilies", "MintMuffin",
}

local Config = {
    AutoFarm = false,
    AutoSell = false,
    SelectedResources = {},
    ResourceFarm = false,
    ToggleBoost = false,

    BreedAllRandom = false,
    SelectedFoods = defaultFoods,
    AutoFeedAll = false,
    AutoClaimChild = false,

    AutoFarmFoodLasso = false,
}

local savedConfig = readFile(configPath)
if savedConfig then
    local success, data = pcall(function()
        return HttpService:JSONDecode(savedConfig)
    end)
    if success and type(data) == "table" then
        for k, v in pairs(Config) do
            if data[k] == nil then
                data[k] = v
            end
        end
        Config = data
    else
        warn("beamware.json is corrupted or invalid. Using default config.")
    end
else
    writeFile(configPath, HttpService:JSONEncode(Config))
end

---------------------------------------------------------------------
--// Load Rayfield
---------------------------------------------------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

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

---------------------------------------------------------------------
--// Services and Locals
---------------------------------------------------------------------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local gui = player:WaitForChild("PlayerGui")
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

---------------------------------------------------------------------
--// Tabs
---------------------------------------------------------------------
local DevTab = Window:CreateTab("Dev")
local MainTab = Window:CreateTab("Main")
local BreedTab = Window:CreateTab("Breeding")
local MiscTab = Window:CreateTab("Misc")

local function saveConfig()
    local encoded = HttpService:JSONEncode(Config)
    writeFile(configPath, encoded)
    Rayfield:Notify({
        Title = "Beamware",
        Content = "Config has been saved!",
        Duration = 3,
        Image = 0
    })
    print("Config saved to beamware.json")
end

---------------------------------------------------------------------
--// HOTBAR UTILS
---------------------------------------------------------------------
local function setHotbarItem(slotIndex, itemName)
    ReplicatedStorage.Remotes.SetHotbarRemote:InvokeServer(tostring(slotIndex), itemName)
end

local function selectHotbarSlot(slotIndex)
    local hud = player.PlayerGui:FindFirstChild("HUDGui")
    if not hud then return end

    local slotButton = hud.BottomFrame.Other.Bottom:FindFirstChild("Slot" .. slotIndex)
        and hud.BottomFrame.Other.Bottom["Slot" .. slotIndex]:FindFirstChild("Menu")

    if slotButton and (slotButton:IsA("ImageButton") or slotButton:IsA("TextButton")) then
        local connections = getconnections(slotButton.MouseButton1Click)
        for i = 2, #connections do
            connections[i]:Fire()
        end
    end
end

---------------------------------------------------------------------
--// DevTab Buttons
---------------------------------------------------------------------
DevTab:CreateButton({
    Name = "Dark Dex v3",
    Callback = function()
        loadstring(
            game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua", true)
        )()
    end,
})

DevTab:CreateButton({
    Name = "SimplySpy",
    Callback = function()
        loadstring(
            game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua")
        )()
    end,
})

DevTab:CreateButton({
    Name = "Infinite Yield FE",
    Callback = function()
        loadstring(
            game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        )()
    end,
})

DevTab:CreateButton({
    Name = "Hydroxide",
    Callback = function()
        local owner = "Upbolt"
        local branch = "revision"
        local function webImport(file)
            return loadstring(
                game:HttpGetAsync(
                    ("https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua"):format(owner, branch, file)
                ),
                file .. ".lua"
            )()
        end
        webImport("init")
        webImport("ui/main")
    end,
})

---------------------------------------------------------------------
--// Horse Taming Utilities
---------------------------------------------------------------------
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

-- Return how many times we fed the horse
local function tameHorseGenericReturnFeedCount(horse, itemName)
    if not horse or not horse:FindFirstChild("TameEvent") then return 0 end
    
    if character and character.PrimaryPart then
        character:SetPrimaryPartCFrame(CFrame.new(horse.Position) + Vector3.new(0, 10, 0))
    else
        warn("Character or PrimaryPart not found!")
        return 0
    end

    local tameEvent = horse:FindFirstChild("TameEvent")
    if not tameEvent then return 0 end

    task.wait(0.2)
    tameEvent:FireServer("Begin")
    task.wait(0.1)

    local heartsContainer = waitForHeartsGUI(horse, 5)
    if not heartsContainer then
        return 0
    end

    local lastHearts = checkHearts(heartsContainer)
    local sameHeartsTime = tick()
    local continueLoop = false
    local firstTime = true
    local feedCount = 0

    while true do
        local currentHearts = checkHearts(heartsContainer)
        tameEvent = horse:FindFirstChild("TameEvent")

        if currentHearts == 0 or not tameEvent then
            break
        end

        if currentHearts < lastHearts then
            lastHearts = currentHearts
            sameHeartsTime = tick()
            continueLoop = true
        elseif currentHearts == lastHearts then
            continueLoop = false

            if tick() - sameHeartsTime > 5 then
                print("Hearts not decreasing for 5 seconds. Exiting tame loop.")
                break
            else
                task.wait(0.1)
            end

            if firstTime then
                if itemName == "SugarMuffin" then
                    ReplicatedStorage.Remotes.PurchaseItemRemote:InvokeServer("SugarMuffin", 1)
                end
                tameEvent:FireServer("SuccessfulFeed")
                feedCount += 1
                firstTime = false
            end
        end

        if continueLoop then
            if itemName == "SugarMuffin" then
                ReplicatedStorage.Remotes.PurchaseItemRemote:InvokeServer("SugarMuffin", 1)
            end
            task.wait(0.45)
            tameEvent:FireServer("SuccessfulFeed")
            feedCount += 1
        end
    end
    return feedCount
end

---------------------------------------------------------------------
--// Leftover Foods Logic for AutoFarm
---------------------------------------------------------------------
local BadFoods = {
    ["MysticFeed"] = true,
    ["GoldApple"] = true,
    ["PremiumFeed"] = true,
    ["ExclusiveFeed"] = true,
    ["SugarMuffin"] = true, -- skipping sugar from leftover
}

local leftoverFoods = {}
local currentFoodIndex = 1
local fallbackToSugar = false

local function scanFoodFolder()
    leftoverFoods = {}
    currentFoodIndex = 1
    fallbackToSugar = false

    local foodFolder = player.PlayerGui.Data:WaitForChild("Food")
    for _, itemObj in ipairs(foodFolder:GetChildren()) do
        local itemName = tostring(itemObj)
        local itemCount = itemObj.Value
        if (itemCount > 4) and (not BadFoods[itemName]) then
            table.insert(leftoverFoods, { name = itemName, count = itemCount })
        end
    end
end

local function getCurrentLeftoverFood()
    if fallbackToSugar then
        return nil
    end
    if #leftoverFoods == 0 then
        fallbackToSugar = true
        return nil
    end

    while currentFoodIndex <= #leftoverFoods do
        local info = leftoverFoods[currentFoodIndex]
        if info.count > 4 then
            return info.name
        else
            currentFoodIndex += 1
        end
    end
    fallbackToSugar = true
    return nil
end

---------------------------------------------------------------------
--// MainTab: Auto Farm
---------------------------------------------------------------------
local Autofarm = Config.AutoFarm

-- (NEW) We'll track the last item used to avoid re-selecting slot 3 if it didn't change
local lastFoodName = nil

local autofarmToggle = MainTab:CreateToggle({
    Name = "Toggle Auto farm",
    CurrentValue = Autofarm,
    Flag = "Autofarm",
    Callback = function(Value)
        Autofarm = Value
        print("Toggle State Changed:", Value)

        if Autofarm then
            -- slot 2 = sugar fallback
            setHotbarItem(2, "SugarMuffin")
            selectHotbarSlot(2)

            -- build leftoverFoods once
            scanFoodFolder()

            lastFoodName = nil  -- (NEW) reset

            task.spawn(function()
                while Autofarm do
                    for _, mob in ipairs(Workspace:WaitForChild("MobFolder"):GetChildren()) do
                        if not Autofarm then break end
                        if mob:FindFirstChild("TameEvent") and mob.Name == "Horse" then

                            local leftoverName = getCurrentLeftoverFood()
                            if leftoverName then
                                -- only set and select slot 3 if leftoverName changed
                                if leftoverName ~= lastFoodName then
                                    setHotbarItem(3, leftoverName)
                                    selectHotbarSlot(3)
                                    lastFoodName = leftoverName
                                end

                                -- Tame
                                local feedUsed = tameHorseGenericReturnFeedCount(mob, leftoverName)

                                -- Decrement leftover count
                                local info = leftoverFoods[currentFoodIndex]
                                if info then
                                    info.count = math.max(info.count - feedUsed, 0)
                                end
                            else
                                -- fallback to sugar
                                -- only select slot 2 if we were not already on sugar
                                if lastFoodName ~= "SugarMuffin" then
                                    selectHotbarSlot(2)
                                    lastFoodName = "SugarMuffin"
                                end
                                tameHorseGenericReturnFeedCount(mob, "SugarMuffin")
                            end

                            task.wait()
                        end
                    end

                    task.wait()
                end
            end)
        end
    end,
})

if Autofarm then
    autofarmToggle.Callback(true)
end

---------------------------------------------------------------------
--// MainTab: Auto farm Food/Lasso (unchanged)
---------------------------------------------------------------------
local autofarmFoodLasso = Config.AutoFarmFoodLasso
local useFood = true

local autofarmFoodLassoToggle = MainTab:CreateToggle({
    Name = "Auto farm Food/Lasso",
    CurrentValue = autofarmFoodLasso,
    Flag = "AutofarmFoodLasso",
    Callback = function(Value)
        autofarmFoodLasso = Value
        print("Autofarm Food/Lasso toggled:", Value)

        if autofarmFoodLasso then
            setHotbarItem(2, "SugarMuffin")
            setHotbarItem(3, "WovenLasso")

            task.spawn(function()
                while autofarmFoodLasso do
                    for _, mob in ipairs(Workspace.MobFolder:GetChildren()) do
                        if not autofarmFoodLasso then break end
                        if mob:FindFirstChild("TameEvent") and mob.Name == "Horse" then
                            useFood = not useFood
                            local item = useFood and "SugarMuffin" or "WovenLasso"
                            local slotToSelect = useFood and 2 or 3
                            selectHotbarSlot(slotToSelect)
                            tameHorseGenericReturnFeedCount(mob, item)
                            task.wait()
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

if autofarmFoodLasso then
    autofarmFoodLassoToggle.Callback(true)
end

---------------------------------------------------------------------
--// MainTab: Auto Sell
---------------------------------------------------------------------
local AutoSell = Config.AutoSell
local horses = {}

local autoSellToggle = MainTab:CreateToggle({
    Name = "Toggle Auto Sell New Horses",
    CurrentValue = AutoSell,
    Flag = "AutoSell",
    Callback = function(Value)
        AutoSell = Value
        print("Toggle State Changed:", Value)

        local sellgui = player:FindFirstChild("PlayerGui")
            and player.PlayerGui:FindFirstChild("DisplayAnimalGui")

        if AutoSell then
            if sellgui then
                sellgui.Enabled = false
            end

            for _, v in ipairs(gui.Data.Animals:GetChildren()) do
                table.insert(horses, tostring(v))
            end

            task.spawn(function()
                while AutoSell do
                    local currentAnimals = gui.Data.Animals:GetChildren()
                    local currentHorseNames = {}
                    for _, animal in ipairs(currentAnimals) do
                        currentHorseNames[tostring(animal)] = true
                    end

                    for _, animal in ipairs(currentAnimals) do
                        local animalName = tostring(animal)
                        if not table.find(horses, animalName) then
                            local args = {[1] = {[1] = animalName}}
                            ReplicatedStorage.Remotes.SellSlotsRemote:InvokeServer(unpack(args))
                            print("sold")
                        end
                    end
                    task.wait()
                end
            end)
        else
            horses = {}
            if sellgui then
                sellgui.Enabled = true
            end
        end
    end,
})

if AutoSell then
    autoSellToggle.Callback(true)
end

---------------------------------------------------------------------
--// MainTab: Resource Farm
---------------------------------------------------------------------
local ResourceFolder = Workspace.Interactions.Resource
local ResourceOptions = {}
local uniqueResources = {}

for _, resource in ipairs(ResourceFolder:GetChildren()) do
    if not uniqueResources[resource.Name] then
        uniqueResources[resource.Name] = true
        table.insert(ResourceOptions, resource.Name)
    end
end

local selectedResources = Config.SelectedResources or {}
local resourceDropdown = MainTab:CreateDropdown({
    Name = "Resource Select",
    Options = ResourceOptions,
    CurrentOption = selectedResources,
    MultipleOptions = true,
    Flag = "ResourceDropdown",
    Callback = function(Options)
        selectedResources = Options
    end,
})

local ResourceFarm = Config.ResourceFarm

local resourceFarmToggle = MainTab:CreateToggle({
    Name = "Toggle Resource Farm",
    CurrentValue = ResourceFarm,
    Flag = "ResourceFarm",
    Callback = function(Value)
        ResourceFarm = Value
        print("ResourceFarm Toggle State:", Value)

        if ResourceFarm then
            task.spawn(function()
                while ResourceFarm do
                    if #selectedResources == 0 then
                        warn("No Resources selected for farming!")
                        break
                    end

                    for _, resourceName in ipairs(selectedResources) do
                        if not ResourceFarm then break end
                        local resourceNode = ResourceFolder:FindFirstChild(resourceName)
                        local attempts = 3
                        while not (resourceNode and resourceNode:IsDescendantOf(ResourceFolder)) and attempts > 0 do
                            task.wait(0.1)
                            resourceNode = ResourceFolder:FindFirstChild(resourceName)
                            attempts -= 1
                        end

                        if resourceNode and resourceNode:IsDescendantOf(ResourceFolder) then
                            local hitbox = resourceNode:FindFirstChild("Hitbox")
                            local guiObj = resourceNode:FindFirstChild("DefaultResourceNodeGui")

                            if hitbox and guiObj then
                                local clickDetector = resourceNode:FindFirstChild("ClickDetector")
                                if clickDetector then
                                    fireclickdetector(clickDetector)
                                    for _, guiItem in ipairs(player.PlayerGui.Data.Animals:GetChildren()) do
                                        if guiItem.Equipped.Value then
                                            local args = {
                                                [1] = character.Animals:FindFirstChild(tostring(guiItem))
                                            }
                                            resourceNode.RemoteEvent:FireServer(unpack(args))
                                        end
                                    end
                                end
                                print("Interacting with:", resourceName)

                                task.wait(0.1)
                                if character and character.PrimaryPart then
                                    character:SetPrimaryPartCFrame(
                                        CFrame.new(hitbox.Position) + Vector3.new(0, 25, 0)
                                    )
                                else
                                    warn("Character or PrimaryPart not found!")
                                end

                                local startTime = os.clock()
                                while resourceNode.Parent ~= nil do
                                    if not ResourceFarm then break end
                                    if os.clock() - startTime > 25 then
                                        warn("Timeout reached for resource: " .. resourceName)
                                        break
                                    end
                                    task.wait()
                                end
                            else
                                warn(resourceName .. " is missing required parts.")
                            end
                        else
                            warn("Selected resource not found:", resourceName)
                        end
                    end

                    if not ResourceFarm then
                        print("Resource Farm fully stopped.")
                        break
                    end

                    task.wait()
                end
            end)
        end
    end,
})

if ResourceFarm then
    resourceFarmToggle.Callback(true)
end

---------------------------------------------------------------------
--// MainTab: Lock-On System
---------------------------------------------------------------------
local mobFolder = Workspace:WaitForChild("MobFolder")
local distanceBehind, distanceUp, angleAround = 15, 5, 0
local connection, lockedTarget = nil, nil

local function findClosestPart()
    local playerPos = humanoidRootPart.Position
    local closest, minDist = nil, math.huge
    for _, part in pairs(mobFolder:GetChildren()) do
        if part:IsA("BasePart") then
            local dist = (part.Position - playerPos).Magnitude
            if dist < minDist then
                closest, minDist = part, dist
            end
        end
    end
    return closest
end

local function getRidingHorse()
    local seatPart = humanoid.SeatPart
    if seatPart and seatPart.Parent:FindFirstChild("HumanoidRootPart") then
        return seatPart.Parent
    end
    return nil
end

local function positionBehindTarget()
    if not (lockedTarget and lockedTarget:IsDescendantOf(Workspace)) then
        return
    end

    local radians = math.rad(angleAround)
    local offset = Vector3.new(
        math.cos(radians) * distanceBehind,
        distanceUp,
        math.sin(radians) * distanceBehind
    )
    local targetPosition = lockedTarget.Position + offset

    if character and humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.RotVelocity = Vector3.zero
    end

    local mount = getRidingHorse()
    if mount and mount.PrimaryPart then
        mount:SetPrimaryPartCFrame(CFrame.new(targetPosition, lockedTarget.Position))
    else
        humanoidRootPart.CFrame = CFrame.new(targetPosition, lockedTarget.Position)
    end
end

local StatesToDisable = {
    Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Physics
}

local function disableStates(humanoid, disable)
    for _, state in ipairs(StatesToDisable) do
        humanoid:SetStateEnabled(state, not disable)
    end
end

MainTab:CreateSlider({
    Name = "Lock-On Distance",
    Range = {-100, 100},
    Increment = 1,
    Suffix = "Units",
    CurrentValue = distanceBehind,
    Flag = "LockOnDistance",
    Callback = function(Value)
        distanceBehind = Value
        print("Lock-On Distance updated to:", Value)
    end,
})

MainTab:CreateSlider({
    Name = "Distance Up",
    Range = {-50, 350},
    Increment = 1,
    Suffix = "Units",
    CurrentValue = distanceUp,
    Flag = "DistanceUp",
    Callback = function(Value)
        distanceUp = Value
        print("Distance Up updated to:", Value)
    end,
})

MainTab:CreateSlider({
    Name = "Angle Around",
    Range = {0, 360},
    Increment = 1,
    Suffix = "Degrees",
    CurrentValue = angleAround,
    Flag = "AngleAround",
    Callback = function(Value)
        angleAround = Value
        print("Angle Around updated to:", Value)
    end,
})

local LockCloset = false
MainTab:CreateToggle({
    Name = "Lock onto Closest Horse",
    CurrentValue = false,
    Flag = "LockCloset",
    Callback = function(Value)
        LockCloset = Value
        print("Toggle State Changed:", Value)

        if LockCloset then
            disableStates(humanoid, true)
            connection = RunService.RenderStepped:Connect(function()
                if not (lockedTarget and lockedTarget:IsDescendantOf(Workspace)) then
                    lockedTarget = findClosestPart()
                end
                if lockedTarget then
                    positionBehindTarget()
                end
            end)
        else
            disableStates(humanoid, false)
            if connection then
                connection:Disconnect()
                connection = nil
            end
            lockedTarget = nil
        end
    end,
})

---------------------------------------------------------------------
--// MainTab: Speed Boost
---------------------------------------------------------------------
local BoostActive = Config.ToggleBoost
local boostToggle = MainTab:CreateToggle({
    Name = "Toggle Boost",
    CurrentValue = BoostActive,
    Flag = "ToggleBoost",
    Callback = function(Value)
        BoostActive = Value
        print("Toggle State Changed:", Value)

        if BoostActive then
            task.spawn(function()
                while BoostActive do
                    Workspace.BoostPads.Speed.RemoteEvent:FireServer()
                    task.wait(0.5)
                end
            end)
        end
    end,
})

if BoostActive then
    boostToggle.Callback(true)
end

---------------------------------------------------------------------
--// BreedTab: Breed All Random (TOGGLE)
---------------------------------------------------------------------
local BreedAllRandom = Config.BreedAllRandom

local function doRandomBreed()
    local animalFolder = player.PlayerGui.Data.Animals
    local childrenFolder = player.PlayerGui.Data.Children

    local function getParentSerials()
        local parentSerials = {}
        for _, child in ipairs(childrenFolder:GetChildren()) do
            parentSerials[child.Mother.Value] = true
            parentSerials[child.Father.Value] = true
        end
        return parentSerials
    end

    local function groupAnimals(parentSerials)
        local males, females = {}, {}
        for _, animal in ipairs(animalFolder:GetChildren()) do
            local serial = animal.Serial.Value
            local gender = animal.Gender.Value
            local infertile = animal.Infertile.Value

            if not parentSerials[serial] and not infertile then
                if gender == "Male" then
                    table.insert(males, animal)
                elseif gender == "Female" then
                    table.insert(females, animal)
                end
            end
        end
        return males, females
    end

    local function autoBreed()
        local parentSerials = getParentSerials()
        local males, females = groupAnimals(parentSerials)
        local numPairs = math.min(#males, #females)

        for i = 1, numPairs do
            local args = {
                [1] = tostring(males[i]),
                [2] = tostring(females[i])
            }
            ReplicatedStorage.Remotes.BreedSlotsRemote:InvokeServer(unpack(args))
            print("Breeding invoked for:", males[i].Name, females[i].Name)
        end
    end

    autoBreed()
end

local breedAllRandomToggle = BreedTab:CreateToggle({
    Name = "Breed All Random (Toggle)",
    CurrentValue = BreedAllRandom,
    Flag = "BreedAllRandom",
    Callback = function(Value)
        BreedAllRandom = Value
        print("Breed All Random Toggled:", Value)

        if BreedAllRandom then
            task.spawn(function()
                while BreedAllRandom do
                    doRandomBreed()
                    task.wait(5) 
                end
            end)
        end
    end,
})

if BreedAllRandom then
    breedAllRandomToggle.Callback(true)
end

---------------------------------------------------------------------
--// BREEDING: SELECT 2 HORSES
---------------------------------------------------------------------
local animalFolder = player.PlayerGui.Data.Animals
local HorseList = {}
local HorseMap = {}

for _, animal in ipairs(animalFolder:GetChildren()) do
    local serial = animal:FindFirstChild("Serial") and animal.Serial.Value or "???"
    local gender = animal:FindFirstChild("Gender") and animal.Gender.Value or "???"
    local label = string.format("Serial:%s Gender:%s", tostring(serial), tostring(gender))
    table.insert(HorseList, label)
    HorseMap[label] = animal
end

local selectedHorses = {}
local horseDropdown = BreedTab:CreateDropdown({
    Name = "Pick 2 Horses",
    Options = HorseList,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "HorseDropdown",
    Callback = function(options)
        selectedHorses = options
        print("Selected Horses:", table.concat(selectedHorses, ", "))
    end,
})

local breed2Toggle = false
BreedTab:CreateToggle({
    Name = "Breed 2 Horses",
    CurrentValue = false,
    Flag = "Breed2Toggle",
    Callback = function(Value)
        breed2Toggle = Value
        print("Breed 2 Horses Toggled:", Value)

        if breed2Toggle then
            task.spawn(function()
                while breed2Toggle do
                    if #selectedHorses == 2 then
                        local horseLabel1 = selectedHorses[1]
                        local horseLabel2 = selectedHorses[2]
                        local horse1 = HorseMap[horseLabel1]
                        local horse2 = HorseMap[horseLabel2]

                        if horse1 and horse2 then
                            local gender1 = horse1.Gender.Value
                            local gender2 = horse2.Gender.Value

                            if gender1 == "Male" and gender2 == "Female" then
                                local args = { tostring(horse1), tostring(horse2) }
                                ReplicatedStorage.Remotes.BreedSlotsRemote:InvokeServer(unpack(args))
                                print("Breeding invoked for:", horse1.Name, horse2.Name)
                            elseif gender1 == "Female" and gender2 == "Male" then
                                local args = { tostring(horse2), tostring(horse1) }
                                ReplicatedStorage.Remotes.BreedSlotsRemote:InvokeServer(unpack(args))
                                print("Breeding invoked for:", horse2.Name, horse1.Name)
                            else
                                print("Please pick one male and one female!")
                            end
                        end
                    else
                        print("Please select exactly 2 horses in the dropdown.")
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

---------------------------------------------------------------------
--// BreedTab: Food Dropdown & Auto Feed All
---------------------------------------------------------------------
local foodFolder = player.PlayerGui.Data:WaitForChild("Food")

local foodOptions = {}
for _, foodItem in ipairs(foodFolder:GetChildren()) do
    table.insert(foodOptions, foodItem.Name)
end

local selectedFoods = Config.SelectedFoods or defaultFoods
local foodDropdown = BreedTab:CreateDropdown({
    Name = "Select Food",
    Options = foodOptions,
    CurrentOption = selectedFoods,
    MultipleOptions = true,
    Flag = "FoodDropdown",
    Callback = function(options)
        selectedFoods = options
        Config.SelectedFoods = options
        print("Selected foods:", table.concat(selectedFoods, ", "))
    end,
})

local AutoFeedAll = Config.AutoFeedAll
local autoFeedAllToggle = BreedTab:CreateToggle({
    Name = "Auto Feed All Horses",
    CurrentValue = AutoFeedAll,
    Flag = "AutoFeedAll",
    Callback = function(Value)
        AutoFeedAll = Value
        print("Toggle State Changed:", Value)

        if AutoFeedAll then
            task.spawn(function()
                while AutoFeedAll do
                    for _, animal in ipairs(player.PlayerGui.Data.Animals:GetChildren()) do
                        for _, food in ipairs(selectedFoods) do
                            local args = {
                                [1] = tostring(animal),
                                [2] = tostring(food),
                                [3] = 1000
                            }
                            ReplicatedStorage.Remotes.GiveConsumableRemote:InvokeServer(unpack(args))
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end,
})

if AutoFeedAll then
    autoFeedAllToggle.Callback(true)
end

---------------------------------------------------------------------
--// BREEDING: AUTO FEED TWO SELECTED HORSES ONLY
---------------------------------------------------------------------
local AutoFeed2 = false
BreedTab:CreateToggle({
    Name = "Auto Feed (Only the 2 selected horses)",
    CurrentValue = false,
    Flag = "AutoFeed2",
    Callback = function(Value)
        AutoFeed2 = Value
        print("Auto Feed 2 Horses Toggled:", Value)

        if AutoFeed2 then
            task.spawn(function()
                while AutoFeed2 do
                    if #selectedHorses == 2 then
                        for _, horseLabel in ipairs(selectedHorses) do
                            local horseInstance = HorseMap[horseLabel]
                            if horseInstance then
                                for _, food in ipairs(selectedFoods) do
                                    local args = {
                                        tostring(horseInstance),
                                        tostring(food),
                                        1000
                                    }
                                    ReplicatedStorage.Remotes.GiveConsumableRemote:InvokeServer(unpack(args))
                                end
                            end
                        end
                    else
                        print("You must pick exactly 2 horses in the dropdown for Auto Feed.")
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

---------------------------------------------------------------------
--// BreedTab: Auto Claim Child
---------------------------------------------------------------------
local folder = player.PlayerGui.Data.Animals
local AutoClaimChild = Config.AutoClaimChild
local autoClaimChildToggle = BreedTab:CreateToggle({
    Name = "Auto Claim Child",
    CurrentValue = AutoClaimChild,
    Flag = "AutoClaimChild",
    Callback = function(Value)
        AutoClaimChild = Value
        print("Toggle State Changed:", Value)

        if AutoClaimChild then
            task.spawn(function()
                while AutoClaimChild do
                    for _, horse in ipairs(folder:GetChildren()) do
                        ReplicatedStorage.Remotes.BirthSlotRemote:InvokeServer(tostring(horse))
                    end
                    task.wait(0.5)
                end
            end)
        end
    end,
})

if AutoClaimChild then
    autoClaimChildToggle.Callback(true)
end

---------------------------------------------------------------------
--// MiscTab
---------------------------------------------------------------------
local function createPurchaseUI(tab, itemName, maxCount)
    local count = 0

    tab:CreateSlider({
        Name = itemName .. "s to Buy",
        Range = {0, maxCount},
        Increment = 1,
        Suffix = "x",
        CurrentValue = 0,
        Callback = function(Value)
            count = Value
            print(itemName, "slider:", Value)
        end,
    })

    tab:CreateButton({
        Name = "Buy Selected " .. itemName .. "s",
        Callback = function()
            if count > 0 then
                ReplicatedStorage.Remotes.PurchaseItemRemote:InvokeServer(itemName, count)
                print("Bought", count, itemName .. "(s)")
            else
                print("Slider is at 0, no", itemName, "purchased.")
            end
        end,
    })
end

createPurchaseUI(MiscTab, "SugarMuffin", 100)
createPurchaseUI(MiscTab, "WovenLasso", 100)

MiscTab:CreateButton({
    Name = "Ride horse",
    Callback = function()
        local player = game.Players.LocalPlayer
        local wsg = player:WaitForChild("PlayerGui"):WaitForChild("WorkspaceGui")
        local animals = workspace:WaitForChild("Characters"):WaitForChild(player.Name):WaitForChild("Animals")

        for _, animal in ipairs(animals:GetChildren()) do
            local uiPath = "Workspace.Characters."..player.Name..".Animals."
                        ..animal.Name..".RootPart.MiddleBody.UpperBody"

            local upperBody = wsg:FindFirstChild(uiPath)
            if upperBody then
                local optionsFrame = upperBody.ContainerFrame.OptionsFrame
                for _, button in ipairs(optionsFrame:GetChildren()) do
                    if button.Name == "Default"
                       and button:FindFirstChild("ActionHintLabel")
                       and button.ActionHintLabel.Text == "Ride"
                    then
                        firesignal(button.MouseButton1Down)
                    end
                end
            end
        end
    end,
})

MiscTab:CreateLabel("Discord: willievibes")

MiscTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        Config.AutoFarm = Autofarm
        Config.AutoSell = AutoSell
        Config.SelectedResources = selectedResources
        Config.ResourceFarm = ResourceFarm
        Config.ToggleBoost = BoostActive

        Config.BreedAllRandom = BreedAllRandom
        Config.AutoFeedAll = AutoFeedAll
        Config.AutoClaimChild = AutoClaimChild

        Config.AutoFarmFoodLasso = autofarmFoodLasso
        saveConfig()
    end,
})
