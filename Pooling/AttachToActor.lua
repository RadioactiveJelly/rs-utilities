--Attach the game object this script belongs to to the actor and returns it to the pool once its lifetime expires.
--Uses the actors position or center position.
--Requires a DataContainer labeled "DataContainer" with a boolean variable "UseCenterPosition"
behaviour("AttachToActor")

function AttachToActor:SetTarget(actor, pool, lifetime)
	self.targetActor = actor
	self.useCenter = self.targets.DataContainer.GetBool("UseCenterPosition")
	self.pool = pool
	self.lifetime = lifetime or 2
	self.timer = 0
end

function AttachToActor:Update()
	if self.targetActor == nil then return end
	self.timer = self.timer + Time.deltaTime

	if self.useCenter then
		self.transform.position = self.targetActor.centerPosition
	else
		self.transform.position = self.targetActor.position
	end

	if self.timer >= self.lifetime then
		self.targetActor = nil
		self.pool:pool(self)
	end
end

