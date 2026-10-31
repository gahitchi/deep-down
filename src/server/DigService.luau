--!strict
-- Handles dig requests from clients. Everything is checked here: never trust the client.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BlockTypes = require(Shared:WaitForChild("BlockTypes"))
local Config = require(Shared:WaitForChild("Config"))
local Grid = require(Shared:WaitForChild("Grid"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent.PlayerDataService)
local TerrainService = require(script.Parent.TerrainService)

local DigService = {}

local function reject(player: Player, reason: string)
	if Config.DEBUG then
		warn(string.format("[Deep Down] dig from %s rejected: %s", player.Name, reason))
	end
end

local function isWholeNumber(value: unknown): boolean
	return typeof(value) == "number" and value == math.floor(value)
end

local function getRoot(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

local function onDigRequest(player: Player, col: unknown, row: unknown)
	if not isWholeNumber(col) or not isWholeNumber(row) then
		return reject(player, "bad cell values")
	end
	local c = col :: number
	local r = row :: number
	if not Grid.inBounds(c, r) then
		return reject(player, "cell out of bounds")
	end

	local state = PlayerDataService.get(player)
	local root = getRoot(player)
	if not state or not root then
		return reject(player, "no player state or character")
	end

	-- Rate limit, with a little slack for network jitter. Not logged: it happens often and is harmless.
	local now = os.clock()
	if now - state.lastDig < Config.SWING_INTERVAL * 0.8 then
		return
	end

	local blockId = TerrainService.getBlock(c, r)
	local def = BlockTypes.get(blockId)
	if not def or not def.diggable then
		return reject(player, "block is air or undiggable")
	end
	local distance = (Grid.cellToWorld(c, r) - root.Position).Magnitude
	if distance > Config.REACH then
		return reject(player, string.format("out of reach (%.1f studs)", distance))
	end
	if not TerrainService.isExposed(c, r) then
		return reject(player, "block is buried (no open side)")
	end

	local collectible = def.value > 0
	if collectible and not PlayerDataService.hasSpace(player) then
		Remotes.Notify:FireClient(player, "Backpack full! Sell your ores to the trader.")
		return
	end

	state.lastDig = now
	local broke = TerrainService.hit(c, r, PlayerDataService.getPickaxePower(player))
	if broke and collectible then
		PlayerDataService.addOre(player, blockId)
	end
	-- Everyone sees the swing, the dust and the debris.
	Remotes.Swing:FireAllClients(player, c, r, blockId, broke)
end

function DigService.init()
	Remotes.DigBlock.OnServerEvent:Connect(onDigRequest)
end

return DigService
