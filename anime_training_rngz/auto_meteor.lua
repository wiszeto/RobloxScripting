while true do
    local x = game:GetService("Players").FNwillie.PlayerGui.MainUI.ShowBoosts.RightBottom.Weather.Weather.Name
    
    -- Keep firing the remote until x is "[ Meteor ]"
    while x ~= "[  Meteor  ]" do
        game:GetService("ReplicatedStorage").WeatherSystem.Remotes.TransitWeather:FireServer()
        wait(0.3)  -- Small delay to prevent potential lag
        x = game:GetService("Players").FNwillie.PlayerGui.MainUI.ShowBoosts.RightBottom.Weather.Weather.Text
        print(x)
    end
    
    -- Once x is "[ Meteor ]", wait until it changes to something else
    repeat
        wait()
        x = game:GetService("Players").FNwillie.PlayerGui.MainUI.ShowBoosts.RightBottom.Weather.Weather.Text
    until x ~= "[  Meteor  ]"

end
