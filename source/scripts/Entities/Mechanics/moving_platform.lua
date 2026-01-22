local pd <const> = playdate
local gfx <const> = pd.graphics

class('MovingPlatform').extends(gfx.sprite)

function MovingPlatform:init(x, y, entity)
	self:moveTo(x + entity.size.width / 2, y + entity.size.height / 2)

	local sprite = gfx.image.new(entity.size.width, entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	ns:drawInRect(0, 0, entity.size.width, entity.size.height)
	gfx.unlockFocus()
	self:setImage(sprite)

	self:setCollideRect(0, 0, entity.size.width, entity.size.height)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups({COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.PROJECTILE})

	self.startPoint = pd.geometry.vector2D.new(self.x, self.y)
	self.endPoint = pd.geometry.vector2D.new(16 * entity.fields.TargetPoint.cx + 8, 16 * entity.fields.TargetPoint.cy + 8)

	self.target = self.endPoint

	self.speed = entity.fields.Speed
	self.velocity = pd.geometry.vector2D.new(0, 0)

	self:add()
end

function MovingPlatform:update()
	local direction = pd.geometry.vector2D.new(self.target.x - self.x, self.target.y - self.y)
	if direction:magnitude() > self.speed then
		direction:normalize()
		direction *= self.speed
	end
	-- NOTE: This doesn't do anything, but the thinking is if the player is allowed to stand on the platform then when we collide we want to give the player our velocity
	self.velocity = direction
	self:moveBy(direction.x, direction.y)
	-- local spritesOverlapping = self:overlappingSprites()
	-- for _, sprite in spritesOverlapping do
	-- 	if sprite.PhysicsComponent then
	-- 		sprite.PhysicsComponent.velocity += self.velocity
	-- 	end
	-- end
	if (pd.geometry.vector2D.new(self.x, self.y) - self.target):magnitude() == 0 then
		if self.target == self.endPoint then
			self.target = self.startPoint
		else
			self.target = self.endPoint
		end
	end
end
