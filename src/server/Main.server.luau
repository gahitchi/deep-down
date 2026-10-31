--!strict
-- Server entry point. The server owns all game state (digging, loot, combat, saving).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

print(string.format("[%s] server running, v%s", Config.GAME_NAME, Config.VERSION))
