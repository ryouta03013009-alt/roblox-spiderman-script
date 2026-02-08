-- スパイダーマン モバイルスクリプト for Roblox
-- LocalScript として StarterPlayer > StarterCharacterScripts に配置してください

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- グローバル変数
local isSwinging = false
local ropeConnection = nil
local reticleGui = nil
local touchStartPos = nil
local isClimbing = false

-- 設定
local ROPE_SPEED = 100
local ROPE_LENGTH = 100
local SWING_DAMPING = 0.95
local GRAVITY = 196.2

-- レティクルの作成
local function createReticle()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ReticleGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- 中央の点
    local centerDot = Instance.new("TextLabel")
    centerDot.Name = "CenterDot"
    centerDot.Size = UDim2.new(0, 4, 0, 4)
    centerDot.Position = UDim2.new(0.5, -2, 0.5, -2)
    centerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    centerDot.BorderSizePixel = 0
    centerDot.TextSize = 0
    centerDot.Parent = screenGui
    
    -- 十字線
    local crosshair = Instance.new("Frame")
    crosshair.Name = "Crosshair"
    crosshair.Size = UDim2.new(0, 30, 0, 30)
    crosshair.Position = UDim2.new(0.5, -15, 0.5, -15)
    crosshair.BackgroundTransparency = 1
    crosshair.BorderSizePixel = 0
    crosshair.Parent = screenGui
    
    -- 上下左右の線
    for _, direction in ipairs({"Top", "Bottom", "Left", "Right"}) do
        local line = Instance.new("Frame")
        line.Name = direction
        line.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        line.BorderSizePixel = 0
        
        if direction == "Top" then
            line.Size = UDim2.new(0, 2, 0, 8)
            line.Position = UDim2.new(0.5, -1, 0, 0)
        elseif direction == "Bottom" then
            line.Size = UDim2.new(0, 2, 0, 8)
            line.Position = UDim2.new(0.5, -1, 1, -8)
        elseif direction == "Left" then
            line.Size = UDim2.new(0, 8, 0, 2)
            line.Position = UDim2.new(0, 0, 0.5, -1)
        else -- Right
            line.Size = UDim2.new(0, 8, 0, 2)
            line.Position = UDim2.new(1, -8, 0.5, -1)
        end
        
        line.Parent = crosshair
    end
    
    return screenGui
end

-- 糸の作成と描画
local function createRope(startPos, endPos)
    local rope = Instance.new("Part")
    rope.Name = "WebRope"
    rope.Shape = Enum.PartType.Cylinder
    rope.Material = Enum.Material.Neon
    rope.Color = Color3.fromRGB(100, 149, 237)
    rope.CanCollide = false
    rope.CFrame = CFrame.new((startPos + endPos) / 2, endPos)
    rope.Size = Vector3.new(0.3, (endPos - startPos).Magnitude, 0.3)
    rope.Parent = workspace
    
    game:GetService("Debris"):AddItem(rope, 10)
    return rope
end

-- タップで糸を発射
local function fireWebToTouch(touchPos)
    local startPos = rootPart.Position + rootPart.CFrame.LookVector * 5
    
    -- スクリーン座標からワールド座標に変換
    local screenSize = camera.ViewportSize
    local unitRay = camera:ScreenPointToRay(touchPos.X, touchPos.Y)
    
    -- Raycast で最初に衝突したオブジェクトを取得
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
    local targetPos = unitRay.Origin + unitRay.Direction * 500;
    
    if rayResult then
        targetPos = rayResult.Position
    end
    
    createRope(startPos, targetPos)
    
    -- 対象に向かって引っ張る
    isSwinging = true
    local direction = (targetPos - rootPart.Position).Unit
    
    for i = 1, 30 do
        if not character.Parent or humanoid.Health <= 0 then break end
        
        rootPart.Velocity = direction * ROPE_SPEED + Vector3.new(0, -GRAVITY * 0.5, 0)
        wait(0.05)
    end
    
    isSwinging = false
end

-- 壁登り機能
local function climbWall()
    if isSwinging or isClimbing then return end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    -- 前方の壁を検出
    local rayDirection = rootPart.CFrame.LookVector * 10
    local rayResult = workspace:Raycast(rootPart.Position, rayDirection, raycastParams)
    
    if rayResult then
        isClimbing = true
        -- 壁に吸着して上昇
        local wallNormal = rayResult.Normal
        local climbDirection = Vector3.new(0, 1, 0) - wallNormal * 0.5
        
        for i = 1, 20 do
            if not character.Parent or humanoid.Health <= 0 then break end
            rootPart.Velocity = climbDirection.Unit * 50
            wait(0.05)
        end
        isClimbing = false
    end
end

-- モバイルタッチ入力
local UserInputService = game:GetService("UserInputService")

-- シングルタップで糸発射
UserInputService.TouchBegan:Connect(function(touch, gameProcessed)
    if gameProcessed then return end
    
    touchStartPos = Vector2.new(touch.Position.X, touch.Position.Y)
    fireWebToTouch(touchStartPos)
end)

-- スワイプで壁登り
UserInputService.TouchMoved:Connect(function(touch, gameProcessed)
    if gameProcessed or not touchStartPos then return end
    
    local touchCurrentPos = Vector2.new(touch.Position.X, touch.Position.Y)
    local swipeDelta = touchCurrentPos - touchStartPos
    
    -- 上方向へのスワイプ検出
    if swipeDelta.Y < -50 then
        climbWall()
        touchStartPos = nil
    end
end)

UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
    touchStartPos = nil
end)

-- 初期化
reticleGui = createReticle()

-- クリーンアップ
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if reticleGui then
        reticleGui:Destroy()
    end
end)

print("スパイダーマン モバイルスクリプト 読み込み完了！")
print("タップ: 糸を発射")
print("上方向スワイプ: 壁登り")