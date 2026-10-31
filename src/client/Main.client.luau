--!strict
-- Client entry point. Handles input, camera and UI; asks the server for anything that changes the game.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local CameraController = require(script.Parent.CameraController)
local DigController = require(script.Parent.DigController)
local Hud = require(script.Parent.Hud)
local MovementController = require(script.Parent.MovementController)

Hud.start()
CameraController.start()
MovementController.start()
DigController.start()

print(string.format("[%s] client running, v%s", Config.GAME_NAME, Config.VERSION))
