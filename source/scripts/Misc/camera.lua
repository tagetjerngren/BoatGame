import "scripts/Misc/utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Camera').extends()

function Camera:init(x, y, xMin, yMin, xMax, yMax)
	self.x = x
	self.y = y

	self.xMin = xMin
	self.yMin = yMin

	self.xMax = xMax
	self.yMax = yMax
end

local screenHalfWidth = pd.display.getWidth()/2
local screenHalfHeight = pd.display.getHeight()/2

function Camera:center(x, y)
	local targetX = Clamp(x, self.xMin + screenHalfWidth, self.xMax - screenHalfWidth)
	local targetY = Clamp(y, self.yMin + screenHalfHeight, self.yMax - screenHalfHeight)

	gfx.setDrawOffset(screenHalfWidth - targetX, screenHalfHeight - targetY)

	self.x = targetX
	self.y = targetY
end

function Camera:lerp(x, y, speed)
	local dx = pd.math.lerp(self.x, x, speed)
	local dy = pd.math.lerp(self.y, y, speed)

	self:center(dx, dy)
end
