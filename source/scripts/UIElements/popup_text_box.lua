local pd <const> = playdate
local gfx <const> = playdate.graphics

class('PopupTextBox').extends(gfx.sprite)

function PopupTextBox:init(message, timeToLive, padding)
	self.width, self.height = gfx.getTextSize(message)
	local sprite = gfx.image.new(self.width + 2 * padding, self.height + 2 * padding)
	self:setZIndex(100)
	self:setIgnoresDrawOffset(true)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	ns:drawInRect(0, 0, self.width + 2*padding, self.height + 2*padding)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned(message, self.width / 2 + padding, padding, kTextAlignment.center)
	gfx.unlockFocus()
	self:moveTo(200, 240 + self.height / 2)
	self:setImage(sprite)
	pd.timer.performAfterDelay(timeToLive, function ()
		self.expired = true
	end)
	self:add()
end

function PopupTextBox:update()
	if self.expired then
		local targetY = pd.math.lerp(self.y, 240 + self.height / 2 + 10, 0.15)
		self:moveTo(self.x, targetY)
		if self.y > 240 + self.height / 2 then
			self:remove()
		end
	else
		local targetY = pd.math.lerp(self.y, 240 - self.height, 0.2)
		self:moveTo(self.x, targetY)
	end

end
