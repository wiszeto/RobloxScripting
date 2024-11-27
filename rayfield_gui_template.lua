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

local Main = Window:CreateTab("Main", 4483362458) -- Title, Image

local Section = Main:CreateSection("Section Example")

-- Cleaner toggle implementation
local Toggle = Main:CreateToggle({
    Name = "Toggle Example",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(Value)
        if Value then
            -- Start the process when toggle is turned on
            task.spawn(function()
                while Toggle.CurrentValue do -- Access toggle state directly
                    print("Hello")
                    task.wait(0.1) -- Adjustable wait to control loop speed
                end
            end)
        else
            -- Automatically stops when toggle is off since the loop checks Toggle.CurrentValue
            print("Toggle turned off")
        end
    end,
})
