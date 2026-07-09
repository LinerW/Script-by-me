--[1] Gán dịch vụ hệ thống của Roblox vào biến local để truy cập nhanh
local RS = game:GetService("ReplicatedStorage")
local WS = workspace

--[2] Import thư viện Runtime Lib của hệ thống rbxts
local RL = require(RS.rbxts_include.RuntimeLib)

--[3] Định nghĩa các Remote Event và Trạng thái (Store) trận đấu từ hệ thống game
local B = RL.import(script, RS, "common", "remotes", "battle").BattleRemotes
local S = RL.import(script, RS, "common", "store", "battle")
local CM = RL.import(script, RS, "common", "util", "battle-util").ChallengeMode
local Enemies = WS.Enemies

--[4] Tối ưu hóa các hàm hệ thống thành biến cục bộ (Local) để tăng tốc độ xử lý
local tonumber = tonumber
local task_wait = task.wait
local task_spawn = task.spawn

--[5] Khởi tạo các biến toàn cục trong script để lưu trữ mục tiêu hiện tại
local tgt = nil
local cached_hp_text = nil

--[6] Hàm kiểm tra xem nhân vật có đang ở trạng thái được phép farm hay không
local function canKill()
    local c = S.AtomBattleState()
    return c == CM.None or c == 0 or c == "None" or c == 4 or tostring(c) == "4"
end

--[7] Hàm kiểm tra xem quái mục tiêu hiện tại đã chết hay chưa (bằng cách check chữ số đầu của Text Máu)
local function isCurrentTargetDead()
    if not tgt or not tgt.Parent then return true end
    if cached_hp_text and cached_hp_text.Parent then
        return cached_hp_text.Text:sub(1,1) == "0"
    end
    
    local hp = tgt:FindFirstChild("hpText", true)
    if hp then 
        cached_hp_text = hp
        return hp.Text:sub(1,1) == "0"
    end
    return true
end

--[8] Hàm quét và tìm kiếm mục tiêu (quái) tiếp theo còn sống trong danh sách quái
local function getNextTarget()
    local list = Enemies:GetChildren()
    for i = 1, #list do
        local v = list[i]
        if v and v.Parent then
            local hp = v:FindFirstChild("hpText", true)
            if hp and hp.Text:sub(1,1) ~= "0" then
                cached_hp_text = hp
                return v
            end
        end
    end
    return nil
end

--[9] Hàm dọn dẹp rác đồ họa (Part hiệu ứng, bảng sát thương) để chống drop FPS khi AFK lâu
local function cleanGarbage()
    for _, v in WS:GetChildren() do
        if v:IsA("Part") and (v.Name:find("Effect") or v.Name:find("Damage") or v.Name:find("Part")) then
            v:Destroy()
        elseif v:IsA("Debris") or v.Name == "EffectContainer" then
            v:ClearAllChildren()
        end
    end
end

--[10] Hàm chứa vòng lặp tấn công chính (Kill Loop)
local function KillLoop()
    tgt = nil
    cached_hp_text = nil
    B.enterMainChallengeReq:fire() -- Gửi tín hiệu bắt đầu thử thách màn chơi
    
    task_spawn(function()
        local attack_remote = B.attack
        local enter_remote = B.enterMainChallengeReq
        local last_clean = os.time()
        
        -- Vòng lặp tấn công liên tục khi biến điều kiện bật và được phép farm
        while _G.Kill and canKill() do
            if not tgt or isCurrentTargetDead() then
                tgt = getNextTarget()
                if tgt then 
                    enter_remote:fire() 
                else
                    cached_hp_text = nil
                end
            end
            
            if tgt then 
                attack_remote:fire(tonumber(tgt.Name)) -- Gửi remote tấn công quái theo ID tên của nó
            end
            
            -- Cứ sau mỗi 30 giây chạy, tự động gọi hàm dọn rác 1 lần
            if os.time() - last_clean > 30 then
                cleanGarbage()
                last_clean = os.time()
            end
            
            task_wait(0.02) -- Nghỉ 0.02 giây để tránh làm nghẽn băng thông server (chống Disconnect)
        end
    end)
end

--[11] Bật công tắc kích hoạt chính
_G.Kill = true

--[12] Luồng chạy ngầm theo dõi trạng thái Game để tự động Bật/Tắt vòng lặp farm khi chuyển màn
task_spawn(function()
    local running = false
    if canKill() then running = true KillLoop() end
    while _G.Kill do
        local ok = canKill()
        if not ok and running then
            tgt, cached_hp_text, running = nil, nil, false
        elseif ok and not running then
            running = true KillLoop()
        end
        task_wait(0.5) -- Kiểm tra lại trạng thái mỗi 0.5 giây
    end
end)