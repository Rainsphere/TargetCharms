local frame = nil;
local titleBar = nil;

function createButtons()
    for index = 1,9 do
        local button =
			CreateFrame(
			"Button",
			("TargetCharms_Bar_Button%d"):format(index),
			TargetCharms_Bar,
			"SecureActionButtonTemplate, BackdropTemplate"
		);

        button:SetHeight(18);
		button:SetWidth(18);

        local image = button:CreateTexture(nil, "BACKGROUND");
		image:SetAllPoints();
		image:SetTexture(
			index == 9 and "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up" or
				("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"):format(index)
		);

        button:SetAttribute("type1", "macro");
		button:SetAttribute("macrotext1", ('/run SetRaidTargetIcon("target", %d)'):format(index < 9 and index or 0));

        button:SetScript(
            "OnEnter",
            function(self)
                self:SetBackdropBorderColor(.7, .7, 0)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
                GameTooltip:SetText("Target Charms")
                GameTooltip:AddLine(index == 9 and "Click to remove the charm." or "Click to add the charm to the target.", 1, 1, 1)
                GameTooltip:Show()
            end
        );
        button:SetScript(
            "OnLeave",
            function()
                GameTooltip:Hide()
            end
        );

        button:RegisterForClicks("AnyDown");
		frame.buttons[index] = button;
    end
end

function SetPosition(f)
    local _, _, _, x, y = f:GetPoint()
    frame.position = {"TOPLEFT", "UIParent", "TOPLEFT", x, y}
end

function OnDragStart(f)
    f = f:GetParent()
    f:StartMoving()
end

function OnDragStop(f)
    f = f:GetParent()
    SetPosition(f)
    f:StopMovingOrSizing()
end

function createTitleBar()
    titleBar = CreateFrame("Frame", "TargetCharms_Bar_Titlebar", TargetCharms_Bar, "SecureHandlerStateTemplate, BackdropTemplate");
    titleBar:SetWidth(252);
    titleBar:SetHeight(20);
    titleBar:SetClampedToScreen(true);
    titleBar:SetMovable(true);
    titleBar:EnableMouse(true);
    titleBar:RegisterForDrag("LeftButton");
    titleBar:SetScript("OnDragStart", OnDragStart);
    titleBar:SetScript("OnDragStop", OnDragStop);

    titleBar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"});
    titleBar:SetBackdropColor(0,0,0,0.7);
    titleBar:SetPoint("LEFT", 0, 0);
    titleBar:SetPoint("TOP", 0, 20);

    titleBar.text = titleBar:CreateFontString(nil,"ARTWORK");
    titleBar.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE");
    titleBar.text:SetPoint("CENTER",0,0);
    titleBar.text:SetText("Target Charms");

end

function initialize()
    
    frame = CreateFrame("Frame", "TargetCharms_Bar", UIParent, "SecureHandlerStateTemplate, BackdropTemplate");
    frame:SetResizable(false);
	frame:SetClampedToScreen(true);
    frame:SetMovable(true);
    frame.buttons = {};

    frame:ClearAllPoints();
	frame:SetPoint("CENTER");

    frame:SetWidth(252);
    frame:SetHeight(30);
    frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"});
    frame:SetBackdropColor(0,0,0,0.3);

    createTitleBar();
    createButtons();

    for i = 9, 1, -1 do
		local button = frame.buttons[i]
		local prev = frame.buttons[i + 1]
		button:ClearAllPoints()
        if i == 9 then
            button:SetPoint("LEFT", 3, 0);
        else
            button:SetPoint("LEFT", prev, "RIGHT", 10, 0);
        end
	end

    frame:Show();
    print("Target Charms Loaded.");
end

initialize();