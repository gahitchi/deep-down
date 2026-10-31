--!strict
-- Converts between grid cells and world positions.
-- Column 0 is the leftmost, row 0 is the top (grass) row; rows grow downward.
-- Negative rows are the open air above the surface.

local Config = require(script.Parent.Config)

local B = Config.BLOCK_SIZE
local HALF_COLUMNS = (Config.WORLD_COLUMNS - 1) / 2

local Grid = {}

function Grid.cellToWorld(col: number, row: number): Vector3
	return Vector3.new((col - HALF_COLUMNS) * B, -B / 2 - row * B, Config.WORLD_Z)
end

function Grid.worldToCell(position: Vector3): (number, number)
	local col = math.round(position.X / B + HALF_COLUMNS)
	local row = math.round((-position.Y - B / 2) / B)
	return col, row
end

function Grid.inBounds(col: number, row: number): boolean
	return col >= 0 and col < Config.WORLD_COLUMNS and row >= 0 and row < Config.WORLD_ROWS
end

return table.freeze(Grid)
