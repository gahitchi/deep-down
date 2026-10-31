--!strict
-- Game-wide constants shared by server and client.

local Config = {}

Config.GAME_NAME = "Deep Down"
Config.VERSION = "0.1.0"

-- World: a vertical slice of blocks, one block thick, centered on X = 0.
Config.BLOCK_SIZE = 6 -- studs; a character fits in a one-block tunnel
Config.WORLD_COLUMNS = 40
Config.WORLD_ROWS = 60
Config.WALL_HEIGHT = 8 -- edge walls rise this many blocks above the surface
Config.WORLD_Z = 0 -- the plane players move on

-- Surface layout (X positions in studs)
Config.SPAWN_X = 0
Config.SELL_PAD_X = 30

-- Digging
Config.SWING_INTERVAL = 0.25 -- seconds between pickaxe hits
Config.REACH = 13.5 -- studs from the character's center to a block's center
Config.PICKAXE_POWER = 1 -- damage per hit

-- Player
Config.BACKPACK_CAPACITY = 20
Config.SURFACE_COOLDOWN = 5 -- seconds between "back to surface" uses

-- Camera
Config.CAMERA_DISTANCE = 55
Config.CAMERA_HEIGHT = 4
Config.CAMERA_FOV = 40

return table.freeze(Config)
