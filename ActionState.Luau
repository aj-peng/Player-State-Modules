--!strict
--[[ NOTE: Module to be used on the client only. ]]--
export type State = {
	CurrentAction : string?,
	LockExpireTime : number,
	LockPriority : number,
}

local State : State = {
	CurrentAction = nil,       -- "Weapon", "Ability", or nil
	LockExpireTime = 0,
	LockPriority = 0         -- Higher priority actions can interrupt lower ones. Same priority actions can't interrupt each other.
}

local Priority = {
	-- Action1 = 1,
	-- Action2 = 2,
	-- Action3 = 3,
}

local UpdateEvent = Instance.new("BindableEvent")

local function GetLocked() : boolean
	if State.CurrentAction and os.clock() >= State.LockExpireTime then
		State.CurrentAction = nil
		State.LockExpireTime = 0
		State.LockPriority = 0
	end
	
	return State.CurrentAction ~= nil
end


return {
	GetLocked = function()
		return GetLocked()
	end,
	
	GetState = function()
		return {
			Action = State.CurrentAction,
			Locked = GetLocked(),
			Priority = State.LockPriority
		}
	end,
	
	Claim = function(action: string, duration: number?, priority: number) : boolean
		if GetLocked() then
			if priority <= State.LockPriority then
				return false
			end
		end
		
		State.CurrentAction = action
		State.LockExpireTime = duration and (os.clock() + duration) or math.huge
		State.LockPriority = priority
		UpdateEvent:Fire()

		return true
	end,
	
	Release = function(action: string?)
		if action == nil or State.CurrentAction == action then
			State.CurrentAction = nil
			State.LockExpireTime = 0
			State.LockPriority = 0
		end
	end,
	
	Priority = Priority,
	Update = UpdateEvent
}
