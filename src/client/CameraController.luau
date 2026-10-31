--!strict
-- Locked side-view camera that smoothly follows the player. The slight perspective gives the 2.5D look.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local SNAP_DISTANCE = 40 -- studs; farther jumps (like teleports) snap instead of sliding

local CameraController = {}

function CameraController.start()
	local player = Players.LocalPlayer
	local focus: Vector3? = nil

	RunService:BindToRenderStep(
		"DeepDownCamera",
		Enum.RenderPriority.Camera.Value + 1,
		function(dt: number)
			local camera = Workspace.CurrentCamera
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not camera or not root or not root:IsA("BasePart") then
				return
			end

			camera.CameraType = Enum.CameraType.Scriptable
			camera.FieldOfView = Config.CAMERA_FOV

			local target = root.Position
			local previous = focus
			local current: Vector3 = target
			if previous and (target - previous).Magnitude <= SNAP_DISTANCE then
				current = previous:Lerp(target, 1 - math.exp(-dt * 10))
			end
			focus = current

			local lookAt =
				Vector3.new(current.X, current.Y + Config.CAMERA_HEIGHT * 0.5, Config.WORLD_Z)
			local eye = lookAt + Vector3.new(0, Config.CAMERA_HEIGHT * 0.5, Config.CAMERA_DISTANCE)
			camera.CFrame = CFrame.lookAt(eye, lookAt)
		end
	)
end

return CameraController
