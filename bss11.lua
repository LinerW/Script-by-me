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

local coreStats = LocalPlayer:WaitForChild("CoreStats")

local autofarmField = {"None Selected"}
local autofarmVar = false
local autoMicroConverter = false
local autoCollectTokens = false
local autoDig = false
local selectedToken = {"All"}
local autoFarmRadius = 20

local autoBuyBasicEgg = false
local autoRollSticker = false

local isDonating = false
local windShrinePos = Vector3.new(-481.719, 138.292, 411.695)
local boostMarketPos = Vector3.new(92.331, 237.831, -558.869)

local selectedNPC = "None Selected"
local isTeleportingTreasures = false

local tokenList = {
    "All",
    "Honey",
    "Ticket",
    "Treat",
    "Cloud",
    "Buff / Ability",
    "Micro-Converter"
}

local flowerFields = {}
if Workspace:FindFirstChild("FlowerZones") then
    for _, v in pairs(Workspace.FlowerZones:GetChildren()) do
        table.insert(flowerFields, v.Name)
    end
end

-- Lấy danh sách NPC từ Workspace.NPCs
local npcList = {"None Selected"}
local npcsFolder = Workspace:FindFirstChild("NPCs")
if npcsFolder then
    for _, npc in pairs(npcsFolder:GetChildren()) do
        table.insert(npcList, npc.Name)
    end
end

-- Hàm mua Basic Egg (Đã cập nhật code mới từ Cobalt)
local function buyBasicEgg()
    pcall(function()
        itemPackageEvent:InvokeServer(
            (function(bytes)
                local b = buffer.create(#bytes)
                for i = 1, #bytes do
                    buffer.writeu8(b, i - 1, bytes[i])
                end
                return b
            end)({ 66, 83, 82, 80, 1, 2, 0, 4, 8, 0, 0, 0, 80, 117, 114, 99, 104, 97, 115, 101, 5, 3, 0, 0, 0, 4, 4, 0, 0, 0, 84, 121, 112, 101, 4, 5, 0, 0, 0, 66, 97, 115, 105, 99, 4, 6, 0, 0, 0, 65, 109, 111, 117, 110, 116, 3, 0, 0, 0, 0, 0, 0, 240, 63, 4, 8, 0, 0, 0, 67, 97, 116, 101, 103, 111, 114, 121, 4, 4, 0, 0, 0, 69, 103, 103, 115 })
        )
    end)
end

-- Hàm Roll Sticker Printer bằng Basic Egg
local function rollStickerPrinter()
    local bytes = { 66, 83, 82, 80, 1, 1, 0, 4, 9, 0, 0, 0, 66, 97, 115, 105, 99, 32, 69, 103, 103 }
    local b = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(b, i - 1, bytes[i])
    end
    pcall(function()
        stickerPrinterActivate:FireServer(b)
    end)
end

-- Vòng lặp Auto Buy Basic Egg
local function startAutoBuyBasicEggLoop()
    task.spawn(function()
        while autoBuyBasicEgg do
            buyBasicEgg()
            task.wait(0.5)
        end
    end)
end

-- Vòng lặp Auto Roll Sticker (Đã chỉnh delay thành 10 giây)
local function startAutoRollStickerLoop()
    task.spawn(function()
        while autoRollSticker do
            rollStickerPrinter()
            task.wait(10)
        end
    end)
end

local function useMicroConverter()
    local bytes = { 66, 83, 82, 80, 1, 2, 0, 4, 15, 0, 0, 0, 77, 105, 99, 114, 111, 45, 67, 111, 110, 118, 101, 114, 116, 101, 114, 4, 15, 0, 0, 0, 77, 105, 99, 114, 111, 45, 67, 111, 110, 118, 101, 114, 116, 101, 114 }
    local b = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(b, i - 1, bytes[i])
    end
    playerActivesCommand:FireServer(b)
end

local function digTool()
    local bytes = { 66, 83, 82, 80, 1, 0, 0 }
    local b = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(b, i - 1, bytes[i])
    end
    toolCollect:FireServer(b)
end

local function startAutoDigLoop()
    task.spawn(function()
        while autoDig do
            digTool()
            task.wait(0.1)
        end
    end)
end

local function donateWindShrine()
    local bytes = { 66, 83, 82, 80, 1, 2, 0, 4, 6, 0, 0, 0, 84, 105, 99, 107, 101, 116, 3, 0, 0, 0, 0, 0, 0, 240, 63 }
    local b = buffer.create(#bytes)
    for i = 1, #bytes do
        buffer.writeu8(b, i - 1, bytes[i])
    end
    
    local success, _ = pcall(function()
        windShrineDonation:InvokeServer(b)
    end)

    return success
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
                local dist = (hrp.Position - token.Position).Magnitude
                if dist <= 80 then
                    hrp.CFrame = token.CFrame + Vector3.new(0, 1, 0)
                    task.wait(0.06)
                end
            end
        end
    end
end

local function getRandomPointInRadius(radius, pointCFrame)
    local pointPosition = pointCFrame.Position
    local randX = math.random(-radius, radius)
    local randZ = math.random(-radius, radius)
    return Vector3.new(pointPosition.X + randX, pointPosition.Y, pointPosition.Z + randZ)
end

local function startAutoFarmLoop()
    task.spawn(function()
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

                    if autoCollectTokens then
                        collectTokens()
                    end

                    if autoMicroConverter and coreStats.Pollen.Value >= coreStats.Capacity.Value then
                        useMicroConverter()
                        task.wait(0.5)
                    end

                    if (hrp.Position - targetPos).Magnitude < 4 then
                        break
                    end
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
   Name = "Ez walkspeed & AutoFarm",
   LoadingTitle = "Ez walkspeed",
   LoadingSubtitle = "by NguyenMinhAdon",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "EzwalkspeedConfig",
      FileName = "Ez walkspeed"
   },
   Discord = { Enabled = false },
   KeySystem = false
})

