--!strict
-- Owns the block grid: generates the mine, builds its parts, and applies pickaxe hits.
-- Generation is procedural: every server gets a new seed, so every mine is different.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BlockTypes = require(Shared:WaitForChild("BlockTypes"))
local Config = require(Shared:WaitForChild("Config"))
local Grid = require(Shared:WaitForChild("Grid"))

local B = Config.BLOCK_SIZE
local COLUMNS = Config.WORLD_COLUMNS
local ROWS = Config.WORLD_ROWS

-- Generation tuning (in grid cells)
local TOPSOIL_DEPTH = 7 -- average rows of dirt before stone takes over
local TOPSOIL_WOBBLE = 4 -- how much that boundary rises and falls
local CAVE_START_ROW = 14 -- no caves above this, so the village floor stays solid
local CAVE_THRESHOLD = 0.3 -- higher = fewer, smaller caves
local COPPER_START_ROW = 3
local COPPER_THRESHOLD_TOP = 0.4 -- veins are rarer near the top...
local COPPER_THRESHOLD_DEEP = 0.3 -- ...and richer deeper down

local blocks: { [number]: { [number]: number } } = {}
local parts: { [number]: { [number]: BasePart } } = {}
local damage: { [number]: { [number]: number } } = {}
local rng = Random.new()
local seed = rng:NextNumber() * 10000

local TerrainService = {}

-- Smooth random value, roughly in -0.5..0.5. Each `layer` gives an independent pattern.
local function noise(x: number, y: number, layer: number): number
	return math.noise(x, y, seed + layer * 97.3)
end

local function pickBlock(col: number, row: number): number
	if row == ROWS - 1 then
		return BlockTypes.BEDROCK
	elseif row == 0 then
		return BlockTypes.GRASS
	end

	-- Caves: smooth blobs of empty space carved out of the deeper rock.
	if row >= CAVE_START_ROW and row < ROWS - 2 then
		if noise(col * 0.07, row * 0.1, 1) > CAVE_THRESHOLD then
			return BlockTypes.AIR
		end
	end

	-- Copper: clustered veins that get richer with depth.
	if row >= COPPER_START_ROW then
		local depth = math.clamp(row / (ROWS * 0.6), 0, 1)
		local threshold = COPPER_THRESHOLD_TOP + (COPPER_THRESHOLD_DEEP - COPPER_THRESHOLD_TOP) * depth
		if noise(col * 0.16, row * 0.16, 2) > threshold then
			return BlockTypes.COPPER
		end
	end

	-- Topsoil: a wavy dirt layer over stone, with dirt pockets scattered through the stone.
	local stoneLine = TOPSOIL_DEPTH + math.round(noise(col * 0.06, 0.5, 3) * 2 * TOPSOIL_WOBBLE)
	if row < stoneLine then
		return BlockTypes.DIRT
	end
	if noise(col * 0.12, row * 0.12, 4) > 0.32 then
		return BlockTypes.DIRT
	end
	return BlockTypes.STONE
end

local function makeBlockPart(col: number, row: number, def: BlockTypes.BlockDef): Part
	local part = Instance.new("Part")
	part.Name = "Block"
	part.Size = Vector3.new(B, B, B)
	part.Position = Grid.cellToWorld(col, row)
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = def.color
	part.Material = def.material
	part:SetAttribute("Col", col)
	part:SetAttribute("Row", row)
	return part
end

