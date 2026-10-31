--!strict
-- Click or tap a block to dig it; hold to keep digging. The block you can reach is outlined.
-- The server re-checks everything, so this only decides what to ask for.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Grid = require(Shared:WaitForChild("Grid"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local DigController = {}

function DigController.start()
	local player = Players.LocalPlayer
	local mine = Workspace:WaitForChild("Mine")

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { mine }

	local outline = Instance.new("SelectionBox")
	outline.Name = "DigOutline"
	outline.LineThickness = 0.1
	outline.Color3 = Color3.fromRGB(255, 240, 200)
	outline.SurfaceTransparency = 1

	local holdingMouse = false
	local activeTouch: InputObject? = nil
	local lastSwing = 0

	local function pointerRay(camera: Camera): Ray?
		local touch = activeTouch
		if touch then
			return camera:ScreenPointToRay(touch.Position.X, touch.Position.Y)
		end
		if UserInputService.MouseEnabled then
			local mouse = UserInputService:GetMouseLocation()
			return camera:ViewportPointToRay(mouse.X, mouse.Y)
		end
		return nil
	end

	-- The block under the pointer, if it's within reach.
	local function findTarget(camera: Camera): BasePart?
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			return nil
		end
		local ray = pointerRay(camera)
		if not ray then
			return nil
		end
		local result = Workspace:Raycast(ray.Origin, ray.Direction * 500, rayParams)
		if not result then
			return nil
		end
		local part = result.Instance
		local col = part:GetAttribute("Col")
		local row = part:GetAttribute("Row")
		if typeof(col) ~= "number" or typeof(row) ~= "number" then
			return nil
		end
		if (Grid.cellToWorld(col, row) - root.Position).Magnitude > Config.REACH then
			return nil
		end
		return part
	end

	local function swing(target: BasePart)
		lastSwing = os.clock()
		Remotes.DigBlock:FireServer(target:GetAttribute("Col"), target:GetAttribute("Row"))
	end

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then
			return -- the input went to a button or the thumbstick
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holdingMouse = true
			lastSwing = 0
		elseif input.UserInputType == Enum.UserInputType.Touch then
			activeTouch = input
			lastSwing = 0
		end
	end)

	UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			holdingMouse = false
		elseif input == activeTouch then
			activeTouch = nil
		end
	end)

	RunService.RenderStepped:Connect(function()
		local camera = Workspace.CurrentCamera
		if not camera then
			return
		end
		if outline.Parent ~= camera then
			outline.Parent = camera -- client-only, never replicated
		end

		local target = findTarget(camera)
		outline.Adornee = target

		local digging = holdingMouse or activeTouch ~= nil
		if digging and target and os.clock() - lastSwing >= Config.SWING_INTERVAL then
			swing(target)
		end
	end)
end

return DigController