local WsJpTab = Window:CreateTab("WS/JP", nil)

Rayfield:Notify({
   Title = "Welcome to Ez walkspeed",
   Content = "Script loaded donezo",
   Duration = 5
})

WsJpTab:CreateToggle({
   Name = "Enable Loop WalkSpeed",
   CurrentValue = false,
   Flag = "WalkSpeedToggle",
   Callback = function(Value)
      WalkSpeedToggle = Value
   end,
})

WsJpTab:CreateSlider({
   Name = "WalkSpeed Value",
   Range = {0, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 105,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      WalkSpeedValue = Value
   end,
})

WsJpTab:CreateToggle({
   Name = "Enable Loop JumpPower",
   CurrentValue = false,
   Flag = "JumpPowerToggle",
   Callback = function(Value)
      JumpPowerToggle = Value
   end,
})

WsJpTab:CreateSlider({
   Name = "JumpPower Value",
   Range = {0, 300},
   Increment = 1,
   Suffix = "JP",
   CurrentValue = 90,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      JumpPowerValue = Value
   end,
})

WsJpTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
      _G.infinjump = not _G.infinjump

      if _G.infinJumpStarted == nil then
         _G.infinJumpStarted = true
         
         game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TooColdHub",
            Text = "Infinite Jump Activated!",
            Duration = 5
         })

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

local AutoFarmTab = Window:CreateTab("Auto Farm", nil)

AutoFarmTab:CreateDropdown({
    Name = "Choose A Field To Farm In",
    Options = flowerFields,
    CurrentOption = {"None Selected"},
    MultipleOptions = false,
    Flag = "FieldDropdown", 
    Callback = function(Options)
        autofarmField = Options
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Toggle Auto Farm",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        autofarmVar = Value
        if autofarmVar then
            startAutoFarmLoop()
        end
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Auto Dig Tool",
    CurrentValue = false,
    Flag = "AutoDigToggle",
    Callback = function(Value)
        autoDig = Value
        if autoDig then
            startAutoDigLoop()
        end
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Auto Collect Tokens",
    CurrentValue = false,
    Flag = "AutoCollectTokensToggle",
    Callback = function(Value)
        autoCollectTokens = Value
    end,
})

