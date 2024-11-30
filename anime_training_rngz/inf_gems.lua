while true do 
    local args = {
        [1] = "Kakashi"
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("BossSystem"):WaitForChild("Remotes"):WaitForChild("StartBossFight"):FireServer(unpack(args))
    
    
    local args = {
        [1] = game:GetService("Players").LocalPlayer.Character.Melee,
        [2] = {
            ["p"] = Vector3.new(529.9826049804688, 44.036231994628906, -1807.618408203125),
            ["name"] = "Kakashi_7545704974_1",
            ["h"] = workspace:WaitForChild("MaidPool"):WaitForChild("Kakashi"):WaitForChild("Humanoid"),
            ["part"] = workspace:WaitForChild("MaidPool"):WaitForChild("Kakashi"):WaitForChild("Melee"):WaitForChild("Handle"),
            ["t"] = 0.014259769581258297,
            ["m"] = Enum.Material.Plastic,
            ["n"] = Vector3.new(0.37481051683425903, -0.124080590903759, 0.9187606573104858)
        }
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("WeaponSystem"):WaitForChild("Remotes"):WaitForChild("WeaponHit"):FireServer(unpack(args))
    wait()
    end