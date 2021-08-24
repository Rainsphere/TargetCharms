local frame = nil
local titleBar = nil

local incombat = UnitAffectingCombat("player")

local colors = {
    white = {r = 1, g = 1, b = 1},
    red = {r = 1, g = 0, b = 0}
}

local classColors = {
    druid = {r = 1, g = 0.49, b = 0.04},
    warlock = {r = 0.53, g = 0.53, b = 0.93},
    shaman = {r = 0.00, g = 0.44, b = 0.87},
    mage = {r = 0.25, g = 0.78, b = 0.92},
    hunter = {r = 0.67, g = 0.83, b = 0.45}
}

local charms = {
    {
        name = "Star",
        usage = "Rogue Sap",
        color = {r = 1.00, g = 0.96, b = 0.41}
    },
    {name = "Circle", usage = "Druid Hibernate", color = classColors.druid},
    {name = "Diamond", usage = "Warlock Banish", color = classColors.warlock},
    {name = "Triangle", usage = "Shaman Hex", color = classColors.shaman},
    {name = "Moon", usage = "Mage Polymorph", color = classColors.mage},
    {name = "Square", usage = "Hunter Trap", color = classColors.hunter},
    {name = "Cross", usage = "Secondary Target", color = colors.white},
    {name = "Skull", usage = "Main Target", color = colors.white}
}

function createButtons()
    for index = 1, 9 do
        local button =
            CreateFrame(
            "Button",
            ("Raid_Charms_Bar_Button%d"):format(index),
            Raid_Charms_Bar,
            "SecureActionButtonTemplate, BackdropTemplate"
        )

        button:SetHeight(18)
        button:SetWidth(18)

        local image = button:CreateTexture(nil, "BACKGROUND")
        image:SetAllPoints()
        image:SetTexture(
            index == 9 and "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up" or
                ("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"):format(index)
        )

        button:SetAttribute("type1", "macro")
        button:SetAttribute("macrotext1", ('/run SetRaidTargetIcon("target", %d)'):format(index < 9 and index or 0))

        button:SetScript(
            "OnEnter",
            function(self)
                self:SetBackdropBorderColor(.7, .7, 0)
                GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
                GameTooltip:SetText("Raid Charms")
                GameTooltip:AddLine(
                    index == 9 and "Click to remove the charm." or
                        "Click to add " .. charms[index]["name"] .. " to the target.",
                    1,
                    1,
                    1
                )
                if (index < 9) then
                    GameTooltip:AddDoubleLine(
                        "Typical Usage:",
                        charms[index]["usage"],
                        1,
                        1,
                        1,
                        charms[index]["color"]["r"],
                        charms[index]["color"]["g"],
                        charms[index]["color"]["b"]
                    )
                end
                GameTooltip:Show()
            end
        )
        button:SetScript(
            "OnLeave",
            function()
                GameTooltip:Hide()
            end
        )

        button:RegisterForClicks("AnyDown")
        frame.buttons[index] = button
    end
end

function SetPosition(f)
    local _, _, _, x, y = f:GetPoint()
    frame.position = {"TOPLEFT", "UIParent", "TOPLEFT", x, y}
end

function OnDragStart(f)
    if (not incombat) then
        f = f:GetParent()
        f:StartMoving()
    end
end

function OnDragStop(f)
    if (not incombat) then
        f = f:GetParent()
        SetPosition(f)
        f:StopMovingOrSizing()
    end
end

function createTitleBar()
    titleBar =
        CreateFrame(
        "Frame",
        "Raid_Charms_Bar_Titlebar",
        Raid_Charms_Bar,
        "SecureHandlerStateTemplate, BackdropTemplate"
    )
    titleBar:SetWidth(252)
    titleBar:SetHeight(20)
    titleBar:SetClampedToScreen(true)
    titleBar:SetMovable(true)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", OnDragStart)
    titleBar:SetScript("OnDragStop", OnDragStop)

    titleBar:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
    titleBar:SetBackdropColor(0, 0, 0, 0.7)
    titleBar:SetPoint("LEFT", 0, 0)
    titleBar:SetPoint("TOP", 0, 20)

    titleBar.text = titleBar:CreateFontString(nil, "ARTWORK")
    titleBar.text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
    titleBar.text:SetPoint("CENTER", 0, 0)
    titleBar.text:SetText("Raid Charms")
end

function initialize()
    frame = CreateFrame("Frame", "Raid_Charms_Bar", UIParent, "SecureHandlerStateTemplate, BackdropTemplate")
    frame:SetResizable(false)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame.buttons = {}

    frame:ClearAllPoints()
    frame:SetPoint("CENTER")

    frame:SetWidth(252)
    frame:SetHeight(30)
    frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
    frame:SetBackdropColor(0, 0, 0, 0.3)

    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:SetScript(
        "OnEvent",
        function(self, event)
            if (event == "PLAYER_REGEN_ENABLED") then
                incombat = false
            end
            if (event == "PLAYER_REGEN_DISABLED") then
                incombat = true
            end
        end
    )
    createTitleBar()
    createButtons()

    for i = 9, 1, -1 do
        local button = frame.buttons[i]
        local prev = frame.buttons[i + 1]
        button:ClearAllPoints()
        if i == 9 then
            button:SetPoint("LEFT", 3, 0)
        else
            button:SetPoint("LEFT", prev, "RIGHT", 10, 0)
        end
    end

    frame:Show()
    print("Raid Charms - TBC Loaded.")
end

initialize()
