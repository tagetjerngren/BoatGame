local pd <const> = playdate
local gfx <const> = pd.graphics

class('Darkness').extends(gfx.sprite)

function Darkness:init(player)
	self.player = player
	self:setIgnoresDrawOffset(true)
	self:setCenter(0, 0)

	local ox, oy = gfx.getDrawOffset()
	local allBlack = gfx.image.new(400, 240)
	gfx.pushContext(allBlack)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 400, 240)
		gfx.setColor(gfx.kColorClear)
		gfx.fillCircleAtPoint(self.player.x + ox, self.player.y + oy, self.player.lightRadius)
	gfx.popContext()

	self:setImage(allBlack)

	self:setZIndex(100)
	self:add()
end

function Darkness:update()
	local allBlack = gfx.image.new(400, 240)
	local ox, oy = gfx.getDrawOffset()
	gfx.pushContext(allBlack)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 400, 240)
		gfx.setColor(gfx.kColorClear)
		gfx.fillCircleAtPoint(self.player.x + ox, self.player.y + oy, self.player.lightRadius)
	gfx.popContext()

	self:setImage(allBlack)
end
