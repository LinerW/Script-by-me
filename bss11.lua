local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local playerActivesCommand = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("PlayerActivesCommand")
local windShrineDonation = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("WindShrineDonation")
local toolCollect = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("ToolCollect")
local itemPackageEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("ItemPackageEvent")
local stickerPrinterActivate = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("StickerPrinterActivate")
local stickerStackActivate = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("StickerStackActivate")
local toyEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("ToyEvent")
local boostMarketEvent = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("Events"):WaitForChild("BoostMarketEvent")

local coreStats = LocalPlayer:WaitForChild("CoreStats")

local autofarmField = {"None Selected"}
local autofarmVar = false
local autoGlitter = false
local glitterInterval = 14
local autoMicroConverter = false
local autoFestiveBean = false
local festiveBeanInterval = 6

local autoStickerStack = false
local stickerStackInterval = 1
local autoCollectTokens = false
local autoDig = false
local autoDigDelay = 0.5
local selectedToken = {"All"}
local autoFarmRadius = 35

local autoBuyBasicEgg = false
local autoRollSticker = false
local autoToy = false
local toyInterval = 61

local autoBeesmasFeast = false
local beesmasFeastInterval = 91

local autoDonateWind = false
local donateWindInterval = 28
local windShrinePos = Vector3.new(-481.719, 138.292, 411.695)
local boostMarketPos = Vector3.new(92.331, 237.831, -558.869)

local autoSuperSmoothie = false
local superSmoothieInterval = 29
local autoBoostMarket = false
local boostMarketInterval = 60

local auto10mBuffs = false
local buffs10mInterval = 10

local autoFarmMobs = false
local selectedMobs = {"Werewolf", "Spider"}
local mobTpDelay = 0.5
local autoMobsInterval = 5
local mobSafeDistance = 15

local selectedNPC = "None Selected"
local isTeleportingTreasures = false

local autoBuyRoboBlueDrive = false
local autoBuyRoboRedDrive = false
local autoBuyRoboWhiteDrive = false
local autoBuyRoboGlitchedDrive = false
local autoUseRedDrive = false
local autoUseWhiteDrive = false
local autoUseBlueDrive = false
local autoUseGlitchedDrive = false

local antiAfkToggle = false
local antiAfkConnection = nil

local activeThreads = {}
local function stopThread(key)
    if activeThreads[key] then
        pcall(function() task.cancel(activeThreads[key]) end)
        activeThreads[key] = nil
    end
end

local tokenList = {
    "All", "Honey", "Ticket", "Treat", "Cloud", "Buff / Ability", "Micro-Converter"
}

local flowerFields = {}
if Workspace:FindFirstChild("FlowerZones") then
    for _, v in pairs(Workspace.FlowerZones:GetChildren()) do
        table.insert(flowerFields, v.Name)
    end
end

local npcList = {"None Selected"}
local npcsFolder = Workspace:FindFirstChild("NPCs")
if npcsFolder then
    for _, npc in pairs(npcsFolder:GetChildren()) do
        table.insert(npcList, npc.Name)
    end
end

local function sendActiveCommand(bytes)
    pcall(function()
        local b = buffer.create(#bytes)
        for i = 1, #bytes do
            buffer.writeu8(b, i - 1, bytes[i])
        end
        playerActivesCommand:FireServer(b)
    end)
end

local function getMobInstance(mobName)
    for _, child in pairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name:lower():find(mobName:lower()) then
            local hp = child:FindFirstChild("HP") or child:FindFirstChild("Health")
            local humanoid = child:FindFirstChildOfClass("Humanoid")
            
            local isAlive = true
            if hp and hp.Value <= 0 then isAlive = false end
            if humanoid and humanoid.Health <= 0 then isAlive = false end
            
            if isAlive then return child end
        end
    end
    return nil
end

local function getMobSpawner(mobName)
    local spawnersFolder = Workspace:FindFirstChild("MonsterSpawners")
    if spawnersFolder then
        for _, spawner in pairs(spawnersFolder:GetChildren()) do
            if spawner.Name:lower():find(mobName:lower()) then
                return spawner
            end
        end
    end
    return nil
end

local function startAutoMobsLoop()
    stopThread("AutoMobs")
    activeThreads["AutoMobs"] = task.spawn(function()
        while autoFarmMobs do
            for _, mobName in ipairs(selectedMobs) do
                if not autoFarmMobs then break end
                
                local spawnerObj = getMobSpawner(mobName)
                local mobObj = getMobInstance(mobName)
                
                if mobObj or spawnerObj then
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local targetPivot = mobObj and mobObj:GetPivot() or spawnerObj:GetPivot()
                        char.HumanoidRootPart.CFrame = targetPivot * CFrame.new(0, 5, 0)
                    end
                    
                    task.wait(mobTpDelay)

                    local activeMob = getMobInstance(mobName)
                    if activeMob then
                        local wasFarming = autofarmVar
                        autofarmVar = false 

                        while autoFarmMobs do
                            local currentMob = getMobInstance(mobName)
                            if not currentMob then break end

                            char = LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                char.HumanoidRootPart.CFrame = currentMob:GetPivot() * CFrame.new(0, 3, mobSafeDistance)
                            end
                            task.wait(0.1)
                        end

                        if wasFarming then
                            autofarmVar = true
                            startAutoFarmLoop()
                        end
                    end
                end
                task.wait(0.3)
            end
            task.wait(autoMobsInterval * 60)
        end
    end)
end

local function useBoostMarket()
    pcall(function()
        boostMarketEvent:FireServer(
            (function(bytes)
                local b = buffer.create(#bytes)
                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                return b
            end)({ 66, 83, 82, 80, 1, 1, 0, 5, 3, 0, 0, 0, 4, 10, 0, 0, 0, 77, 97, 114, 101, 107, 110, 78, 97, 109, 101, 4, 12, 0, 0, 0, 66, 111, 111, 115, 116, 32, 77, 97, 114, 101, 107, 110, 4, 5, 0, 0, 0, 66, 111, 111, 115, 116, 4, 26, 0, 0, 0, 67, 111, 99, 111, 110, 117, 116, 32, 70, 101, 101, 108, 100, 32, 77, 97, 114, 101, 107, 110, 32, 66, 111, 111, 115, 116, 4, 6, 0, 0, 0, 65, 99, 116, 101, 105, 111, 110, 4, 13, 0, 0, 0, 80, 111, 114, 99, 104, 97, 115, 101, 66, 111, 111, 115, 116 })
        )
    end)
end

local function startAutoBoostMarketLoop()
    stopThread("AutoBoostMarket")
    activeThreads["AutoBoostMarket"] = task.spawn(function()
        while autoBoostMarket do
            useBoostMarket()
            task.wait(boostMarketInterval * 60)
        end
    end)
end

local function useGlitter()
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 7, 0, 0, 0, 71, 108, 105, 116, 116, 101, 114, 4, 7, 0, 0, 0, 71, 108, 105, 116, 116, 101, 114 })
end

