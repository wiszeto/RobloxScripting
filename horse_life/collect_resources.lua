while true do 
    for i=1, 126 do 
    local args = {
        [1] = "\\" .. tostring(i)
    }
    
    game:GetService("ReplicatedStorage").Remotes.SendDropsRemote:FireServer(unpack(args))
    
    wait()
    end
    
    wait(0.1)
    end