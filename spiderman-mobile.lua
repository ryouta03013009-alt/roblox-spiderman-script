-- Mobile-Optimized Spider-Man Script

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = game.Workspace.CurrentCamera

local webReleased = false

-- Function to shoot web
local function shootWeb()
    if webReleased then return end
    webReleased = true
    local web = Instance.new("Part")
    web.Size = Vector3.new(0.2, 0.2, 10)
    web.Anchored = true
    web.CFrame = character.Head.CFrame * CFrame.new(0, 0, -5)
    web.Parent = game.Workspace
    wait(2)
    web:Destroy()
    webReleased = false
end

-- Function to tilt camera
local function tiltCamera(direction)
    local tiltAmount = 5 -- Adjust this value for sensitivity
    if direction == "up" then
        camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-tiltAmount), 0, 0)
    elseif direction == "down" then
        camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(tiltAmount), 0, 0)
    end
end

-- Function to handle input
local function onUserInput(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        if input.UserInputState == Enum.UserInputState.Begin then
            shootWeb()
        end
    elseif input.UserInputType == Enum.UserInputType.Accelerometer then
        if input.Position.Y > input.Position.X then -- Tilting up
tiltCamera("up")
        else -- Tilting down
tiltCamera("down")
        end
    end
end

UserInputService.InputBegan:Connect(onUserInput)