--!strict
-- Server entry point. The server owns all game state (digging, loot, combat, saving).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local CharacterService = require(script.Parent.CharacterService)
local DigService = require(script.Parent.DigService)
local PlayerDataService = require(script.Parent.PlayerDataService)
local SurfaceService = require(script.Parent.SurfaceService)
local TerrainService = require(script.Parent.TerrainService)

SurfaceService.init()
TerrainService.init()
PlayerDataService.init()
CharacterService.init()
DigService.init()

print(string.format("[%s] server running, v%s", Config.GAME_NAME, Config.VERSION))
