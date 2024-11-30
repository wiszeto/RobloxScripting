local eventargs = "\255"
local functionargs = "\255"


-- Define the folder you want to search
local folder = game:GetService("ReplicatedStorage")

-- Function to safely invoke RemoteFunction with timeout
local function safeInvoke(remoteFunction, timeout)
    local result
    local finished = false

    -- Create a new thread to invoke the RemoteFunction
    coroutine.wrap(function()
        local success, response = pcall(function()
            return remoteFunction:InvokeServer()
        end)
        if success then
            result = response
        else
            result = "Error invoking RemoteFunction: " .. response
        end
        finished = true
    end)()

    -- Wait for the specified timeout
    local startTime = os.clock()
    while not finished and os.clock() - startTime < timeout do
        wait()
    end

    if not finished then
        return "RemoteFunction did not respond within timeout."
    else
        return result
    end
end

for i=0, 100, 1 do 
local function findRemoteFunctionsAndEvents(folder)
    for _, descendant in pairs(folder:GetDescendants()) do
        -- Check if the object is a RemoteFunction or RemoteEvent
        if descendant:IsA("RemoteFunction") or descendant:IsA("RemoteEvent") then
            print(descendant:GetFullName() .. " - ClassName: " .. descendant.ClassName)

            if descendant:IsA("RemoteFunction") then
                local result = safeInvoke(descendant, 5) -- 5-second timeout
                print("RemoteFunction result:", result)
            end

            if descendant:IsA("RemoteEvent") then
                descendant:FireServer()
            end

            wait() -- Ensure there's a small delay to avoid overwhelming the system
        end
    end
end

-- Call the function
findRemoteFunctionsAndEvents(folder)
wait()
end


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Beamware",
    Icon = 0,
    LoadingTitle = "Beam Hub",
    LoadingSubtitle = "by willievibes",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Beamware"
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main")
local selectedRemote -- To store the currently selected remote
local remotes = {} -- To store the remote objects by name

-- Dropdown options
local remoteOptions = {}

-- Function to populate remotes dynamically
local function populateRemotes(folder)
    for _, descendant in pairs(folder:GetDescendants()) do
        if descendant:IsA("RemoteFunction") or descendant:IsA("RemoteEvent") then
            local name = descendant.Name
            table.insert(remoteOptions, name)
            remotes[name] = descendant -- Map remote names to objects
        end
    end
end

-- Call the function on ReplicatedStorage
populateRemotes(game:GetService("ReplicatedStorage"))

-- Dropdown for selecting remotes
local Dropdown = MainTab:CreateDropdown({
    Name = "Select Remote",
    Options = remoteOptions,
    CurrentOption = {}, -- No default selection
    MultipleOptions = false,
    Flag = "RemoteDropdown",
    Callback = function(option)
        selectedRemote = remotes[option] -- Update the selected remote
        print("Selected Remote:", selectedRemote and selectedRemote.Name or "None") -- Debug print
    end,
})

-- TextBox for input arguments
local ArgumentInput = MainTab:CreateInput({
    Name = "Arguments",
    CurrentValue = "",
    PlaceholderText = "Enter arguments (comma-separated)",
    RemoveTextAfterFocusLost = false,
    Flag = "ArgumentInput"
})

-- Button to fire the selected remote
MainTab:CreateButton({
    Name = "Fire Remote",
    Callback = function()
        if selectedRemote then
            local args = ArgumentInput.CurrentValue:split(",") -- Split arguments into a table
            if selectedRemote:IsA("RemoteEvent") then
                selectedRemote:FireServer(unpack(args))
                print("Fired RemoteEvent:", selectedRemote.Name, "with arguments:", table.concat(args, ", "))
            elseif selectedRemote:IsA("RemoteFunction") then
                local result = selectedRemote:InvokeServer(unpack(args))
                print("Invoked RemoteFunction:", selectedRemote.Name, "Result:", result)
            end
        else
            print("No remote selected.") -- Debug message
        end
    end,
})

-- Toggle for loop firing the selected remote
MainTab:CreateToggle({
    Name = "Loop Fire Remote",
    CurrentValue = false,
    Flag = "LoopToggle",
    Callback = function(value)
        if value and selectedRemote then
            task.spawn(function()
                while value do
                    local args = ArgumentInput.CurrentValue:split(",")
                    if selectedRemote:IsA("RemoteEvent") then
                        selectedRemote:FireServer(unpack(args))
                    elseif selectedRemote:IsA("RemoteFunction") then
                        local result = selectedRemote:InvokeServer(unpack(args))
                        print("Loop Invoked RemoteFunction:", result)
                    end
                    task.wait(0.5) -- Adjust loop speed as needed
                end
            end)
        else
            if not selectedRemote then
                print("No remote selected for loop.") -- Debug message
            end
        end
    end,
})
