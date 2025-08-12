-- Sound manager for playing a sound per shot.
-- Uses the AudioSourceManager object to detach its audio sources for better sound handling when a weapon is swapped/destroyed
behaviour("SoundManager")

function SoundManager:Start()
	local weapon = self.targets.Weapon

	if weapon == nil then return end

	weapon.onFire.AddListener(self,"OnWeaponFire")

	--If bot use 3D spatial blend
	if weapon.user then
		if not weapon.user.isPlayer then
			self.AudioSource = self.targets.TPAudioSource
			self.AudioSource.SetOutputAudioMixer(AudioMixer.World)
		else
			self.AudioSource = self.targets.FPAudioSource
			self.AudioSource.SetOutputAudioMixer(AudioMixer.FirstPerson)
		end
		if _audioSourceManager == nil then
			local managerPrefab = self.targets.SoundData.GetGameObject("AudioSourceManager")
			GameObject.Instantiate(managerPrefab)
		end
		_audioSourceManager:AddAudioSource(weapon.user, weapon.weaponEntry.name, self.AudioSource.gameObject)
	end
end

function SoundManager:OnWeaponFire()
	if self.AudioSource then
		self.AudioSource.Play()
	end
end

function SoundManager:ToggleSoundType(loud)
	if loud then
		if self.targets.SoundData.HasAudioClip("SingleFireLoud") then
			self.AudioSource.clip = self.targets.SoundData.GetAudioClip("SingleFireLoud")
		end
	else
		if self.targets.SoundData.HasAudioClip("SingleFireSuppressed") then
			self.AudioSource.clip = self.targets.SoundData.GetAudioClip("SingleFireSuppressed")
		end
	end
end