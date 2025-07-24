-- Register the behaviour
behaviour("PoolManager")

_poolManager = nil

function PoolManager:Awake()
	self.pools = {}
	_poolManager = self
end

function PoolManager:GetPool(poolName)
	if self.pools == nil then self.pools = {} end

	if self.pools[poolName] == nil then
		self.pools[poolName] = Pool:new()
		print("[PoolManager.GetPool] Object Pool for " .. poolName .. " created.")
	end
	
	return self.pools[poolName]
end

function PoolManager:OnDestroy()
	_poolManager = nil
end

--Object responsible for handling a pool for a given prefab
Pool = {prefab = nil, stackCount = 0, stack = {}, initialized = false, objectType = nil}
function Pool:new()
	local instance = 
	{
		prefab = nil,
		stackCount = 0,
		stack = {},
		autoSetActive = true,
		initialized = false,
		objectType = nil
	}
	return setmetatable(instance, {__index = Pool})
end

--Initialize the pool's prefab. This is important! Always call this before doing anything else with the pool.
--A object type is required for the pool to know what kind of objects we're dealing with in the pool. If no type is given, the pool will default to GameObjects.
function Pool:initialize(prefab, objectType)
	if self.prefab then
		print("<color=red> ERROR: [Pool:initialize] You cannot change a pool's prefab!</color>")
		return 
	end

	self.prefab = prefab
	if objectType then
		local luaType = type(objectType)
		if luaType == "userdata" then
			self.objectType = objectType
		elseif luaType == "string" then
			self.objectType = behaviour(objectType)
			print("[Pool:initialize]Registered behaviour of type " .. objectType)
		end
	else
		print("[Pool:initialize]Pool was not given a type, defaulting to GameObject")
	end
	
	self.initialized = true
end

--Preload the instances of the prefab the pool is responsible for.
function Pool:prePool(initialSize)
	if not self.initialized then
		print("<color=red> ERROR: [Pool:prePool] Attempted to prepool an uninitialized pool!</color>")
		return 
	end
	if self.prePooled then return end

	local size = initialSize or 16
	for i = 1, size, 1 do
		local obj = nil
		if self.objectType == nil then
			obj = GameObject.Instantiate(self.prefab)
		else
			obj = GameObject.Instantiate(self.prefab).GetComponent(self.objectType)
		end
		if obj == nil then
			print("<color=red> ERROR: [Pool:prePool] Prefab provided is not the correct type!</color>")
			return
		end
		self:pool(obj)
	end
	self.prePooled = true
end

--Request an object from the pool. If the pool is empty, instantiates a new instace of the object.
function Pool:requestObject()
	if not self.initialized then
		print("<color=red> ERROR: [Pool:requestObject] Attempted to request an object from an uninitialized pool!</color>")
		return
	end

	local obj = nil
	if self.stackCount == 0 then
		if self.objectType then
			obj = GameObject.Instantiate(self.prefab).GetComponent(self.objectType)
		else
			obj = GameObject.Instantiate(self.prefab)
		end
		
		if obj == nil then
			print("<color=red> ERROR: [Pool:requestObject] Prefab requested is not the correct type!</color>")
		end
	else
		obj = table.remove(self.stack)
		self.stackCount = self.stackCount - 1
	end

	obj.gameObject.SetActive(self.autoSetActive)
	obj.gameObject.name = self.prefab.name
	return obj
end

--Return the object to the pool.
function Pool:pool(obj)
	if not self.initialized then
		print("<color=red> ERROR: [Pool:pool] Attempted to return an object to an uninitialized pool!</color>")
		return
	end
	
	obj.gameObject.SetActive(false)
	table.insert(self.stack, obj)
	self.stackCount = self.stackCount + 1
	obj.gameObject.name = self.prefab.name .. " (Pooled)"
end

--Releases all instances in the pool's stack.
function Pool:release()
	for i = 1, self.stackCount, 1 do
		local obj = self.stack[i]
		GameObject.Destroy(obj.gameObject)
	end
	self.stack = nil
end

function Pool:count()
	return self.stackCount
end