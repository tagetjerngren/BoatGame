local pd <const> = playdate
local gfx <const> = pd.graphics

class('Button').extends(gfx.sprite)

function Button:init(x, y, entity)
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self.entity = entity
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollideRect(0, 6, 32, 10)
	self:setZIndex(-1)
	self:release()
	self:add()
end

function Button:press()
	self:setImage(gfx.image.new("images/ButtonPressed"))
	self.bPressed = true
end

function Button:release()
	self:setImage(gfx.image.new("images/ButtonUnpressed"))
	self.bPressed = false
end

function Button:update()
	local width, _ = self:getSize()
	local collisions = gfx.sprite.querySpritesInRect(self.x, self.y + 2, width, 6 - 2)
	if #collisions > 0 and not self.bPressed then
		self:press()
	elseif #collisions == 0 and self.bPressed then
		self:release()
	end
end
