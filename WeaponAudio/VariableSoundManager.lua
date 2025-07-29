-- Sound manager for using looped audio for firing sounds.
-- Handles transitioning into full auto loops past the first shot.
-- Requires a DataContainer labeled as "SoundData"
-- Uses the AudioSourceManager object to detach its audio sources for better sound handling when a weapon is swapped/destroyed
behaviour("VariableSoundManager")

function VariableSoundManager:Start()
	self.weapon = self.targets.Weapon

	if self.weapon == nil then return end

	self.weapon.onFire.AddListener(self,"OnWeaponFire")

	--If bot use 3D spatial blend
	if self.weapon.user then
		if not self.weapon.user.isPlayer then
			self.AudioSource = self.targets.TPAudioSource
			self.TailSource = self.targets.TPTail
			self.TailSource.SetOutputAudioMixer(AudioMixer.World)
			self.AudioSource.SetOutputAudioMixer(AudioMixer.World)
		else
			self.AudioSource = self.targets.FPAudioSource
			self.TailSource = self.targets.FPTail
			self.TailSource.SetOutputAudioMixer(AudioMixer.FirstPerson)
			self.AudioSource.SetOutputAudioMixer(AudioMixer.FirstPerson)
		end
		self.AudioSource.gameObject.SetActive(true)
		self.maxVol = self.AudioSource.volume

		if _audioSourceManager == nil then
			local managerPrefab = self.targets.SoundData.GetGameObject("AudioSourceManager")
			local obj = GameObject.Instantiate(managerPrefab)
		end
		_audioSourceManager:AddAudioSource(self.weapon.user, self.weapon.weaponEntry.name, self.AudioSource.gameObject)
	end
	self.didFire = false
	self.looping = false
	self.shots = 0
end

function VariableSoundManager:OnEnable()
	self.shots = 0
	
end

function VariableSoundManager:OnDisable()
	if self.weapon == nil then return end

	--End looping audio if the weapon is swapped/destroyed
	self:CheckLoop(true)
end

function VariableSoundManager:Update()
	if self.weapon == nil then return end

	--Once the weapon is done cooling down, end the firing loop.
	if not self.weapon.isCoolingDown then
		self:CheckLoop(false)
	end
end

function VariableSoundManager:CheckLoop(instant)
	self.firing = false
	--If more than one shot was fired, use the tail audio specifically for the looped audio.
	if self.shots > 1 then
		self.AudioSource.loop = false
		self.TailSource.Play()
		if instant then
			self.AudioSource.volume = 0
		else
			self.script.StartCoroutine(self:LoopFade())
		end
	end
	self.shots = 0 
end

function VariableSoundManager:OnWeaponFire()
	if self.AudioSource then
		self.firing = true
		self.AudioSource.volume = self.maxVol
		--If it's the first shot, play the single fire version.
		if self.shots == 0 then
			self.AudioSource.clip = self.singleFireShot
			self.AudioSource.Play()
		--In subsequent shots, play the full auto loop.
		elseif self.shots == 1 then
			self.AudioSource.clip = self.fullAutoLoop
			self.AudioSource.loop = true
			self.AudioSource.Play()
		end
		self.shots = self.shots + 1
	end
end

function VariableSoundManager:ToggleSoundType(loud)
	--Call this to change the firing sounds being used by your gun.
	--Requires a DataContainer set as a target named SoundData.
	if loud then
		if self.targets.SoundData.HasAudioClip("SingleFireLoud") then
			self.singleFireShot = self.targets.SoundData.GetAudioClip("SingleFireLoud")
		end
		if self.targets.SoundData.HasAudioClip("FullAutoLoopLoud") then
			self.fullAutoLoop = self.targets.SoundData.GetAudioClip("FullAutoLoopLoud")
		end
		if self.targets.SoundData.HasAudioClip("FullAutoTailLoud") then
			self.TailSource.clip = self.targets.SoundData.GetAudioClip("FullAutoTailLoud")
		end
	else
		if self.targets.SoundData.HasAudioClip("SingleFireSuppressed") then
			self.singleFireShot = self.targets.SoundData.GetAudioClip("SingleFireSuppressed")
		end
		if self.targets.SoundData.HasAudioClip("FullAutoLoopSuppressed") then
			self.fullAutoLoop = self.targets.SoundData.GetAudioClip("FullAutoLoopSuppressed")
		end
		if self.targets.SoundData.HasAudioClip("FullAutoTailLoudSuppressed") then
			self.TailSource.clip = self.targets.SoundData.GetAudioClip("FullAutoTailLoudSuppressed")
		end
	end
end

function VariableSoundManager:LoopFade()
	return function()
		local elapsedTime = 0.0
		local duration = 0.1

		while(elapsedTime < duration) do
			elapsedTime = elapsedTime + Time.deltaTime

			local t = elapsedTime/duration

			self.AudioSource.volume = (1 - t) * self.maxVol

			if t >= 1 or self.firing then break
			else coroutine.yield() end
		end
	end
end