AutoFarmTab:CreateDropdown({
    Name = "Select Token To Collect",
    Options = tokenList,
    CurrentOption = {"All"},
    MultipleOptions = false,
    Flag = "TokenDropdown",
    Callback = function(Option)
        selectedToken = Option
    end,
})

AutoFarmTab:CreateToggle({
    Name = "Auto Micro-Converter",
    CurrentValue = false,
    Flag = "AutoMicroConverterToggle",
    Callback = function(Value)
        autoMicroConverter = Value
    end,
})

AutoFarmTab:CreateSlider({
    Name = "Auto Farm Radius",
    Range = {0, 100},
    Increment = 5,
    Suffix = "studs",
    CurrentValue = 20,
    Flag = "AutoFarmRadius",
    Callback = function(Value)
        autoFarmRadius = Value
    end,
})

-- TAB MỚI: Sticker & Buy
local StickerBuyTab = Window:CreateTab("Sticker & Buy", nil)

StickerBuyTab:CreateToggle({
    Name = "Auto Buy Basic Egg",
    CurrentValue = false,
    Flag = "AutoBuyBasicEggToggle",
    Callback = function(Value)
        autoBuyBasicEgg = Value
        if autoBuyBasicEgg then
            startAutoBuyBasicEggLoop()
        end
    end,
})

StickerBuyTab:CreateToggle({
    Name = "Auto Roll Sticker Printer (Basic Egg)",
    CurrentValue = false,
    Flag = "AutoRollStickerToggle",
    Callback = function(Value)
        autoRollSticker = Value
        if autoRollSticker then
            startAutoRollStickerLoop()
        end
    end,
})

local BoostShrineTab = Window:CreateTab("Boost & Shrine", nil)

BoostShrineTab:CreateButton({
    Name = "Donate WindShrine - 1ticket",
    Callback = function()
        if isDonating then return end
        isDonating = true

        task.spawn(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                
                if (hrp.Position - windShrinePos).Magnitude > 15 then
                    hrp.CFrame = CFrame.new(windShrinePos)
                    task.wait(0.3)
                end
            end

            donateWindShrine()
            
            isDonating = false
        end)
    end,
})

BoostShrineTab:CreateButton({
    Name = "BoostMarket",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(boostMarketPos)
        end
    end,
})

local TeleportTab = Window:CreateTab("Teleport", nil)

TeleportTab:CreateDropdown({
    Name = "Select NPC",
    Options = npcList,
    CurrentOption = {"None Selected"},
    MultipleOptions = false,
    Flag = "NpcDropdown",
    Callback = function(Option)
        if type(Option) == "table" then
            selectedNPC = Option[1]
        else
            selectedNPC = Option
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport To NPC",
    Callback = function()
        if selectedNPC == "None Selected" or not selectedNPC then return end

        local npcsFolder = Workspace:FindFirstChild("NPCs")
        local targetNpc = npcsFolder and npcsFolder:FindFirstChild(selectedNPC)
        local char = LocalPlayer.Character

        if targetNpc and char and char:FindFirstChild("HumanoidRootPart") then
            local npcPivot = targetNpc:GetPivot()
            char:PivotTo(npcPivot * CFrame.new(0, 3, 0))
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
                        local treasurePivot = treasure:GetPivot()
                        char:PivotTo(treasurePivot * CFrame.new(0, 3, 0))
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
         if WalkSpeedToggle then
            humanoid.WalkSpeed = WalkSpeedValue
         end
         
         if JumpPowerToggle then
            humanoid.UseJumpPower = true 
            humanoid.JumpPower = JumpPowerValue
         end
      end
   end
end)
