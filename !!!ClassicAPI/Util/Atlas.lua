ATLAS_INFO_STORAGE = ATLAS_INFO_STORAGE or {}

local _ = ATLAS_INFO_STORAGE
local CAPI_TEXTURE_PATH = "Interface\\AddOns\\!!!ClassicAPI\\Texture\\" -- Make this global in restructure.

--[[
	INFORMATION
	=================================

	Build: 3.4.2 (50664):
		https://www.townlong-yak.com/framexml/9.2.7/Helix/AtlasInfo.lua
		https://github.com/Ketho/BlizzardInterfaceResources/blob/wrath/Resources/AtlasInfo.lua
		https://github.com/Gethe/wow-ui-textures

	Build (Fallback): 10.1.5 (50622):
		https://github.com/Ketho/BlizzardInterfaceResources/blob/mainline/Resources/AtlasInfo.lua
		https://wow.tools

	Manual Calc: X/WIDTH || Y/HEIGHT
]]

-- _["atlasName"]={width, height, left, right, top, bottom, tilesHoriz, tilesVert, texturePath}

-- Interface/FrameGeneral/UIFrameDiamondMetal
local FrameGeneral_UIFrameDiamondMetal = CAPI_TEXTURE_PATH.."FrameGeneral\\UIFrameDiamondMetal"
_["UI-Frame-DiamondMetal-CornerBottomLeft"]={32, 32, 0.015625, 0.515625, 0.269531, 0.394531, false, false, FrameGeneral_UIFrameDiamondMetal}
_["UI-Frame-DiamondMetal-CornerBottomRight"]={32, 32, 0.015625, 0.515625, 0.402344, 0.527344, false, false, FrameGeneral_UIFrameDiamondMetal}
_["UI-Frame-DiamondMetal-CornerTopLeft"]={32, 32, 0.015625, 0.515625, 0.535156, 0.660156, false, false, FrameGeneral_UIFrameDiamondMetal}
_["UI-Frame-DiamondMetal-CornerTopRight"]={32, 32, 0.015625, 0.515625, 0.667969, 0.792969, false, false, FrameGeneral_UIFrameDiamondMetal}
_["_UI-Frame-DiamondMetal-EdgeBottom"]={32, 32, 0, 0.5, 0.00390625, 0.128906, false, false, FrameGeneral_UIFrameDiamondMetal}
_["_UI-Frame-DiamondMetal-EdgeTop"]={32, 32, 0, 0.5, 0.136719, 0.261719, false, false, FrameGeneral_UIFrameDiamondMetal}

-- Interface/FrameGeneral/UIFrameDiamondMetalVertical
local FrameGeneral_UIFrameDiamondMetalVertical = CAPI_TEXTURE_PATH.."FrameGeneral\\UIFrameDiamondMetalVertical"
_["!UI-Frame-DiamondMetal-EdgeLeft"]={32, 32, 0.0078125, 0.257812, 0, 1, false, false, FrameGeneral_UIFrameDiamondMetalVertical}
_["!UI-Frame-DiamondMetal-EdgeRight"]={32, 32, 0.273438, 0.523438, 0, 1, false, false, FrameGeneral_UIFrameDiamondMetalVertical}

-- Interface/RaidFrame/RaidFrameSummon
local RaidFrame_RaidFrameSummon = CAPI_TEXTURE_PATH.."RaidFrame\\RaidFrameSummon"
_["Raid-Icon-SummonAccepted"]={32, 32, 0.0078125, 0.257812, 0.015625, 0.515625, false, false, RaidFrame_RaidFrameSummon}
_["Raid-Icon-SummonDeclined"]={32, 32, 0.273438, 0.523438, 0.015625, 0.515625, false, false, RaidFrame_RaidFrameSummon}
_["Raid-Icon-SummonPending"]={32, 32, 0.539062, 0.789062, 0.015625, 0.515625, false, false, RaidFrame_RaidFrameSummon}

-- Interface/ContainerFrame/Bags
local ContainerFrame_Bags = CAPI_TEXTURE_PATH.."ContainerFrame\\Bags"
_["bags-newitem"]={44, 44, 0.363281, 0.535156, 0.00390625, 0.175781, false, false, ContainerFrame_Bags}
_["bags-junkcoin"]={20, 18, 0.863281, 0.941406, 0.28125, 0.351562, false, false, ContainerFrame_Bags}
_["bags-innerglow"]={36, 36, 0.164062, 0.304688, 0.539062, 0.679688, false, false, ContainerFrame_Bags}
_["bags-glow-purple"]={39, 39, 0.00390625, 0.15625, 0.539062, 0.691406, false, false, ContainerFrame_Bags}
_["bags-glow-blue"]={39, 39, 0.542969, 0.695312, 0.164062, 0.316406, false, false, ContainerFrame_Bags}
_["bags-glow-orange"]={39, 39, 0.707031, 0.859375, 0.363281, 0.515625, false, false, ContainerFrame_Bags}
_["bags-glow-green"]={39, 39, 0.703125, 0.855469, 0.00390625, 0.15625, false, false, ContainerFrame_Bags}
_["bags-glow-heirloom"]={39, 39, 0.703125, 0.855469, 0.164062, 0.316406, false, false, ContainerFrame_Bags}
_["bags-glow-white"]={39, 39, 0.00390625, 0.15625, 0.699219, 0.851562, false, false, ContainerFrame_Bags}
_["bags-glow-flash"]={90, 90, 0.00390625, 0.355469, 0.00390625, 0.355469, false, false, ContainerFrame_Bags}
_["bags-button-autosort-down"]={28, 26, 0.164062, 0.273438, 0.835938, 0.9375, false, false, ContainerFrame_Bags}
_["bags-button-autosort-up"]={28, 26, 0.3125, 0.421875, 0.539062, 0.640625, false, false, ContainerFrame_Bags}
_["bags-roundhighlight"]={36, 36, 0.164062, 0.304688, 0.6875, 0.828125, false, false, ContainerFrame_Bags}
_["bags-icon-consumables"]={28, 28, 0.863281, 0.972656, 0.00390625, 0.113281, false, false, ContainerFrame_Bags}
_["bags-icon-equipment"]={28, 28, 0.863281, 0.972656, 0.164062, 0.273438, false, false, ContainerFrame_Bags}
_["bags-icon-tradegoods"]={28, 28, 0.867188, 0.976562, 0.363281, 0.472656, false, false, ContainerFrame_Bags}
_["bags-glow-artifact"]={39, 39, 0.542969, 0.695312, 0.00390625, 0.15625, false, false, ContainerFrame_Bags}
_["bags-greenarrow"]={20, 22, 0.3125, 0.390625, 0.648438, 0.734375, false, false, ContainerFrame_Bags}
_["bags-icon-addslots"]={42, 42, 0.363281, 0.527344, 0.183594, 0.347656, false, false, ContainerFrame_Bags}
_["bags-static"]={178, 43, 0.00390625, 0.699219, 0.363281, 0.53125, false, false, ContainerFrame_Bags}
_["bags-icon-scrappable"]={36, 32, 0.00390625, 0.144531, 0.859375, 0.984375, false, false, ContainerFrame_Bags}