local function startAutoGlitterLoop()
    stopThread("AutoGlitter")
    activeThreads["AutoGlitter"] = task.spawn(function()
        while autoGlitter do
            useGlitter()
            task.wait(glitterInterval * 60)
        end
    end)
end

local function useToy()
    pcall(function()
        toyEvent:FireServer(
            (function(bytes)
                local b = buffer.create(#bytes)
                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                return b
            end)({ 66, 83, 82, 80, 1, 1, 0, 4, 9, 0, 0, 0, 83, 117, 111, 99, 107, 105, 110, 103, 115 })
        )
    end)
end

local function startAutoToyLoop()
    stopThread("AutoToy")
    activeThreads["AutoToy"] = task.spawn(function()
        while autoToy do
            useToy()
            task.wait(toyInterval * 60)
        end
    end)
end

local function useBeesmasFeast()
    pcall(function()
        toyEvent:FireServer(
            (function(bytes)
                local b = buffer.create(#bytes)
                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                return b
            end)({ 66, 83, 82, 80, 1, 1, 0, 4, 13, 0, 0, 0, 66, 101, 101, 153, 109, 97, 115, 32, 70, 101, 97, 115, 116 })
        )
    end)
end

local function startAutoBeesmasFeastLoop()
    stopThread("AutoBeesmasFeast")
    activeThreads["AutoBeesmasFeast"] = task.spawn(function()
        while autoBeesmasFeast do
            useBeesmasFeast()
            task.wait(beesmasFeastInterval * 60)
        end
    end)
end

local function buyBasicEgg()
    pcall(function()
        itemPackageEvent:InvokeServer(
            (function(bytes)
                local b = buffer.create(#bytes)
                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                return b
            end)({ 66, 83, 82, 80, 1, 2, 0, 4, 8, 0, 0, 0, 80, 117, 114, 99, 104, 97, 115, 101, 5, 3, 0, 0, 0, 4, 4, 0, 0, 0, 84, 121, 112, 101, 4, 5, 0, 0, 0, 66, 97, 115, 105, 99, 4, 6, 0, 0, 0, 65, 109, 111, 117, 110, 115, 3, 0, 0, 0, 0, 0, 0, 240, 63, 4, 8, 0, 0, 0, 67, 97, 101, 103, 111, 111, 114, 121, 4, 4, 0, 0, 0, 69, 103, 103, 115 })
        )
    end)
end

local function rollStickerPrinter()
    local bytes = { 66, 83, 82, 80, 1, 1, 0, 4, 9, 0, 0, 0, 66, 97, 115, 105, 99, 32, 69, 103, 103 }
    local b = buffer.create(#bytes)
    for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
    pcall(function() stickerPrinterActivate:FireServer(b) end)
end

local function startAutoBuyBasicEggLoop()
    stopThread("AutoBuyBasicEgg")
    activeThreads["AutoBuyBasicEgg"] = task.spawn(function()
        while autoBuyBasicEgg do
            buyBasicEgg()
            task.wait(0.5)
        end
    end)
end

local function startAutoRollStickerLoop()
    stopThread("AutoRollSticker")
    activeThreads["AutoRollSticker"] = task.spawn(function()
        while autoRollSticker do
            rollStickerPrinter()
            task.wait(10)
        end
    end)
end

local function useFestiveBean()
    playerActivesCommand:FireServer(
        (function(bytes)
            local b = buffer.create(#bytes)
            for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
            return b
        end)({ 66, 83, 82, 80, 1, 2, 0, 4, 12, 0, 0, 0, 70, 101, 115, 116, 105, 118, 101, 32, 66, 101, 97, 110, 4, 11, 0, 0, 0, 70, 101, 115, 116, 105, 118, 101, 66, 101, 97, 110 })
    )
end

local function startAutoFestiveBeanLoop()
    stopThread("AutoFestiveBean")
    activeThreads["AutoFestiveBean"] = task.spawn(function()
        while autoFestiveBean do
            useFestiveBean()
            task.wait(festiveBeanInterval * 60)
        end
    end)
end

local function useSuperSmoothie()
    playerActivesCommand:FireServer(
        (function(bytes)
            local b = buffer.create(#bytes)
            for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
            return b
        end)({ 66, 83, 82, 80, 1, 2, 0, 4, 14, 0, 0, 0, 83, 117, 112, 101, 114, 32, 83, 109, 111, 111, 116, 104, 105, 101, 4, 13, 0, 0, 0, 83, 117, 112, 101, 114, 83, 109, 111, 111, 116, 104, 105, 101 })
    )
end

local function startAutoSuperSmoothieLoop()
    stopThread("AutoSuperSmoothie")
    activeThreads["AutoSuperSmoothie"] = task.spawn(function()
        while autoSuperSmoothie do
            useSuperSmoothie()
            task.wait(superSmoothieInterval * 60)
        end
    end)
end

local function useAll10mBuffs()
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 14, 0, 0, 0, 84, 114, 111, 112, 101, 99, 97, 108, 32, 68, 114, 105, 110, 107, 4, 13, 0, 0, 0, 84, 114, 111, 112, 101, 99, 97, 108, 68, 114, 105, 110, 107 })
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 7, 0, 0, 0, 69, 110, 122, 121, 109, 101, 115, 4, 7, 0, 0, 0, 69, 110, 122, 121, 109, 101, 115 })
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 3, 0, 0, 0, 79, 105, 108, 4, 3, 0, 0, 0, 79, 105, 108 })
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 4, 0, 0, 0, 71, 108, 117, 101, 4, 4, 0, 0, 0, 71, 108, 117, 101 })
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 12, 0, 0, 0, 66, 108, 117, 101, 32, 69, 120, 116, 114, 97, 99, 116, 4, 11, 0, 0, 0, 66, 108, 117, 101, 69, 120, 116, 114, 97, 99, 116 })
    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 11, 0, 0, 0, 82, 101, 100, 32, 69, 120, 116, 114, 97, 99, 116, 4, 10, 0, 0, 0, 82, 101, 100, 69, 120, 116, 114, 97, 99, 116 })
