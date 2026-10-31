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
		return
	end
	local c = col :: number
	local r = row :: number
	if not Grid.inBounds(c, r) then
		return
	end

	local state = PlayerDataService.get(player)
	local root = getRoot(player)
	if not state or not root then
		return
	end

	-- Rate limit, with a little slack for network jitter.
	local now = os.clock()
	if now - state.lastDig < Config.SWING_INTERVAL * 0.8 then
		return
	end

	local def = BlockTypes.get(TerrainService.getBlock(c, r))
	if not def or not def.diggable then
		return
	end
	if (Grid.cellToWorld(c, r) - root.Position).Magnitude > Config.REACH then
		return
	end
	if not TerrainService.isExposed(c, r) then
		return
	end

	local collectible = def.value > 0
	if collectible and not PlayerDataService.hasSpace(player) then
		Remotes.Notify:FireClient(player, "Backpack full! Sell your ores at the surface.")
		return
	end

	state.lastDig = now
	local broke = TerrainService.hit(c, r, Config.PICKAXE_POWER)
	if broke and collectible then
		PlayerDataService.addOre(player, def.id)
	end
end

function DigService.init()
	Remotes.DigBlock.OnServerEvent:Connect(onDigRequest)
end

return DigService
