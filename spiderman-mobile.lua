-- Updated spiderman-mobile.lua with first-person animations

local Animations = {}

function Animations:LoadFirstPersonAnimations()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    -- Web shooting poses
    local webShootAnimation = Instance.new("Animation")
    webShootAnimation.AnimationId = "rbxassetid://<web_shoot_anim_id>"  -- Replace <web_shoot_anim_id> with actual Animation ID
    local webShoot = character.Humanoid:LoadAnimation(webShootAnimation)

    -- Climbing animation
    local climbAnimation = Instance.new("Animation")
    climbAnimation.AnimationId = "rbxassetid://<climb_anim_id>"  -- Replace <climb_anim_id> with actual Animation ID
    local climb = character.Humanoid:LoadAnimation(climbAnimation)

    -- Player input
    local isFirstPerson = false
    local function onCameraChanged()
        isFirstPerson = workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable
    end

    workspace.CurrentCamera:GetPropertyChangedSignal("CameraType"):Connect(onCameraChanged)

    -- Execute animations based on perspective
    local function onInputBegan(input)
        if isFirstPerson then
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E then
                webShoot:Play()
            elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.W then
                climb:Play()
            end
        end
    end

    game:GetService("UserInputService").InputBegan:Connect(onInputBegan)
end

return Animations