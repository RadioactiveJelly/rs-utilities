-- Register the behaviour
behaviour("SetOutputMixerToWorld")

function SetOutputMixerToWorld:Awake()
	if self.targets.AudioSource == nil then return end

	self.targets.AudioSource.SetOutputAudioMixer(AudioMixer.World)
end
