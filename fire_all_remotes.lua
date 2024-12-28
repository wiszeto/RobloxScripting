-- Define the folder you want to search
local folder = game:GetService("ReplicatedStorage")

-- Function to safely invoke a RemoteFunction with a specified timeout and iteration parameter
local function safeInvoke(remoteFunction, timeout, i)
    local result
    local finished = false

    coroutine.wrap(function()
        local success, response = pcall(function()
            return remoteFunction:InvokeServer(i)
        end)

        if success then
            result = response
        else
            result = "Error invoking RemoteFunction: " .. tostring(response)
        end
        finished = true
    end)()

    local startTime = os.clock()
    while not finished and (os.clock() - startTime) < timeout do
        task.wait()
    end

    if not finished then
        return "RemoteFunction did not respond within the timeout."
    end

    return result
end

-- Function to find and interact with RemoteFunctions and RemoteEvents in the folder
local function findRemoteFunctionsAndEvents(targetFolder, i)
    for _, descendant in ipairs(targetFolder:GetDescendants()) do
        if descendant:IsA("RemoteFunction") then
            print(string.format("%s - ClassName: %s (Iteration: %d)", descendant:GetFullName(), descendant.ClassName, i))
            local result = safeInvoke(descendant, 5, i)
            print("RemoteFunction result:", result)
            task.wait()
        elseif descendant:IsA("RemoteEvent") then
            print(string.format("%s - ClassName: %s (Iteration: %d)", descendant:GetFullName(), descendant.ClassName, i))
            descendant:FireServer(i)
            task.wait()
        end
    end
end

-- Run the function 100 times, passing the iteration index as a parameter
for i = 1, 100 do
    findRemoteFunctionsAndEvents(folder, i)
    task.wait()
end
