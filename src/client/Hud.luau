--!strict
-- On-screen info: coins, backpack, a "back to surface" button, short messages, and the build version.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local TEXT = Color3.fromRGB(255, 244, 220)
local PANEL = Color3.fromRGB(28, 24, 22)
local GOLD = Color3.fromRGB(255, 214, 120)
local WARN = Color3.fromRGB(255, 120, 100)

local Hud = {}

local function round(instance: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
end

local function makeLabel(parent: Instance, text: string, size: number, color: Color3): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.Font = Enum.Font.GothamBold
	label.TextSize = size
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

function Hud.start()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "Hud"
	gui.ResetOnSpawn = false

	-- Stats panel (top left)
	local stats = Instance.new("Frame")
	stats.Name = "Stats"
	stats.Position = UDim2.fromOffset(12, 12)
	stats.Size = UDim2.fromOffset(200, 68)
	stats.BackgroundColor3 = PANEL
	stats.BackgroundTransparency = 0.25
	stats.Parent = gui
	round(stats, 10)

	local coinsLabel = makeLabel(stats, "", 20, GOLD)
	coinsLabel.Position = UDim2.fromOffset(14, 8)
	coinsLabel.Size = UDim2.new(1, -28, 0, 26)

	local backpackLabel = makeLabel(stats, "", 16, TEXT)
	backpackLabel.Position = UDim2.fromOffset(14, 36)
	backpackLabel.Size = UDim2.new(1, -28, 0, 22)

	local function refresh()
		local coins = player:GetAttribute("Coins") or 0
		local used = player:GetAttribute("BackpackUsed") or 0
		local capacity = player:GetAttribute("BackpackCapacity") or Config.BACKPACK_CAPACITY
		coinsLabel.Text = string.format("Coins: %d", coins)
		backpackLabel.Text = string.format("Backpack: %d / %d", used, capacity)
		backpackLabel.TextColor3 = if used >= capacity then WARN else TEXT
	end
	for _, name in { "Coins", "BackpackUsed", "BackpackCapacity" } do
		player:GetAttributeChangedSignal(name):Connect(refresh)
	end
	refresh()

	-- Back to surface (top right, clear of the mobile jump button)
	local surfaceButton = Instance.new("TextButton")
	surfaceButton.Name = "SurfaceButton"
	surfaceButton.AnchorPoint = Vector2.new(1, 0)
	surfaceButton.Position = UDim2.new(1, -12, 0, 12)
	surfaceButton.Size = UDim2.fromOffset(170, 52)
	surfaceButton.BackgroundColor3 = Color3.fromRGB(70, 120, 200)
	surfaceButton.Text = "Back to surface"
	surfaceButton.TextColor3 = TEXT
	surfaceButton.Font = Enum.Font.GothamBold
	surfaceButton.TextSize = 18
	surfaceButton.Parent = gui
	round(surfaceButton, 10)
	surfaceButton.Activated:Connect(function()
		Remotes.ReturnToSurface:FireServer()
	end)

	-- Short messages from the server (top center)
	local toast = Instance.new("TextLabel")
	toast.Name = "Toast"
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Position = UDim2.new(0.5, 0, 0, 90)
	toast.Size = UDim2.fromOffset(460, 44)
	toast.BackgroundColor3 = PANEL
	toast.TextColor3 = TEXT
	toast.Font = Enum.Font.GothamBold
	toast.TextSize = 18
	toast.TextWrapped = true
	toast.Visible = false
	toast.Parent = gui
	round(toast, 10)

	local toastId = 0
	Remotes.Notify.OnClientEvent:Connect(function(message: unknown)
		if typeof(message) ~= "string" then
			return
		end
		toastId += 1
		local myId = toastId
		toast.Text = message
		toast.BackgroundTransparency = 0.2
		toast.TextTransparency = 0
		toast.Visible = true
		task.delay(2.2, function()
			if toastId ~= myId then
				return -- a newer message replaced this one
			end
			local fade = TweenInfo.new(0.4)
			TweenService:Create(toast, fade, { BackgroundTransparency = 1, TextTransparency = 1 })
				:Play()
		end)
	end)

	-- Build version (bottom left, small)
	local version =
		makeLabel(gui, string.format("%s v%s (dev)", Config.GAME_NAME, Config.VERSION), 12, TEXT)
	version.AnchorPoint = Vector2.new(0, 1)
	version.Position = UDim2.new(0, 12, 1, -8)
	version.Size = UDim2.fromOffset(240, 16)
	version.TextTransparency = 0.4

	gui.Parent = playerGui
end

return Hud
