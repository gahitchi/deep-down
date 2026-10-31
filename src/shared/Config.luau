--!strict
-- Game-wide constants shared by server and client.

local Config = {}

Config.GAME_NAME = "Deep Down"
Config.VERSION = "0.2.0"
Config.DEBUG = true -- extra Output logging while we're in development

-- World: a vertical slice of blocks, one block thick, centered on X = 0.
Config.BLOCK_SIZE = 3 -- studs; tunnels are 2 blocks tall
Config.WORLD_COLUMNS = 70
Config.WORLD_ROWS = 100
Config.WALL_HEIGHT = 20 -- invisible edge walls rise this many blocks above the surface
Config.WORLD_Z = 0 -- the plane players move on

-- Characters are scaled to this body height so they fit a 2-block tunnel with headroom.
Config.CHARACTER_HEIGHT = 4.6

-- Village
Config.VILLAGE_NAME = "Lowmere"
Config.SPAWN_X = 0
Config.TRADER_X = 22
Config.BLACKSMITH_X = 40
Config.NPC_Z = -6.5 -- NPCs stand behind their counters, just off the play plane
Config.SHOP_DISTANCE = 14 -- how close you must be to an NPC to trade

-- Digging
Config.SWING_INTERVAL = 0.3 -- seconds between pickaxe hits
Config.REACH = 10 -- studs from the character's center to a block's center

-- Player
Config.SURFACE_COOLDOWN = 5 -- seconds between "back to surface" uses

-- Camera
Config.CAMERA_DISTANCE = 40
Config.CAMERA_RISE = 8 -- camera sits this much higher than the player, looking slightly down
Config.CAMERA_FOV = 40

return table.freeze(Config)
