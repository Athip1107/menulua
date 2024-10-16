MIOddhwuie = {}
MIOddhwuie.debug = false

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 191, back = 202}
local optionCount = 0
local currentKey = nil
local currentMenu = nil

-- Menu layout settings
local titleHeight = 0.11
local titleXOffset = 0.5
local titleSpacing = 2
local titleYOffset = 0.03
local titleScale = 1.0
local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

-- Debug function
local function debugPrint(text)
    if MIOddhwuie.debug then
        Citizen.Trace('[MIOddhwuie] ' .. tostring(text))
    end
end

-- Menu property functions
local function setMenuProperty(id, property, value)
    if id and menus[id] then
        menus[id][property] = value
        debugPrint(id .. ' menu property changed: { ' .. tostring(property) .. ', ' .. tostring(value) .. ' }')
    end
end

local function isMenuVisible(id)
    if id and menus[id] then
        return menus[id].visible
    else
        return false
    end
end

local function setMenuVisible(id, visible, holdCurrent)
    if id and menus[id] then
        setMenuProperty(id, 'visible', visible)
        if not holdCurrent then
            setMenuProperty(id, 'currentOption', 1)
        end
        if visible then
            if id ~= currentMenu and isMenuVisible(currentMenu) then
                setMenuVisible(currentMenu, false)
            end
            currentMenu = id
        end
    end
end

-- Drawing functions
local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
    SetTextColour(color.r, color.g, color.b, color.a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    if shadow then
        SetTextDropShadow(2, 2, 0, 0, 0)
    end
    if menus[currentMenu] then
        if center then
            SetTextCentre(center)
        elseif alignRight then
            SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menus[currentMenu].width - buttonTextXOffset)
            SetTextRightJustify(true)
        end
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function drawRect(x, y, width, height, color)
    DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

-- Title and button drawing
local function drawTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menus[currentMenu].width / 2
        local y = menus[currentMenu].y + titleHeight * 1 / titleSpacing
        drawRect(x, y, menus[currentMenu].width, titleHeight, menus[currentMenu].titleBackgroundColor)
        drawText(menus[currentMenu].title, x, y - titleHeight / 2 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale, true)
    end
end

local function drawSubTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menus[currentMenu].width / 2
        local y = menus[currentMenu].y + titleHeight + buttonHeight / 2
        drawRect(x, y, menus[currentMenu].width, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
        drawText(menus[currentMenu].subTitle, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, menus[currentMenu].titleBackgroundColor, buttonScale, false)
        if optionCount > menus[currentMenu].maxOptionCount then
            drawText(tostring(menus[currentMenu].currentOption) .. ' / ' .. tostring(optionCount), menus[currentMenu].x + menus[currentMenu].width, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, menus[currentMenu].titleBackgroundColor, buttonScale, false, false, true)
        end
    end
end

local function drawButton(text, subText)
    local x = menus[currentMenu].x + menus[currentMenu].width / 2
    local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * optionCount) - buttonHeight / 2
    local backgroundColor, textColor

    if menus[currentMenu].currentOption == optionCount then
        backgroundColor = menus[currentMenu].menuFocusBackgroundColor
        textColor = menus[currentMenu].menuFocusTextColor
    else
        backgroundColor = menus[currentMenu].menuBackgroundColor
        textColor = menus[currentMenu].menuTextColor
    end

    drawRect(x, y, menus[currentMenu].width, buttonHeight, backgroundColor)
    drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false)
    
    if subText then
        drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, textColor, buttonScale, false, false, true)
    end
end

-- Menu creation functions
function MIOddhwuie.CreateMenu(id, title)
    menus[id] = {
        title = title,
        subTitle = 'INTERACTION MENU',
        visible = false,
        currentOption = 1,
        maxOptionCount = 10,
        titleFont = 1,
        titleColor = {r = 0, g = 0, b = 0, a = 255},
        titleBackgroundColor = {r = 245, g = 127, b = 23, a = 255},
        menuTextColor = {r = 255, g = 255, b = 255, a = 255},
        menuFocusBackgroundColor = {r = 245, g = 245, b = 245, a = 255},
        menuBackgroundColor = {r = 0, g = 0, b = 0, a = 160},
        subTitleBackgroundColor = {r = 0, g = 0, b = 0, a = 255}
    }
    debugPrint(id .. ' menu created')
end

-- Menu interaction functions
function MIOddhwuie.OpenMenu(id)
    if id and menus[id] then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        setMenuVisible(id, true)
        debugPrint(id .. ' menu opened')
    end
end

function MIOddhwuie.Display()
    if isMenuVisible(currentMenu) then
        drawTitle()
        drawSubTitle()
        currentKey = nil
        if IsDisabledControlJustReleased(1, keys.down) then
            if menus[currentMenu].currentOption < optionCount then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
            else
                menus[currentMenu].currentOption = 1
            end
        elseif IsDisabledControlJustReleased(1, keys.up) then
            if menus[currentMenu].currentOption > 1 then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
            else
                menus[currentMenu].currentOption = optionCount
            end
        end
        optionCount = 0
    end
end
