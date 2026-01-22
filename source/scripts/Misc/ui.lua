local pd <const> = playdate
local gfx <const> = pd.graphics

class('UI').extends(gfx.sprite)

function UI:init()
	self:setImage(gfx.image.new(400, 240))
	self:setIgnoresDrawOffset(true)
	self:setCenter(0, 0)
	self:setZIndex(1000)
	self:add()
end

function UI:drawImageAt(image, x, y)
	gfx.lockFocus(self:getImage())
	image:draw(x, y)
	gfx.unlockFocus()
end


function UI:drawAt(func, x, y)
	gfx.lockFocus(self:getImage())
	func()
	gfx.unlockFocus()
end

function UI:clear()
	self:getImage():clear(gfx.kColorClear)
end


function UI:drawImageAtWorld(image, x, y)
	local ox, oy = gfx.getDrawOffset()
	gfx.lockFocus(self:getImage())
	image:draw(ox + x, oy + y)
	gfx.unlockFocus()
end
