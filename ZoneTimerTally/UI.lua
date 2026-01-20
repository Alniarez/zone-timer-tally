-- ZoneTimerTally/UI.lua

local ZTT = ZoneTimerTally
local rows = {} -- each row contains multiple FontStrings
local totalTimeText
local totalGoldText
local UpdateList

--------------------------------------------------
-- Main frame
--------------------------------------------------

local frame = CreateFrame("Frame", "ZoneTimerTallyFrame", UIParent, "BackdropTemplate")
frame:SetSize(520, 520)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

--------------------------------------------------
-- Title
--------------------------------------------------

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -12)
title:SetText("ZoneTimer Tally")

--------------------------------------------------
-- Close button
--------------------------------------------------

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", -10, -10)

--------------------------------------------------
-- Column headers
--------------------------------------------------

local headerZone = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerZone:SetPoint("TOPLEFT", frame, "TOPLEFT", 24, -44)
headerZone:SetWidth(210)
headerZone:SetJustifyH("LEFT")
headerZone:SetText("Zone")

local headerTime = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerTime:SetPoint("LEFT", headerZone, "RIGHT", 0, 0)
headerTime:SetWidth(120)
headerTime:SetJustifyH("RIGHT")
headerTime:SetText("Time")

local headerGold = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
headerGold:SetPoint("LEFT", headerTime, "RIGHT", 6, 0)
headerGold:SetWidth(130)
headerGold:SetJustifyH("RIGHT")
headerGold:SetText("Gold")

--------------------------------------------------
-- Scroll frame
--------------------------------------------------

local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 18, -62)
scroll:SetPoint("BOTTOMRIGHT", -36, 50)

local content = CreateFrame("Frame", nil, scroll)
content:SetSize(360, 400)
scroll:SetScrollChild(content)

--------------------------------------------------
-- Export button
--------------------------------------------------

local exportButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
exportButton:SetSize(100, 22)
exportButton:SetPoint("BOTTOMRIGHT", -16, 16)
exportButton:SetText("Export")

--------------------------------------------------
-- Sort button
--------------------------------------------------

local sortButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
sortButton:SetSize(120, 22)
sortButton:SetPoint("BOTTOMRIGHT", exportButton, "BOTTOMLEFT", -6, 0)
sortButton:SetText("Sort: Time")

sortButton:SetScript("OnClick", function()
    if ZTT.sortMode == "time" then
        ZTT.sortMode = "gold"
        sortButton:SetText("Sort: Gold")
    else
        ZTT.sortMode = "time"
        sortButton:SetText("Sort: Time")
    end

    UpdateList()
end)

--------------------------------------------------
-- Row cleanup
--------------------------------------------------

local function ClearRows()
    for _, fs in ipairs(rows) do
        fs:Hide()
        fs:SetParent(nil)
    end
    wipe(rows)
end

--------------------------------------------------
-- Update list (column layout)
--------------------------------------------------

