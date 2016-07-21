-- ************************************************************************** --
--[[
Dusk Engine Component: Screen Info

Gives correct screen dimensions.
--]]
-- ************************************************************************** --

local screenInfo = {}

screenInfo.left = display.screenOriginX -- Left side of the screenInfo
screenInfo.right = display.contentWidth - screenInfo.left -- Right side of the screenInfo
screenInfo.top = display.screenOriginY -- Top of the screenInfo
screenInfo.centerX = display.contentCenterX
screenInfo.centerY = display.contentCenterY
screenInfo.bottom = display.contentHeight - screenInfo.top -- Bottom of the screenInfo
screenInfo.width = screenInfo.right - screenInfo.left -- Actual width of the screenInfo
screenInfo.height = screenInfo.bottom - screenInfo.top -- Actual height of the screenInfo
screenInfo.zoomX = screenInfo.width / display.contentWidth
screenInfo.zoomY = screenInfo.height / display.contentHeight

return screenInfo