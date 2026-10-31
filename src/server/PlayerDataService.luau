--!strict
-- Per-player state: coins, backpack and upgrade tiers. Mirrored to player attributes so clients can read it.
-- Not saved yet: saving comes with the vertical slice milestone.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BlockTypes = require(Shared:WaitForChild("BlockTypes"))
local Upgrades = require(Shared:WaitForChild("Upgrades"))

export type PlayerState = {
	coins: number,
	ores: { [number]: number }, -- block id -> count
	oreCount: number,
	pickaxeTier: number,
	backpackTier: number,
	lastDig: number,
	lastSurface: number,
}

local states: { [Player]: PlayerState } = {}

local PlayerDataService = {}

local function tierValue(kind: Upgrades.Kind, tier: number): number
	local def = Upgrades.get(kind, tier)
	return if def then def.value else 0
end

local function capacityOf(state: PlayerState): number
	return tierValue("backpack", state.backpackTier)
end

local function sync(player: Player, state: PlayerState)
	player:SetAttribute("Coins", state.coins)
	player:SetAttribute("BackpackUsed", state.oreCount)
	player:SetAttribute("BackpackCapacity", capacityOf(state))
	player:SetAttribute("PickaxeTier", state.pickaxeTier)
	player:SetAttribute("BackpackTier", state.backpackTier)

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
		pickaxeTier = 1,
		backpackTier = 1,
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

function PlayerDataService.getPickaxePower(player: Player): number
	local state = states[player]
	return if state then tierValue("pickaxe", state.pickaxeTier) else 0
end

function PlayerDataService.hasSpace(player: Player): boolean
	local state = states[player]
	return state ~= nil and state.oreCount < capacityOf(state)
end

function PlayerDataService.addOre(player: Player, blockId: number): boolean
	local state = states[player]
	if not state or state.oreCount >= capacityOf(state) then
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

-- Buys the next tier of an upgrade track. Returns (success, message for the player).
function PlayerDataService.buyNextTier(player: Player, kind: Upgrades.Kind): (boolean, string)
	local state = states[player]
	if not state then
		return false, "Something went wrong. Try again."
	end
	local current = if kind == "pickaxe" then state.pickaxeTier else state.backpackTier
	local nextDef = Upgrades.get(kind, current + 1)
	if not nextDef then
		return false, "You already have the best one!"
	end
	if state.coins < nextDef.price then
		return false, string.format("You need %d more coins.", nextDef.price - state.coins)
	end

	state.coins -= nextDef.price
	if kind == "pickaxe" then
		state.pickaxeTier += 1
	else
		state.backpackTier += 1
	end
	sync(player, state)
	return true, string.format("You bought the %s!", nextDef.name)
end

return PlayerDataService