function UpdateList()
    ClearRows()

    local data = ZTT:GetSortedZones()
    local rowHeight = 22
    local startY = -8
    local totalTime = 0
    local totalGold = 0

    for i, entry in ipairs(data) do
        local y = startY - (i - 1) * rowHeight

        -- Zone column
        local zoneFS = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        zoneFS:SetPoint("TOPLEFT", 0, y)
        zoneFS:SetWidth(210)
        zoneFS:SetJustifyH("LEFT")
        zoneFS:SetWordWrap(false)
        zoneFS:SetText(entry.zone)

        zoneFS:SetScript("OnEnter", function(self)
            if self:IsTruncated() then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(entry.zone, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        zoneFS:SetScript("OnLeave", GameTooltip_Hide)

        table.insert(rows, zoneFS)

        -- Time column
        local timeFS = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        timeFS:SetPoint("LEFT", zoneFS, "RIGHT", 0, 0)
        timeFS:SetWidth(120)
        timeFS:SetJustifyH("RIGHT")
        timeFS:SetText(ZTT:ColorTime(ZTT:FormatTime(entry.time)))

        table.insert(rows, timeFS)

        -- Gold column
        local goldText = ZTT:ColorGold(ZTT:FormatGold(entry.gold))

        local goldFS = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        goldFS:SetPoint("LEFT", timeFS, "RIGHT", 6, 0)
        goldFS:SetWidth(130)
        goldFS:SetJustifyH("RIGHT")
        goldFS:SetWordWrap(false)
        goldFS:SetText(goldText)

        goldFS:SetScript("OnEnter", function(self)
            if self:IsTruncated() then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(goldText, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        goldFS:SetScript("OnLeave", GameTooltip_Hide)

        table.insert(rows, goldFS)

        totalTime = totalTime + entry.time
        totalGold = totalGold + entry.gold
    end

    content:SetHeight(math.max(400, (#data + 1) * rowHeight))

    totalTimeText:SetText(
            "Total Time: " .. ZTT:ColorTime(ZTT:FormatTime(totalTime))
    )
    totalGoldText:SetText(
            "Total Gold: " .. ZTT:ColorGold(ZTT:FormatGold(totalGold))
    )
end


--------------------------------------------------
-- Totals
--------------------------------------------------

totalTimeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
totalTimeText:SetPoint("BOTTOMLEFT", 20, 30)
totalTimeText:SetJustifyH("LEFT")
totalTimeText:SetText("Total Time: 0h 0m 0s")
totalTimeText:SetTextColor(1, 0.82, 0)

totalGoldText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
totalGoldText:SetPoint("TOPLEFT", totalTimeText, "BOTTOMLEFT", 0, -2)
totalGoldText:SetJustifyH("LEFT")
totalGoldText:SetText("Total Gold: 0g 0s 0c")
totalGoldText:SetTextColor(1, 0.82, 0)


--------------------------------------------------
-- Export window
--------------------------------------------------

local exportFrame = CreateFrame("Frame", "ZoneTimerTallyExportFrame", UIParent, "BackdropTemplate")
exportFrame:SetSize(600, 400)
exportFrame:SetFrameStrata("DIALOG")
exportFrame:SetFrameLevel(frame:GetFrameLevel() + 10)
exportFrame:SetPoint("CENTER", frame, "CENTER")
exportFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    edgeSize = 32,
    insets = { left = 12, right = 12, top = 12, bottom = 12 }
})
exportFrame:SetMovable(true)
exportFrame:EnableMouse(true)
exportFrame:RegisterForDrag("LeftButton")
exportFrame:SetScript("OnDragStart", exportFrame.StartMoving)
exportFrame:SetScript("OnDragStop", exportFrame.StopMovingOrSizing)
exportFrame:Hide()

-- Export close button
local exportClose = CreateFrame("Button", nil, exportFrame, "UIPanelCloseButton")
exportClose:SetPoint("TOPRIGHT", -8, -8)

-- Export title
local exportTitle = exportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
exportTitle:SetPoint("TOP", 0, -16)
exportTitle:SetText("ZoneTimer Tally – CSV Export")

-- Scroll + EditBox
local exportScroll = CreateFrame("ScrollFrame", nil, exportFrame, "UIPanelScrollFrameTemplate")
exportScroll:SetPoint("TOPLEFT", 16, -48)
exportScroll:SetPoint("BOTTOMRIGHT", -30, 16)

local editBox = CreateFrame("EditBox", nil, exportScroll)
editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(520)
editBox:SetAutoFocus(false)
editBox:EnableMouse(true)
editBox:SetScript("OnEscapePressed", function()
    exportFrame:Hide()
end)

exportScroll:SetScrollChild(editBox)

exportButton:SetScript("OnClick", function()
    local csv = ZTT:GenerateCSV()
    editBox:SetText(csv)
    editBox:HighlightText()
    exportFrame:Show()
end)



--------------------------------------------------
-- Slash command
--------------------------------------------------

SLASH_ZONETIMERTALLY1 = "/ztt"
SlashCmdList["ZONETIMERTALLY"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        sortButton:SetText(
                ZTT.sortMode == "gold" and "Sort: Gold" or "Sort: Time"
        )
        UpdateList()
        frame:Show()
    end
end
