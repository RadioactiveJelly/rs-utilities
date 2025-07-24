-- Register the behaviour
behaviour("SelfReturningPoolable")

function SelfReturningPoolable:Init(pool, lifetime)
	self.lifetime = lifetime
	self.timer = 0
	self.initialized = true
	self.pool = pool
end

function SelfReturningPoolable:Update()
	if not self.initialized then return end
	
	self.timer = self.timer + Time.deltaTime
	if self.timer >= self.lifetime then
		self.pool:pool(self)
	end
end
