--!strict
-- Builds the surface area (spawn and sell pad) and handles selling and returning to the surface.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent.PlayerDataService)

local B = Config.BLOCK_SIZE
local SURFACE_RETURN_POSITION = Vector3.new(Config.SPAWN_X, 5, Config.WORLD_Z)

local SurfaceService = {}

-- The Baseplate template's own baseplate and spawn would overlap the mine.
-- They're removed only while the game runs; the saved place is untouched.
local function removeTemplateParts()
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then
		baseplate:Destroy()
	end
	for _, descendant in Workspace:GetDescendants() do
		if descendant:IsA("SpawnLocation") then
			descendant:Destroy()
		end
	end
end

local function buildSpawn(folder: Folder)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(8, 1, B)
	spawn.Position = Vector3.new(Config.SPAWN_X, 0.5, Config.WORLD_Z)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0 -- no spawn force field
	spawn.Color = Color3.fromRGB(196, 180, 150)
	spawn.Material = Enum.Material.WoodPlanks
	spawn.TopSurface = Enum.SurfaceType.Smooth
	spawn.Parent = folder
end

local function onSell(player: Player)
	local sold, earned = PlayerDataService.sellAll(player)
	if sold == 0 then
		Remotes.Notify:FireClient(player, "Your backpack is empty. Go dig some ore!")
	else
		Remotes.Notify:FireClient(player, string.format("Sold %d ore for %d coins!", sold, earned))
	end
end

local function buildSellPad(folder: Folder)
	local pad = Instance.new("Part")
	pad.Name = "SellPad"
	pad.Size = Vector3.new(10, 0.5, B)
	pad.Position = Vector3.new(Config.SELL_PAD_X, 0.25, Config.WORLD_Z)
	pad.Anchored = true
	pad.Color = Color3.fromRGB(245, 196, 66)
	pad.Material = Enum.Material.SmoothPlastic
	pad.TopSurface = Enum.SurfaceType.Smooth
	pad.Parent = folder

	local sign = Instance.new("BillboardGui")
	sign.Name = "Sign"
	sign.Size = UDim2.fromOffset(180, 50)
	sign.StudsOffset = Vector3.new(0, 6, 0)
	sign.AlwaysOnTop = true
	sign.Parent = pad

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "SELL ORES"
	label.TextColor3 = Color3.fromRGB(255, 230, 140)
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 28
	label.Parent = sign

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Sell ores"
	prompt.ObjectText = "Trader"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = pad
	prompt.Triggered:Connect(onSell)
end

local function onReturnToSurface(player: Player)
	local state = PlayerDataService.get(player)
	local character = player.Character
	if not state or not character then
		return
	end
	local now = os.clock()
	local waitLeft = Config.SURFACE_COOLDOWN - (now - state.lastSurface)
	if waitLeft > 0 then
		Remotes.Notify:FireClient(
			player,
			string.format("Wait %d s before going up again.", math.ceil(waitLeft))
		)
		return
	end
	state.lastSurface = now
	character:PivotTo(CFrame.new(SURFACE_RETURN_POSITION))
end

function SurfaceService.init()
	removeTemplateParts()

	local folder = Instance.new("Folder")
	folder.Name = "Surface"
	buildSpawn(folder)
	buildSellPad(folder)
	folder.Parent = Workspace

	Remotes.ReturnToSurface.OnServerEvent:Connect(onReturnToSurface)
end

return SurfaceService
