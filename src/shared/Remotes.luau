--!strict
-- All RemoteEvents in one place. The server creates them; clients wait for them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local folder: Instance
if IS_SERVER then
	local existing = ReplicatedStorage:FindFirstChild("Remotes")
	if existing then
		folder = existing
	else
		local created = Instance.new("Folder")
		created.Name = "Remotes"
		created.Parent = ReplicatedStorage
		folder = created
	end
else
	folder = ReplicatedStorage:WaitForChild("Remotes")
end

local function event(name: string): RemoteEvent
	if IS_SERVER then
		local existing = folder:FindFirstChild(name)
		if existing and existing:IsA("RemoteEvent") then
			return existing
		end
		local created = Instance.new("RemoteEvent")
		created.Name = name
		created.Parent = folder
		return created
	end
	return folder:WaitForChild(name) :: RemoteEvent
end

return table.freeze({
	DigBlock = event("DigBlock"), -- client -> server: (col: number, row: number)
	ReturnToSurface = event("ReturnToSurface"), -- client -> server: ()
	BuyUpgrade = event("BuyUpgrade"), -- client -> server: (kind: "pickaxe" | "backpack")
	Notify = event("Notify"), -- server -> client: (message: string)
	Swing = event("Swing"), -- server -> all clients: (player, col, row, blockId, broke)
})
