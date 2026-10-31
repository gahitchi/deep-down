--!strict
-- Per-player state: coins and the backpack. Mirrored to player attributes so the client HUD can read it.
-- Not saved yet: saving comes with the vertical slice milestone.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BlockTypes = require(Shared:WaitForChild("BlockTypes"))
local Config = require(Shared:WaitForChild("Config"))

export type PlayerState = {
	coins: number,
	ores: { [number]: number }, -- block id -> count
	oreCount: number,
	capacity: number,
	lastDig: number,
	lastSurface: number,
}

local states: { [Player]: PlayerState } = {}

local PlayerDataService = {}

local function sync(player: Player, state: PlayerState)
	player:SetAttribute("Coins", state.coins)
	player:SetAttribute("BackpackUsed", state.oreCount)
	player:SetAttribute("BackpackCapacity", state.capacity)

	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if coins and coins:IsA("IntValue") then
		coins.Value = state.coins
	end
end

local function onPlayerAdded(player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = leaderstats
	leaderstats.Parent = player

	local state: PlayerState = {
		coins = 0,
		ores = {},
		oreCount = 0,
		capacity = Config.BACKPACK_CAPACITY,
		lastDig = 0,
		lastSurface = -math.huge,
	}
	states[player] = state
	sync(player, state)
end

function PlayerDataService.init()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		states[player] = nil
	end)
	-- Players who joined before this script ran (common in Studio).
	for _, player in Players:GetPlayers() do
		if not states[player] then
			onPlayerAdded(player)
		end
	end
end

function PlayerDataService.get(player: Player): PlayerState?
	return states[player]
end

function PlayerDataService.hasSpace(player: Player): boolean
	local state = states[player]
	return state ~= nil and state.oreCount < state.capacity
end

function PlayerDataService.addOre(player: Player, blockId: number): boolean
	local state = states[player]
	if not state or state.oreCount >= state.capacity then
		return false
	end
	state.ores[blockId] = (state.ores[blockId] or 0) + 1
	state.oreCount += 1
	sync(player, state)
	return true
end

-- Sells everything in the backpack. Returns (items sold, coins earned).
function PlayerDataService.sellAll(player: Player): (number, number)
	local state = states[player]
	if not state then
		return 0, 0
	end
	local earned = 0
	for blockId, count in state.ores do
		local def = BlockTypes.get(blockId)
		if def then
			earned += def.value * count
		end
	end
	local sold = state.oreCount
	state.coins += earned
	state.ores = {}
	state.oreCount = 0
	sync(player, state)
	return sold, earned
end

return PlayerDataService
