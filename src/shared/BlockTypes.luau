--!strict
-- Every kind of block in the mine. Blocks with a value go into the backpack when broken.

export type BlockDef = {
	id: number,
	name: string,
	color: Color3,
	material: Enum.Material,
	hardness: number, -- hits needed at pickaxe power 1
	value: number, -- coins when sold; 0 = not collected
	diggable: boolean,
}

local BlockTypes = {}

BlockTypes.AIR = 0
BlockTypes.GRASS = 1
BlockTypes.DIRT = 2
BlockTypes.STONE = 3
BlockTypes.COPPER = 4
BlockTypes.BEDROCK = 5

local defs: { [number]: BlockDef } = {
	[BlockTypes.GRASS] = {
		id = BlockTypes.GRASS,
		name = "Grass",
		color = Color3.fromRGB(106, 170, 72),
		material = Enum.Material.Grass,
		hardness = 1,
		value = 0,
		diggable = true,
	},
	[BlockTypes.DIRT] = {
		id = BlockTypes.DIRT,
		name = "Dirt",
		color = Color3.fromRGB(134, 94, 60),
		material = Enum.Material.Ground,
		hardness = 2,
		value = 0,
		diggable = true,
	},
	[BlockTypes.STONE] = {
		id = BlockTypes.STONE,
		name = "Stone",
		color = Color3.fromRGB(112, 112, 120),
		material = Enum.Material.Slate,
		hardness = 4,
		value = 0,
		diggable = true,
	},
	[BlockTypes.COPPER] = {
		id = BlockTypes.COPPER,
		name = "Copper",
		color = Color3.fromRGB(222, 132, 62),
		material = Enum.Material.Slate,
		hardness = 4,
		value = 5,
		diggable = true,
	},
	[BlockTypes.BEDROCK] = {
		id = BlockTypes.BEDROCK,
		name = "Bedrock",
		color = Color3.fromRGB(40, 38, 44),
		material = Enum.Material.Basalt,
		hardness = math.huge,
		value = 0,
		diggable = false,
	},
}

function BlockTypes.get(id: number): BlockDef?
	return defs[id]
end

return table.freeze(BlockTypes)
