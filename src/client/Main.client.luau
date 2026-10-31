--!strict
-- Client entry point. Handles input, camera and UI; asks the server for anything that changes the game.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Small on-screen label so it's obvious the Rojo sync is working. Removed once real UI exists.
local gui = Instance.new("ScreenGui")
gui.Name = "DevBuildLabel"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0, 1)
label.Position = UDim2.new(0, 12, 1, -12)
label.Size = UDim2.fromOffset(300, 28)
label.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
label.BackgroundTransparency = 0.35
label.TextColor3 = Color3.fromRGB(255, 214, 120)
label.Font = Enum.Font.GothamMedium
label.TextSize = 14
label.Text = string.format("%s dev build v%s · sync OK", Config.GAME_NAME, Config.VERSION)
label.Parent = gui

gui.Parent = playerGui

print(string.format("[%s] client running, v%s", Config.GAME_NAME, Config.VERSION))
