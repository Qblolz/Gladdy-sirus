local __SendAddonMessage = SendAddonMessage

C_ChatInfo = C_ChatInfo or {}

local function TODO() end

function SendAddonMessage(...)
	local _, _, Type = ...
	if ( Type ~= "PARTY" and Type ~= "RAID" and Type ~= "GUILD" and Type ~= "BATTLEGROUND" and Type ~= "WHISPER" ) then
		return
	end

	__SendAddonMessage(...)
end

C_ChatInfo.RegisterAddonMessagePrefix = TODO
C_ChatInfo.CanPlayerSpeakLanguage = TODO
C_ChatInfo.CanReportPlayer = TODO
C_ChatInfo.GetChannelInfoFromIdentifier = TODO
C_ChatInfo.GetChannelRosterInfo = TODO
C_ChatInfo.GetChannelRuleset = TODO
C_ChatInfo.GetChannelShortcut = TODO
C_ChatInfo.GetChatLineSenderGUID = TODO
C_ChatInfo.GetChatLineSenderName = TODO
C_ChatInfo.GetChatLineText = TODO
C_ChatInfo.GetChatTypeName = TODO
C_ChatInfo.GetClubStreamIDs = TODO
C_ChatInfo.GetColorForChatType = TODO
C_ChatInfo.GetGeneralChannelID = TODO
C_ChatInfo.GetGeneralChannelLocalID = TODO
C_ChatInfo.GetMentorChannelID = TODO
C_ChatInfo.GetNumActiveChannels = TODO
C_ChatInfo.GetNumReservedChatWindows = TODO
C_ChatInfo.GetRegisteredAddonMessagePrefixes = TODO

function C_ChatInfo.IsAddonMessagePrefixRegistered()
	return true
end

C_ChatInfo.IsChannelRegional = TODO
C_ChatInfo.IsChatLineCensored = TODO
C_ChatInfo.IsPartyChannelType = TODO
C_ChatInfo.IsRegionalServiceAvailable = TODO
C_ChatInfo.IsValidChatLine = TODO
C_ChatInfo.RegisterAddonMessagePrefix = TODO
C_ChatInfo.ReplaceIconAndGroupExpressions = TODO
C_ChatInfo.ReportServerLag = TODO
C_ChatInfo.RequestCanLocalWhisperTarget = TODO
C_ChatInfo.ResetDefaultZoneChannels = TODO
C_ChatInfo.SendAddonMessage = SendAddonMessage
C_ChatInfo.SwapChatChannelsByChannelIndex = TODO
C_ChatInfo.UncensorChatLine = TODO