local function makeStaticPart(
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Color = color
	part.Material = material
	return part
end

-- An invisible wall: blocks players but not mouse clicks or camera rays.
local function makeBarrier(name: string, size: Vector3, position: Vector3): Part
	local part = makeStaticPart(name, size, position, Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
	part.Transparency = 1
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	return part
end

-- Walls that keep players inside the mine and on the play plane, plus the dark rock wall behind tunnels.
local function buildBounds()
	local folder = Instance.new("Folder")
	folder.Name = "MineBounds"

	local width = COLUMNS * B
	local topY = Config.WALL_HEIGHT * B
	local bottomY = -ROWS * B
	local fullHeight = topY - bottomY
	local midY = (topY + bottomY) / 2
	local bedrock = BlockTypes.get(BlockTypes.BEDROCK) :: BlockTypes.BlockDef

	for _, col in { -1, COLUMNS } do
		local x = Grid.cellToWorld(col, 0).X
		-- Solid bedrock underground...
		makeStaticPart(
			"EdgeWall",
			Vector3.new(B, -bottomY, B),
			Vector3.new(x, bottomY / 2, Config.WORLD_Z),
			bedrock.color,
			bedrock.material
		).Parent =
			folder
		-- ...and an invisible barrier above ground, so the village doesn't have giant pillars.
		makeBarrier("EdgeBarrier", Vector3.new(B, topY, B), Vector3.new(x, topY / 2, Config.WORLD_Z)).Parent =
			folder
	end

	-- Front and back barriers keep characters on the plane no matter what the input does.
	makeBarrier(
		"FrontBarrier",
		Vector3.new(width + 2 * B, fullHeight, 1),
		Vector3.new(0, midY, Config.WORLD_Z + B / 2 + 0.5)
	).Parent =
		folder
	makeBarrier(
		"BackBarrier",
		Vector3.new(width + 2 * B, topY, 1),
		Vector3.new(0, topY / 2, Config.WORLD_Z - B / 2 - 0.5)
	).Parent =
		folder

	local backWall = makeStaticPart(
		"BackWall",
		Vector3.new(width, -bottomY, 1),
		Vector3.new(0, bottomY / 2, Config.WORLD_Z - B / 2 - 0.5),
		Color3.fromRGB(58, 42, 30),
		Enum.Material.Ground
	)
	backWall.CastShadow = false
	backWall.Parent = folder

	folder.Parent = Workspace
end

function TerrainService.init()
	local folder = Instance.new("Folder")
	folder.Name = "Mine"

	for col = 0, COLUMNS - 1 do
		blocks[col] = {}
		parts[col] = {}
		damage[col] = {}
		for row = 0, ROWS - 1 do
			local id = pickBlock(col, row)
			blocks[col][row] = id
			local def = BlockTypes.get(id)
			if def then -- air has no def and no part
				local part = makeBlockPart(col, row, def)
				part.Parent = folder
				parts[col][row] = part
			end
		end
	end

	-- Parent once at the end: much faster than parenting thousands of parts one by one.
	folder.Parent = Workspace
	buildBounds()

	if Config.DEBUG then
		print(string.format("[Deep Down] mine generated (seed %.2f)", seed))
	end
end

function TerrainService.getBlock(col: number, row: number): number
	if col < 0 or col >= COLUMNS or row >= ROWS then
		return BlockTypes.BEDROCK
	elseif row < 0 then
		return BlockTypes.AIR
	end
	return blocks[col][row]
end

-- A block can only be dug if at least one side touches open space, so players can't dig through walls.
function TerrainService.isExposed(col: number, row: number): boolean
	local get = TerrainService.getBlock
	return get(col - 1, row) == BlockTypes.AIR
		or get(col + 1, row) == BlockTypes.AIR
		or get(col, row - 1) == BlockTypes.AIR
		or get(col, row + 1) == BlockTypes.AIR
end

-- Applies one pickaxe hit. Returns true if the block broke.
function TerrainService.hit(col: number, row: number, power: number): boolean
	if not Grid.inBounds(col, row) then
		return false
	end
	local def = BlockTypes.get(blocks[col][row])
	if not def or not def.diggable then
		return false
	end

	local part = parts[col][row]
	local total = (damage[col][row] or 0) + power
	if total >= def.hardness then
		blocks[col][row] = BlockTypes.AIR
		damage[col][row] = nil
		parts[col][row] = nil
		if part then
			part:Destroy()
		end
		return true
	end

	damage[col][row] = total
	if part then
		-- Darken the block as it takes damage.
		part.Color = def.color:Lerp(Color3.new(0, 0, 0), 0.5 * total / def.hardness)
	end
	return false
end

return TerrainService
