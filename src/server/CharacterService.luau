--!strict
-- Shrinks tall avatars (like Rthro) so every character fits through a one-block tunnel.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

-- Leaves headroom under a block so characters don't scrape the ceiling.
local MAX_HEIGHT = Config.BLOCK_SIZE - 1

local CharacterService = {}

-- Height of the body only: accessories (hats, hair) don't collide, so they don't count.
local function bodyHeight(character: Model): number
	local minY, maxY = math.huge, -math.huge
	for _, child in character:GetChildren() do
		if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
			local halfHeight = child.Size.Y / 2
			minY = math.min(minY, child.Position.Y - halfHeight)
			maxY = math.max(maxY, child.Position.Y + halfHeight)
		end
	end
	return if maxY > minY then maxY - minY else 0
end

local function fit(character: Model)
	local height = bodyHeight(character)
	if height > MAX_HEIGHT then
		character:ScaleTo(character:GetScale() * MAX_HEIGHT / height)
	end
end

local function watch(player: Player)
	player.CharacterAppearanceLoaded:Connect(fit)
	if player.Character and player:HasAppearanceLoaded() then
		fit(player.Character)
	end
end

function CharacterService.init()
	Players.PlayerAdded:Connect(watch)
	for _, player in Players:GetPlayers() do
		watch(player)
	end
end

return CharacterService