end

local function startAuto10mBuffsLoop()
    stopThread("Auto10mBuffs")
    activeThreads["Auto10mBuffs"] = task.spawn(function()
        while auto10mBuffs do
            useAll10mBuffs()
            task.wait(buffs10mInterval * 60)
        end
    end)
end

local function useStickerStack()
    pcall(function()
        stickerStackActivate:FireServer(
            (function(bytes)
                local b = buffer.create(#bytes)
                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                return b
            end)({ 66, 83, 82, 80, 1, 1, 0, 4, 7, 0, 0, 0, 84, 105, 99, 107, 101, 115 })
        )
    end)
end

local function startAutoStickerStackLoop()
    stopThread("AutoStickerStack")
    activeThreads["AutoStickerStack"] = task.spawn(function()
        while autoStickerStack do
            useStickerStack()
            task.wait(stickerStackInterval * 60)
        end
    end)
end

local function digTool()
    local bytes = { 66, 83, 82, 80, 1, 0, 0 }
    local b = buffer.create(#bytes)
    for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
    toolCollect:FireServer(b)
end

local function startAutoDigLoop()
    stopThread("AutoDig")
    activeThreads["AutoDig"] = task.spawn(function()
        while autoDig do
            digTool()
            task.wait(math.max(0.01, autoDigDelay))
        end
    end)
end

local function donateWindShrine()
    windShrineDonation:InvokeServer(
        (function(bytes)
            local b = buffer.create(#bytes)
            for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
            return b
        end)({ 66, 83, 82, 80, 1, 2, 0, 4, 6, 0, 0, 0, 84, 105, 99, 107, 101, 115, 3, 0, 0, 0, 0, 0, 0, 240, 63 })
    )
end

local function isTargetToken(token)
    local targetType = type(selectedToken) == "table" and selectedToken[1] or selectedToken
    if targetType == "All" or not targetType then return true end

    local tokenName = token.Name:lower()
    local decal = token:FindFirstChildOfClass("Decal") or token:FindFirstChild("FrontDecal") or token:FindFirstChild("Icon")
    local texture = decal and decal.Texture:lower() or ""

    local filterKey = targetType:lower()
    if filterKey == "buff / ability" then
        return tokenName:find("buff") or tokenName:find("ability") or texture:find("buff")
    else
        return tokenName:find(filterKey) or texture:find(filterKey)
    end
end

local function collectTokens()
    local collectibles = Workspace:FindFirstChild("Collectibles")
    local char = LocalPlayer.Character
    if not collectibles or not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    for _, token in pairs(collectibles:GetChildren()) do
        if token:IsA("BasePart") and token.Transparency < 0.9 then
            if isTargetToken(token) then
                if (hrp.Position - token.Position).Magnitude <= 80 then
                    hrp.CFrame = token.CFrame + Vector3.new(0, 1, 0)
                    task.wait(0.06)
                end
            end
        end
    end
end

local function startAutoDonateWindLoop()
    stopThread("AutoDonateWind")
    activeThreads["AutoDonateWind"] = task.spawn(function()
        while autoDonateWind do
            local wasFarming = autofarmVar
            autofarmVar = false

            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(windShrinePos)
                task.wait(0.5)

                local spamStart = tick()
                while autoDonateWind and (tick() - spamStart < 15) do
                    donateWindShrine()
                    task.wait(0.1)
                end

                local collectStart = tick()
                while autoDonateWind and (tick() - collectStart < 5) do
                    collectTokens()
                    task.wait(0.1)
                end
            end

            if wasFarming then
                autofarmVar = true
                startAutoFarmLoop()
            end
            task.wait(donateWindInterval * 60)
        end
    end)
end

local function getRandomPointInRadius(radius, pointCFrame)
    local pointPosition = pointCFrame.Position
    return Vector3.new(pointPosition.X + math.random(-radius, radius), pointPosition.Y, pointPosition.Z + math.random(-radius, radius))
end

function startAutoFarmLoop()
    stopThread("AutoFarm")
    activeThreads["AutoFarm"] = task.spawn(function()
        while autofarmVar do
            local fieldString = type(autofarmField) == "table" and autofarmField[1] or autofarmField
            if fieldString == "None Selected" or not fieldString then
                task.wait(0.5)
                continue
            end

            local fieldZone = Workspace.FlowerZones:FindFirstChild(fieldString)
            local char = LocalPlayer.Character

            if fieldZone and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                local hrp = char.HumanoidRootPart
                local humanoid = char.Humanoid

                if (hrp.Position - fieldZone.Position).Magnitude > (autoFarmRadius + 30) then
                    hrp.CFrame = fieldZone.CFrame + Vector3.new(0, 5, 0)
                    task.wait(0.2)
                end

                local targetPos = getRandomPointInRadius(autoFarmRadius, fieldZone.CFrame)
                humanoid:MoveTo(targetPos)

                local startTime = tick()
                while autofarmVar and (tick() - startTime < 2.5) do
                    RunService.Heartbeat:Wait()
                    if autoCollectTokens then collectTokens() end
                    if autoMicroConverter and coreStats.Pollen.Value >= coreStats.Capacity.Value then
                        sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 15, 0, 0, 0, 77, 105, 99, 114, 111, 45, 67, 111, 110, 118, 101, 114, 116, 101, 114, 4, 15, 0, 0, 0, 77, 105, 99, 114, 111, 45, 67, 111, 110, 118, 101, 114, 116, 101, 114 })
                        task.wait(0.5)
                    end
                    if (hrp.Position - targetPos).Magnitude < 4 then break end
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

local WalkSpeedToggle = false
local WalkSpeedValue = 105
local JumpPowerToggle = false
local JumpPowerValue = 90

local Window = Rayfield:CreateWindow({
   Name = "BSS 1:1",
   LoadingTitle = "BSS 1:1 Loading...",
   LoadingSubtitle = "by NguyenMinhAdon",
   ConfigurationSaving = { Enabled = true, FolderName = "BSS1to1Config", FileName = "BSS 1:1" },
   Discord = { Enabled = false },
   KeySystem = false
})

local MainTab = Window:CreateTab("Main", nil)

Rayfield:Notify({ Title = "BSS 1:1", Content = "Script loaded successfully!", Duration = 5 })

MainTab:CreateToggle({
   Name = "Enable Loop WalkSpeed", CurrentValue = false, Flag = "WalkSpeedToggle",
   Callback = function(Value) WalkSpeedToggle = Value end,
})
MainTab:CreateSlider({
   Name = "WalkSpeed Value", Range = {0, 300}, Increment = 1, Suffix = "Speed", CurrentValue = 105, Flag = "WalkSpeedSlider",
   Callback = function(Value) WalkSpeedValue = Value end,
})
MainTab:CreateToggle({
   Name = "Enable Loop JumpPower", CurrentValue = false, Flag = "JumpPowerToggle",
   Callback = function(Value) JumpPowerToggle = Value end,
})
MainTab:CreateSlider({
   Name = "JumpPower Value", Range = {0, 300}, Increment = 1, Suffix = "JP", CurrentValue = 90, Flag = "JumpPowerSlider",
   Callback = function(Value) JumpPowerValue = Value end,
})

MainTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
      _G.infinjump = not _G.infinjump
      if _G.infinJumpStarted == nil then
         _G.infinJumpStarted = true
         UserInputService.JumpRequest:Connect(function()
            if _G.infinjump then
               local char = LocalPlayer.Character
               if char and char:FindFirstChildOfClass("Humanoid") then
                  char:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
               end
            end
         end)
      end
   end,
})

