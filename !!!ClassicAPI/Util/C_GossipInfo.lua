C_GossipInfo = C_GossipInfo or {}

function C_GossipInfo.GetText()
	return GetGossipText()
end

function C_GossipInfo.GetNumActiveQuests()
	return GetNumGossipActiveQuests()
end

function C_GossipInfo.GetNumAvailableQuests()
	return GetNumGossipAvailableQuests()
end