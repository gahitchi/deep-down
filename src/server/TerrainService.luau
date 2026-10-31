--!strict
-- Owns the block grid: generates the mine, builds its parts, and applies pickaxe hits.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local BlockTypes = require(Shared:WaitForChild("BlockTypes"))
local Config = require(Shared:WaitForChild("Config"))
local Grid = require(Shared:WaitForChild("Grid"))

local B = Config.BLOCK_SIZE
local COLUMNS = Config.WORLD_COLUMNS
local ROWS = Config.WORLD_ROWS

local blocks: { [number]: { [number]: number } } = {}
local parts: { [number]: { [number]: BasePart } } = {}
local damage: { [number]: { [number]: number } } = {}
local rng = Random.new()

local TerrainService = {}

local function pickBlock(row: number): number
	if row == ROWS - 1 then
		return BlockTypes.BEDROCK
	elseif row == 0 then
		return BlockTypes.GRASS
	elseif row <= 3 then
		return BlockTypes.DIRT
	end
	-- Copper gets a little more common the deeper you go.
	if rng:NextNumber() < 0.05 + row * 0.0008 then
		return BlockTypes.COPPER
	end
	-- Dirt slowly gives way to stone over the first ~15 rows.
	local stoneChance = math.clamp((row - 3) / 12, 0, 0.85)
	if rng:NextNumber() < stoneChance then
		return BlockTypes.STONE
	end
	return BlockTypes.DIRT
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

-- Walls on both sides of the mine and a dark rock wall behind it, so dug tunnels look like tunnels.
local function buildBounds()
	local folder = Instance.new("Folder")
	folder.Name = "MineBounds"

	local topY = Config.WALL_HEIGHT * B
	local bottomY = -ROWS * B
	local wallSize = Vector3.new(B, topY - bottomY, B)
	local wallY = (topY + bottomY) / 2
	local bedrock = BlockTypes.get(BlockTypes.BEDROCK) :: BlockTypes.BlockDef

	for _, col in { -1, COLUMNS } do
		local x = Grid.cellToWorld(col, 0).X
		local wall = makeStaticPart(
			"EdgeWall",
			wallSize,
			Vector3.new(x, wallY, Config.WORLD_Z),
			bedrock.color,
			bedrock.material
		)
		wall.Parent = folder
	end

	local backWall = makeStaticPart(
		"BackWall",
		Vector3.new(COLUMNS * B, ROWS * B, 1),
		Vector3.new(0, -ROWS * B / 2, Config.WORLD_Z - B / 2 - 0.5),
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
			local id = pickBlock(row)
			blocks[col][row] = id
			local part = makeBlockPart(col, row, BlockTypes.get(id) :: BlockTypes.BlockDef)
			part.Parent = folder
			parts[col][row] = part
		end
	end

	-- Parent once at the end: much faster than parenting 2,400 parts one by one.
	folder.Parent = Workspace
	buildBounds()
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
