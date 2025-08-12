-- Register the behaviour
behaviour("ObjectRotator")

function ObjectRotator:Start()
	self.direction = self.targets.DataContainer.GetVector("RotationDirection")
	self.speed = self.targets.DataContainer.GetFloat("RotationSpeed")
end

function ObjectRotator:Update()
	local delta = self.speed * Time.deltaTime
	self.transform.Rotate(self.direction.x * delta, self.direction.y * delta, self.direction.z * delta)
end
