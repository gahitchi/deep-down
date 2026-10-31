--!strict
-- Upgrade tracks sold by the blacksmith. Tier 1 of each track is what every player starts with.
-- `value` is the pickaxe's power (damage per hit) or the backpack's capacity.

export type Tier = {
	name: string,
	price: number,
	value: number,
	color: Color3,
}

export type Kind = "pickaxe" | "backpack"

local tracks: { [string]: { Tier } } = {
	pickaxe = {
		{ name = "Rusty Pickaxe", price = 0, value = 1, color = Color3.fromRGB(128, 96, 80) },
		{ name = "Copper Pickaxe", price = 60, value = 2, color = Color3.fromRGB(222, 132, 62) },
		{ name = "Iron Pickaxe", price = 250, value = 3, color = Color3.fromRGB(176, 180, 188) },
		{ name = "Crystal Pickaxe", price = 900, value = 5, color = Color3.fromRGB(130, 210, 255) },
	},
	backpack = {
		{ name = "Pouch", price = 0, value = 15, color = Color3.fromRGB(150, 110, 70) },
		{ name = "Satchel", price = 100, value = 30, color = Color3.fromRGB(120, 86, 56) },
		{ name = "Miner's Pack", price = 400, value = 60, color = Color3.fromRGB(96, 70, 50) },
		{ name = "Explorer's Pack", price = 1200, value = 120, color = Color3.fromRGB(70, 56, 44) },
	},
}

local Upgrades = {}

Upgrades.KINDS = { "pickaxe", "backpack" } :: { Kind }

function Upgrades.isKind(value: unknown): boolean
	return value == "pickaxe" or value == "backpack"
end

function Upgrades.get(kind: Kind, tier: number): Tier?
	local track = tracks[kind]
	return track and track[tier]
end

function Upgrades.maxTier(kind: Kind): number
	return #tracks[kind]
end

return table.freeze(Upgrades)
