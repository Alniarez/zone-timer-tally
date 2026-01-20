-- ZoneTimerTally/Core.lua

ZoneTimerTally = {}
ZoneTimerTally.data = {}
ZoneTimerTally.sortMode = "time" -- "time" | "gold"
ZoneTimerTally.VERSION = "1.2"
ZoneTimerTally.DEBUG = false

-- Accessors -----------------------------

function ZoneTimerTally:GetZoneTimes()
    if not ZoneTimerSettings or not ZoneTimerSettings.times then
        return {}
    end
    return ZoneTimerSettings.times
end

function ZoneTimerTally:GetZoneGold(zone)
    if not ZoneGoldDB then return 0 end
    return ZoneGoldDB[zone] or 0
end

-- Formatting helpers ------------------------------

function ZoneTimerTally:FormatGold(copper)
    copper = tonumber(copper) or 0
    local g = math.floor(copper / 10000)
    local s = math.floor((copper % 10000) / 100)
    local c = copper % 100
    return string.format("%dg %ds %dc", g, s, c)
end

function ZoneTimerTally:ColorGold(text)
    -- expects output from FormatGold()
    local g, s, c = text:match("(%d+)g (%d+)s (%d+)c")
    if not g then
        return text -- fail-safe
    end

    return string.format(
            "|cffFFD700%sg|r |cffffffff%ss|r |cffff7f00%sc|r",
            g, s, c
    )
end

function ZoneTimerTally:FormatTime(seconds)
    seconds = tonumber(seconds) or 0

    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60

    if h > 0 then
        return string.format("%dh %dm %ds", h, m, s)
    end

    if m > 0 then
        return string.format("%dm %ds", m, s)
    end

    return string.format("%ds", s)
end

function ZoneTimerTally:ColorTime(text)
    local h, m, s = text:match("(%d+)h (%d+)m (%d+)s")
    if h then
        return string.format(
                "|cffffd200%sh|r |cffc7c7cf%sm|r |cff9d9d9d%ss|r",
                h, m, s
        )
    end

    -- Fallback for condensed format (no seconds)
    h, m = text:match("(%d+)h (%d+)m")
    if h then
        return string.format(
                "|cffffd200%sh|r |cffc7c7cf%sm|r",
                h, m
        )
    end

    return text
end

-- Aggregation ------------------------------------

function ZoneTimerTally:GetSortedZones()
    local zones = self:GetZoneTimes()
    local list = {}

    for zone, time in pairs(zones) do
        table.insert(list, {
            zone = zone,
            time = time,
            gold = self:GetZoneGold(zone)
        })
    end

    -- DEBUG TEST ROWS
    if self.DEBUG then
        for i = 1, 20 do
            table.insert(list, {
                zone = string.format(
                        "DEBUG %02d – VERY LONG ZONE NAME lalalalalalala lalala lilo loalalalala lalalala",
                        i
                ),
                time = 90000000 + (i * 12345),      -- staggered large times
                gold = 90000000000 + (i * 987654),  -- staggered large gold (copper)
                __debug = true
            })
        end
    end

    table.sort(list, function(a, b)
        if a.__debug and not b.__debug then return true end
        if b.__debug and not a.__debug then return false end

        if self.sortMode == "gold" then
            return a.gold > b.gold
        end

        -- default: time
        return a.time > b.time
    end)


    return list
end


-- Export to CSV ------------------------------------

function ZoneTimerTally:GenerateCSV()
    local lines = {}

    table.insert(lines, "Zone,TimeSeconds,TimeFormatted,GoldCopper,GoldFormatted")

    for _, entry in ipairs(self:GetSortedZones()) do
        local timeSeconds = tostring(math.floor(entry.time))
        local goldCopper  = tostring(entry.gold)

        table.insert(lines, string.format(
                "%q,%s,%q,%s,%q",
                entry.zone,
                timeSeconds,
                self:FormatTime(entry.time),
                goldCopper,
                self:FormatGold(entry.gold)
        ))
    end

    return table.concat(lines, "\n")
end
