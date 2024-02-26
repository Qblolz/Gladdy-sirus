--[[

Search Box Template

]]

function InputBoxInstructions_OnTextChanged(self)
	self.Instructions:SetShown(self:GetText() == "")
end

function InputBoxInstructions_UpdateColorForEnabledState(self, color)
	if color then
		self:SetTextColor(color:GetRGBA());
	end
end

function InputBoxInstructions_OnDisable(self)
	InputBoxInstructions_UpdateColorForEnabledState(self, self.disabledColor);
end

function InputBoxInstructions_OnEnable(self)
	InputBoxInstructions_UpdateColorForEnabledState(self, self.enabledColor);
end

function SearchBoxTemplate_OnLoad(self)
	self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
	self:SetTextInsets(16, 20, 0, 0);
	self.Instructions:SetText(SEARCH);
	self.Instructions:ClearAllPoints();
	self.Instructions:SetPoint("TOPLEFT", self, "TOPLEFT", 16, 0);
	self.Instructions:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -20, 0);
end

function SearchBoxTemplate_OnEditFocusLost(self)
	if ( self:GetText() == "" ) then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	end
end

function SearchBoxTemplate_OnEditFocusGained(self)
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
	self.clearButton:Show();
end

function SearchBoxTemplate_OnTextChanged(self)
	if ( not self:HasFocus() and self:GetText() == "" ) then
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	else
		self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.clearButton:Show();
	end
	InputBoxInstructions_OnTextChanged(self);
end

function SearchBoxTemplateClearButton_OnClick(self)
	--PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local editBox = self:GetParent();
	editBox:SetText("");
	editBox:ClearFocus();
end