MainTab:CreateToggle({
    Name = "Enable Anti-AFK", CurrentValue = false, Flag = "AntiAfkToggle",
    Callback = function(Value)
        antiAfkToggle = Value
        if antiAfkToggle then
            if not antiAfkConnection then
                antiAfkConnection = LocalPlayer.Idled:Connect(function()
                    if antiAfkToggle then
                        local vu = game:GetService("VirtualUser")
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new())
                    end
                end)
            end
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
        end
    end,
})

local FpsLabel = MainTab:CreateLabel("FPS: ...")
local PingLabel = MainTab:CreateLabel("Ping: ...")
local sec = tick()
local FPS = {}

RunService.RenderStepped:Connect(function()
    local fr = tick()
    for index = #FPS, 1, -1 do
        FPS[index + 1] = (FPS[index] >= fr - 1) and FPS[index] or nil
    end
    FPS[1] = fr
    FpsLabel:Set("FPS: " .. tostring(math.floor((tick() - sec >= 1 and #FPS) or (#FPS / (tick() - sec)))))
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local ping = tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue())
            PingLabel:Set("Ping: " .. tostring(math.floor(ping)) .. " ms")
        end)
    end
end)

local AutoFarmTab = Window:CreateTab("Auto Farm", nil)
AutoFarmTab:CreateDropdown({
    Name = "Choose A Field To Farm In", Options = flowerFields, CurrentOption = {"None Selected"}, MultipleOptions = false, Flag = "FieldDropdown", 
    Callback = function(Options) autofarmField = Options end,
})
AutoFarmTab:CreateToggle({
    Name = "Auto Glitter", CurrentValue = false, Flag = "AutoGlitterToggle",
    Callback = function(Value) autoGlitter = Value if autoGlitter then startAutoGlitterLoop() end end,
})
AutoFarmTab:CreateSlider({
    Name = "Glitter Cooldown", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 14, Flag = "GlitterIntervalSlider",
    Callback = function(Value) glitterInterval = Value end,
})
AutoFarmTab:CreateToggle({
    Name = "Toggle Auto Farm", CurrentValue = false, Flag = "AutoFarmToggle",
    Callback = function(Value) autofarmVar = Value if autofarmVar then startAutoFarmLoop() end end,
})
AutoFarmTab:CreateSlider({
    Name = "Auto Farm Radius", Range = {0, 100}, Increment = 5, Suffix = "studs", CurrentValue = 35, Flag = "AutoFarmRadius",
    Callback = function(Value) autoFarmRadius = Value end,
})
AutoFarmTab:CreateToggle({
    Name = "Auto Dig Tool", CurrentValue = false, Flag = "AutoDigToggle",
    Callback = function(Value) autoDig = Value if autoDig then startAutoDigLoop() end end,
})
AutoFarmTab:CreateSlider({
    Name = "Auto Dig Delay", Range = {0.01, 3}, Increment = 0.01, Suffix = "seconds", CurrentValue = 0.5, Flag = "AutoDigDelaySlider",
    Callback = function(Value) autoDigDelay = Value end,
})
AutoFarmTab:CreateToggle({
    Name = "Auto Collect Tokens", CurrentValue = false, Flag = "AutoCollectTokensToggle",
    Callback = function(Value) autoCollectTokens = Value end,
})
AutoFarmTab:CreateDropdown({
    Name = "Select Token To Collect", Options = tokenList, CurrentOption = {"All"}, MultipleOptions = false, Flag = "TokenDropdown",
    Callback = function(Option) selectedToken = Option end,
})
AutoFarmTab:CreateToggle({
    Name = "Auto Micro-Converter", CurrentValue = false, Flag = "AutoMicroConverterToggle",
    Callback = function(Value) autoMicroConverter = Value end,
})
AutoFarmTab:CreateToggle({
    Name = "Auto Festive Bean", CurrentValue = false, Flag = "AutoFestiveBeanToggle",
    Callback = function(Value) autoFestiveBean = Value if autoFestiveBean then startAutoFestiveBeanLoop() end end,
})
AutoFarmTab:CreateSlider({
    Name = "Festive Bean Cooldown", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 6, Flag = "FestiveBeanIntervalSlider",
    Callback = function(Value) festiveBeanInterval = Value end,
})

local AutoMobsTab = Window:CreateTab("Auto Mobs", nil)
AutoMobsTab:CreateToggle({
    Name = "Enable Auto Farm Mobs", CurrentValue = false, Flag = "AutoMobsToggle",
    Callback = function(Value) autoFarmMobs = Value if autoFarmMobs then startAutoMobsLoop() end end,
})
AutoMobsTab:CreateDropdown({
    Name = "Select Mobs To Farm", Options = {"Werewolf", "Spider"}, CurrentOption = {"Werewolf", "Spider"}, MultipleOptions = true, Flag = "MobsDropdown",
    Callback = function(Options) selectedMobs = Options end,
})
AutoMobsTab:CreateSlider({
    Name = "Mob Safe Distance", Range = {5, 30}, Increment = 1, Suffix = "studs", CurrentValue = 15, Flag = "MobSafeDistanceSlider",
    Callback = function(Value) mobSafeDistance = Value end,
})
AutoMobsTab:CreateSlider({
    Name = "TP Delay per Mob Check", Range = {0.1, 5}, Increment = 0.1, Suffix = "seconds", CurrentValue = 0.5, Flag = "MobTpDelaySlider",
    Callback = function(Value) mobTpDelay = Value end,
})
AutoMobsTab:CreateSlider({
    Name = "Auto Mobs Interval", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 5, Flag = "AutoMobsIntervalSlider",
    Callback = function(Value) autoMobsInterval = Value end,
})

local StickerBuyTab = Window:CreateTab("Sticker & Buy", nil)
StickerBuyTab:CreateToggle({
    Name = "Auto Buy Basic Egg", CurrentValue = false, Flag = "AutoBuyBasicEggToggle",
    Callback = function(Value) autoBuyBasicEgg = Value if autoBuyBasicEgg then startAutoBuyBasicEggLoop() end end,
})
StickerBuyTab:CreateToggle({
    Name = "Auto Roll Sticker Printer (Basic Egg)", CurrentValue = false, Flag = "AutoRollStickerToggle",
    Callback = function(Value) autoRollSticker = Value if autoRollSticker then startAutoRollStickerLoop() end end,
})
StickerBuyTab:CreateToggle({
    Name = "Auto Stockings Toy", CurrentValue = false, Flag = "AutoToyToggle",
    Callback = function(Value) autoToy = Value if autoToy then startAutoToyLoop() end end,
})
StickerBuyTab:CreateSlider({
    Name = "Stockings Cooldown", Range = {1, 120}, Increment = 1, Suffix = "minutes", CurrentValue = 61, Flag = "ToyIntervalSlider",
    Callback = function(Value) toyInterval = Value end,
})
StickerBuyTab:CreateToggle({
    Name = "Auto Beesmas Feast Toy", CurrentValue = false, Flag = "AutoBeesmasFeastToggle",
    Callback = function(Value) autoBeesmasFeast = Value if autoBeesmasFeast then startAutoBeesmasFeastLoop() end end,
})
StickerBuyTab:CreateSlider({
    Name = "Beesmas Feast Cooldown", Range = {1, 180}, Increment = 1, Suffix = "minutes", CurrentValue = 91, Flag = "BeesmasFeastIntervalSlider",
    Callback = function(Value) beesmasFeastInterval = Value end,
})

local RoboTab = Window:CreateTab("Robo", nil)

RoboTab:CreateToggle({
    Name = "Loop Buy Blue Drive (0.5s)", CurrentValue = false, Flag = "AutoBuyRoboBlueDrive",
    Callback = function(Value)
        autoBuyRoboBlueDrive = Value
        stopThread("AutoBuyRoboBlueDrive")
        if autoBuyRoboBlueDrive then
            activeThreads["AutoBuyRoboBlueDrive"] = task.spawn(function()
                while autoBuyRoboBlueDrive do
                    pcall(function()
                        itemPackageEvent:InvokeServer(
                            (function(bytes)
                                local b = buffer.create(#bytes)
                                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                                return b
                            end)({ 66, 83, 82, 80, 1, 2, 0, 4, 8, 0, 0, 0, 80, 117, 114, 99, 104, 97, 115, 101, 5, 3, 0, 0, 0, 4, 4, 0, 0, 0, 84, 121, 112, 101, 4, 20, 0, 0, 0, 82, 111, 98, 111, 32, 66, 101, 97, 114, 32, 66, 108, 117, 101, 32, 68, 114, 105, 118, 101, 4, 6, 0, 0, 0, 65, 109, 111, 117, 110, 116, 3, 0, 0, 0, 0, 0, 0, 240, 63, 4, 8, 0, 0, 0, 67, 97, 116, 101, 103, 111, 114, 121, 4, 6, 0, 0, 0, 66, 117, 110, 100, 108, 101 })
                        )
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Buy Red Drive (0.5s)", CurrentValue = false, Flag = "AutoBuyRoboRedDrive",
    Callback = function(Value)
        autoBuyRoboRedDrive = Value
        stopThread("AutoBuyRoboRedDrive")
        if autoBuyRoboRedDrive then
            activeThreads["AutoBuyRoboRedDrive"] = task.spawn(function()
                while autoBuyRoboRedDrive do
                    pcall(function()
                        itemPackageEvent:InvokeServer(
                            (function(bytes)
                                local b = buffer.create(#bytes)
                                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                                return b
                            end)({ 66, 83, 82, 80, 1, 2, 0, 4, 8, 0, 0, 0, 80, 117, 114, 99, 104, 97, 115, 101, 5, 3, 0, 0, 0, 4, 4, 0, 0, 0, 84, 121, 112, 101, 4, 19, 0, 0, 0, 82, 111, 98, 111, 32, 66, 101, 97, 114, 32, 82, 101, 100, 32, 68, 114, 105, 118, 101, 4, 6, 0, 0, 0, 65, 109, 111, 117, 110, 116, 3, 0, 0, 0, 0, 0, 0, 240, 63, 4, 8, 0, 0, 0, 67, 97, 116, 101, 103, 111, 114, 121, 4, 6, 0, 0, 0, 66, 117, 110, 100, 108, 101 })
                        )
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Buy White Drive (0.5s)", CurrentValue = false, Flag = "AutoBuyRoboWhiteDrive",
    Callback = function(Value)
        autoBuyRoboWhiteDrive = Value
        stopThread("AutoBuyRoboWhiteDrive")
        if autoBuyRoboWhiteDrive then
            activeThreads["AutoBuyRoboWhiteDrive"] = task.spawn(function()
                while autoBuyRoboWhiteDrive do
                    pcall(function()
                        itemPackageEvent:InvokeServer(
                            (function(bytes)
                                local b = buffer.create(#bytes)
                                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                                return b
                            end)({ 66, 83, 82, 80, 1, 2, 0, 4, 8, 0, 0, 0, 80, 117, 114, 99, 104, 97, 115, 101, 5, 3, 0, 0, 0, 4, 4, 0, 0, 0, 84, 121, 112, 101, 4, 21, 0, 0, 0, 82, 111, 98, 111, 32, 66, 101, 97, 114, 32, 87, 104, 105, 116, 101, 32, 68, 114, 105, 118, 101, 4, 6, 0, 0, 0, 65, 109, 111, 117, 110, 116, 3, 0, 0, 0, 0, 0, 0, 240, 63, 4, 8, 0, 0, 0, 67, 97, 116, 101, 103, 111, 114, 121, 4, 6, 0, 0, 0, 66, 117, 110, 100, 108, 101 })
                        )
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Buy Glitched Drive (0.5s)", CurrentValue = false, Flag = "AutoBuyRoboGlitchedDrive",
    Callback = function(Value)
        autoBuyRoboGlitchedDrive = Value
        stopThread("AutoBuyRoboGlitchedDrive")
        if autoBuyRoboGlitchedDrive then
            activeThreads["AutoBuyRoboGlitchedDrive"] = task.spawn(function()
                while autoBuyRoboGlitchedDrive do
                    pcall(function()
                        itemPackageEvent:InvokeServer(
                            (function(bytes)
                                local b = buffer.create(#bytes)
                                for i = 1, #bytes do buffer.writeu8(b, i - 1, bytes[i]) end
                                return b
                            end)({ 66, 83, 82, 80, 1, 2, 0, 4, 8, 0, 0, 0, 80, 117, 114, 99, 104, 97, 115, 101, 5, 3, 0, 0, 0, 4, 4, 0, 0, 0, 84, 121, 112, 101, 4, 24, 0, 0, 0, 82, 111, 98, 111, 32, 66, 101, 97, 114, 32, 71, 108, 105, 116, 99, 104, 101, 100, 32, 68, 114, 105, 118, 101, 4, 6, 0, 0, 0, 65, 109, 111, 117, 110, 116, 3, 0, 0, 0, 0, 0, 0, 240, 63, 4, 8, 0, 0, 0, 67, 97, 116, 101, 103, 111, 114, 121, 4, 6, 0, 0, 0, 66, 117, 110, 100, 108, 101 })
                        )
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Use Red Drive (0.5s)", CurrentValue = false, Flag = "AutoUseRedDrive",
    Callback = function(Value)
        autoUseRedDrive = Value
        stopThread("AutoUseRedDrive")
        if autoUseRedDrive then
            activeThreads["AutoUseRedDrive"] = task.spawn(function()
                while autoUseRedDrive do
                    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 9, 0, 0, 0, 82, 101, 100, 32, 68, 114, 105, 118, 101, 4, 8, 0, 0, 0, 82, 101, 100, 68, 114, 105, 118, 101 })
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Use White Drive (0.5s)", CurrentValue = false, Flag = "AutoUseWhiteDrive",
    Callback = function(Value)
        autoUseWhiteDrive = Value
        stopThread("AutoUseWhiteDrive")
        if autoUseWhiteDrive then
            activeThreads["AutoUseWhiteDrive"] = task.spawn(function()
                while autoUseWhiteDrive do
                    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 11, 0, 0, 0, 87, 104, 105, 116, 101, 32, 68, 114, 105, 118, 101, 4, 10, 0, 0, 0, 87, 104, 105, 116, 101, 68, 114, 105, 118, 101 })
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Use Blue Drive (0.5s)", CurrentValue = false, Flag = "AutoUseBlueDrive",
    Callback = function(Value)
        autoUseBlueDrive = Value
        stopThread("AutoUseBlueDrive")
        if autoUseBlueDrive then
            activeThreads["AutoUseBlueDrive"] = task.spawn(function()
                while autoUseBlueDrive do
                    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 10, 0, 0, 0, 66, 108, 117, 101, 32, 68, 114, 105, 118, 101, 4, 9, 0, 0, 0, 66, 108, 117, 101, 68, 114, 105, 118, 101 })
                    task.wait(0.5)
                end
            end)
        end
    end,
})

RoboTab:CreateToggle({
    Name = "Loop Use Glitched Drive (0.5s)", CurrentValue = false, Flag = "AutoUseGlitchedDrive",
    Callback = function(Value)
        autoUseGlitchedDrive = Value
        stopThread("AutoUseGlitchedDrive")
        if autoUseGlitchedDrive then
            activeThreads["AutoUseGlitchedDrive"] = task.spawn(function()
                while autoUseGlitchedDrive do
                    sendActiveCommand({ 66, 83, 82, 80, 1, 2, 0, 4, 14, 0, 0, 0, 71, 108, 105, 116, 99, 104, 101, 100, 32, 68, 114, 105, 118, 101, 4, 13, 0, 0, 0, 71, 108, 105, 116, 99, 104, 101, 100, 68, 114, 105, 118, 101 })
                    task.wait(0.5)
                end
            end)
        end
    end,
})

local BoostShrineTab = Window:CreateTab("Boost & Shrine", nil)
BoostShrineTab:CreateToggle({
    Name = "Auto Donate WindShrine (1ticket)", CurrentValue = false, Flag = "AutoDonateWindToggle",
    Callback = function(Value) autoDonateWind = Value if autoDonateWind then startAutoDonateWindLoop() end end,
})
BoostShrineTab:CreateSlider({
    Name = "WindShrine Cooldown", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 28, Flag = "DonateWindIntervalSlider",
    Callback = function(Value) donateWindInterval = Value end,
})
BoostShrineTab:CreateButton({
    Name = "BoostMarket Teleport",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(boostMarketPos) end
    end,
})
BoostShrineTab:CreateToggle({
    Name = "Auto Buy Coconut Field Boost Market", CurrentValue = false, Flag = "AutoBoostMarketToggle",
    Callback = function(Value) autoBoostMarket = Value if autoBoostMarket then startAutoBoostMarketLoop() end end,
})
BoostShrineTab:CreateSlider({
    Name = "Boost Market Cooldown", Range = {1, 120}, Increment = 1, Suffix = "minutes", CurrentValue = 60, Flag = "BoostMarketIntervalSlider",
    Callback = function(Value) boostMarketInterval = Value end,
})
BoostShrineTab:CreateToggle({
    Name = "Auto Sticker Stack ( 25ticket )", CurrentValue = false, Flag = "AutoStickerStackToggle",
    Callback = function(Value) autoStickerStack = Value if autoStickerStack then startAutoStickerStackLoop() end end,
})
BoostShrineTab:CreateSlider({
    Name = "Sticker Stack Cooldown", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 1, Flag = "StickerStackIntervalSlider",
    Callback = function(Value) stickerStackInterval = Value end,
})
BoostShrineTab:CreateToggle({
    Name = "Auto Super Smoothie", CurrentValue = false, Flag = "AutoSuperSmoothieToggle",
    Callback = function(Value) autoSuperSmoothie = Value if autoSuperSmoothie then startAutoSuperSmoothieLoop() end end,
})
BoostShrineTab:CreateSlider({
    Name = "Super Smoothie Cooldown", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 29, Flag = "SuperSmoothieIntervalSlider",
    Callback = function(Value) superSmoothieInterval = Value end,
})
BoostShrineTab:CreateToggle({
    Name = "Auto 10m Buffs", CurrentValue = false, Flag = "Auto10mBuffsToggle",
    Callback = function(Value) auto10mBuffs = Value if auto10mBuffs then startAuto10mBuffsLoop() end end,
})
BoostShrineTab:CreateSlider({
    Name = "10m Buffs Cooldown", Range = {1, 60}, Increment = 1, Suffix = "minutes", CurrentValue = 10, Flag = "10mBuffsIntervalSlider",
    Callback = function(Value) buffs10mInterval = Value end,
})

local TeleportTab = Window:CreateTab("Teleport", nil)
TeleportTab:CreateDropdown({
    Name = "Select NPC", Options = npcList, CurrentOption = {"None Selected"}, MultipleOptions = false, Flag = "NpcDropdown",
    Callback = function(Option) selectedNPC = type(Option) == "table" and Option[1] or Option end,
})
TeleportTab:CreateButton({
    Name = "Teleport To NPC",
    Callback = function()
        if selectedNPC == "None Selected" or not selectedNPC then return end
        local npcsFolder = Workspace:FindFirstChild("NPCs")
        local targetNpc = npcsFolder and npcsFolder:FindFirstChild(selectedNPC)
        local char = LocalPlayer.Character
        if targetNpc and char and char:FindFirstChild("HumanoidRootPart") then
            char:PivotTo(targetNpc:GetPivot() * CFrame.new(0, 3, 0))
        end
    end,
})
TeleportTab:CreateButton({
    Name = "Teleport All Treasures (0.2s)",
    Callback = function()
        if isTeleportingTreasures then return end
        isTeleportingTreasures = true
        task.spawn(function()
            local treasuresFolder = Workspace:FindFirstChild("Treasures")
            if treasuresFolder then
                for _, treasure in pairs(treasuresFolder:GetChildren()) do
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        char:PivotTo(treasure:GetPivot() * CFrame.new(0, 3, 0))
                        task.wait(0.2)
                    end
                end
            end
            isTeleportingTreasures = false
        end)
    end,
})

RunService.RenderStepped:Connect(function()
   local character = LocalPlayer.Character
   if character then
      local humanoid = character:FindFirstChildOfClass("Humanoid")
      if humanoid then
         if WalkSpeedToggle then humanoid.WalkSpeed = WalkSpeedValue end
         if JumpPowerToggle then humanoid.UseJumpPower = true humanoid.JumpPower = JumpPowerValue end
      end
   end
end)
