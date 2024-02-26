local WIDTH, HEIGHT = 858, 660
local IOF = InterfaceOptionsFrame

IOF:SetPoint("CENTER", UIParent, "CENTER")

InterfaceOptionsFrameCategories:SetPoint("BOTTOMLEFT", IOF, "BOTTOMLEFT", 22, 50)
InterfaceOptionsFrameAddOns:SetPoint("BOTTOMLEFT", IOF, "BOTTOMLEFT", 22, 50)

IOF:SetFrameStrata("FULLSCREEN_DIALOG")
IOF:SetSize(WIDTH, HEIGHT)
IOF:SetToplevel(true)
IOF:HookScript("OnShow", function()
	IOF:SetSize(WIDTH, HEIGHT)
end)