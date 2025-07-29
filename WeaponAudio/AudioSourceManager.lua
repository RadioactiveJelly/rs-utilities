behaviour("AudioSourceManager")
--Detaches audio sources from weapons. This ensures that when weapons become disabled, audio does not get cut off and naturally ends.
--Audio sources are removed once an actor dies.
--This is handled in a per .rfc, so each mod will have its own audio source manager present! This instance is shared for all instances of the same weapon in a match.
_audioSourceManager = nil

function AudioSourceManager:Awake()
	_audioSourceManager = self

	print("Created audio source manager!")
	self.audioSources = {}
	GameEvents.onActorDiedInfo.AddListener(self,"OnActorDiedInfo")
end

function AudioSourceManager:AddAudioSource(actor,weaponName,audioSourceObject)
	if self.audioSources[actor.name] == nil then
		self.audioSources[actor.name] = {}
	end
	local actorTable = self.audioSources[actor.name]
	actorTable[weaponName] = audioSourceObject
	audioSourceObject.transform.SetParent(actor.transform)
end

function AudioSourceManager:OnActorDiedInfo(actor, info, isSilentKill)
	if self.audioSources[actor.name] == nil then return end

	for weaponName, audioObject in pairs(self.audioSources[actor.name]) do
		if audioObject then GameObject.Destroy(audioObject) end
	end

	self.audioSources[actor.name] = {}
end

function AudioSourceManager:OnDisable()
	_audioSourceManager = nil
end