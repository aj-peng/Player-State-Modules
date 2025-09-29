--!strict
export type ActionState = {
	CurrentAction : string?,
	LockExpireTime : number,
	LockPriority : number,
	ActionQueue : {}
}

local ActionState : ActionState = {
	CurrentAction = nil,       -- "Weapon", "Ability", or nil
	LockExpireTime = 0,
	LockPriority = 0,         -- Higher priority actions can interrupt lower ones
	ActionQueue = {}
}

local PRIORITY : {[string]: number} = {
	-- Action_1 = 1,
	-- Action_2 = 2,
	-- Action_3 = 3,
}

local function isActionLocked()
	return ActionState.CurrentAction and os.clock() < ActionState.LockExpireTime
end

return {
	TryClaim = function(actionType: string, duration: number?, priority: number)
		if isActionLocked() and priority <= ActionState.LockPriority then
			return false
		end

		ActionState.CurrentAction = actionType
		ActionState.LockPriority = priority
		ActionState.LockExpireTime = duration and (os.clock() + duration) or math.huge

		if duration then
			task.delay(duration, function()
				if ActionState.CurrentAction == actionType then
					ActionState.CurrentAction = nil
					ActionState.LockPriority = 0
				end
			end)
		end

		return true
	end,

	-- Release the action state
	Release = function(actionType: string)
		if ActionState.CurrentAction == actionType then
			ActionState.CurrentAction = nil
			ActionState.LockPriority = 0
			ActionState.LockExpireTime = 0
		end
	end,

	-- Check if an action can be performed
	CanPerform = function(actionType: string, priority: number)
		if not isActionLocked() then return true end
		return priority > ActionState.LockPriority
	end,
	
	isActionLocked = function()  -- Add this
		return isActionLocked()
	end,
	
	-- Get current action state
	GetState = function()
		return {
			CurrentAction = ActionState.CurrentAction,
			IsLocked = isActionLocked(),
			Priority = ActionState.LockPriority
		}
	end,

	PRIORITY = PRIORITY
}
