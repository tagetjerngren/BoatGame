local pd <const> = playdate
local gfx <const> = pd.graphics

class('Explosion').extends(gfx.sprite)

function Explosion:init(x, y)
	self:setCenter(0, 0)
	self:moveTo(x - 32, y - 32)
	local frameTime = 75
	local animationImageTable = gfx.imagetable.new("images/Explosion")
	self.animationLoop = gfx.animation.loop.new(frameTime, animationImageTable, false)
	self:setImage(gfx.image.new(64, 64))
	local spritesInExplosion = gfx.sprite.querySpritesInRect(self.x, self.y, 64, 64)
	for _, value in ipairs(spritesInExplosion) do
		if value.damage then
			value:damage(1000, 10)
		end
	end
	self:setZIndex(20)
	self:add()
	self.explosionSound = pd.sound.sampleplayer.new("sounds/Explosion")
	self.explosionSound:play()
end

function Explosion:update()
	gfx.lockFocus(self:getImage())
	self.animationLoop:draw(0, 0)
	gfx.unlockFocus()
	if not self.animationLoop:isValid() then
		self:remove()
	end
end
