--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

export type HumanoidState = {
	-- State_1 : number,
	-- State_2 : number,
	-- State_3 : boolean,
}

local DEFAULT_STATE : HumanoidState = {
	-- Default state of a HumanoidState
}

local StateManager = {}
if not script:FindFirstChildWhichIsA("RemoteEvent") then
	local remote = Instance.new("UnreliableRemoteEvent", script)
	remote.Name = "UpdateState"
end

StateManager.UpdateState = script:WaitForChild("UpdateState") :: UnreliableRemoteEvent
StateManager.OnStateChange = Instance.new("BindableEvent")

-- Only used on server
function StateManager.Init()
	StateManager.UpdateState.OnServerEvent:Connect(function(player: Player, humanoid: Humanoid, key: string, value: any)
		StateManager.SetState(humanoid, key, value)
	end)
end

function StateManager.GetState(humanoid: Humanoid, state: string)
	return StateManager.GetAllStates(humanoid)[state]
end

function StateManager.GetAllStates(humanoid: Humanoid): HumanoidState
	if humanoid and humanoid:IsDescendantOf(workspace) then
		local attributes = humanoid:GetAttributes()
		local state = table.clone(DEFAULT_STATE)
		for key, value in attributes do
			if state[key] ~= nil then
				state[key] = value
			end
		end
		return state
	else
		return DEFAULT_STATE
	end
end

-- Used on Client and Server based on state.
function StateManager.SetState(humanoid: Humanoid, key: string, value: any) 
	if humanoid and humanoid:IsDescendantOf(game) then
		local state = DEFAULT_STATE[key]
		if state ~= nil then
			local valid = typeof(state) == typeof(value)
			if valid then
				humanoid:SetAttribute(key, value)
				if RunService:IsClient() then
					StateManager.OnStateChange:Fire()
				elseif RunService:IsServer() then
					local player = Players:GetPlayerFromCharacter(humanoid.Parent)
					if player then
						pcall(function()
							StateManager.UpdateState:FireClient(player, key, value)
						end)
					else
						StateManager.OnStateChange:Fire(humanoid, key, value)
					end
				end
			end
		end
	end
end

function StateManager.InitializeHumanoid(humanoid: Humanoid)
	for key, value in pairs(DEFAULT_STATE) do
		StateManager.SetState(humanoid, tostring(key), value)
	end
	
	local timer = 0
	local update = 1
	local connections : {RBXScriptConnection} = {}
	local player = Players:GetPlayerFromCharacter(humanoid.Parent)
	local function disconnect()
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end
	
	table.insert(connections, humanoid.Died:Connect(disconnect))
	table.insert(connections, humanoid.AncestryChanged:Connect(function()
		if not humanoid:IsDescendantOf(workspace) then
			disconnect()
		end
	end))
	
	-- Live state update
	table.insert(connections, RunService.Heartbeat:Connect(function(dt)
		timer += dt	
		if timer >= update then
			timer = 0
		end
	end))
end


return StateManager
