--!strict
-- Keeps the character on the 2D plane: only left/right input is used, and drift off the plane is undone.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local MovementController = {}

-- Roblox's built-in control module reads keyboard, gamepad and the touch thumbstick for us.
local function getControls(player: Player): any
	local playerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
	return (require :: any)(playerModule):GetControls()
end

function MovementController.start()
	local player = Players.LocalPlayer
	local controls = getControls(player)

	-- Runs right after the default controls, overriding their movement with a left/right-only version.
	RunService:BindToRenderStep(
		"DeepDownSideScroll",
		Enum.RenderPriority.Input.Value + 1,
		function()
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end
			local move: Vector3 = controls:GetMoveVector()
			humanoid:Move(Vector3.new(move.X, 0, 0), false)
		end
	)

	RunService.Heartbeat:Connect(function()
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			return
		end
		local offset = Config.WORLD_Z - root.Position.Z
		if math.abs(offset) > 0.05 then
			root.CFrame += Vector3.new(0, 0, offset)
		end
		local velocity = root.AssemblyLinearVelocity
		if velocity.Z ~= 0 then
			root.AssemblyLinearVelocity = Vector3.new(velocity.X, velocity.Y, 0)
		end
	end)
end

return MovementController
