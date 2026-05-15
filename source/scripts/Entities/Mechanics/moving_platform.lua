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
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.PROJECTILE})

	-- TODO: Make it so the physics component takes inverted mass instead, then set this to be ZERO
	local mass = 100000000
	local maxVelocity = 10
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, mass, maxVelocity)

	self.startPoint = pd.geometry.vector2D.new(self.x, self.y)
	self.endPoint = pd.geometry.vector2D.new(16 * entity.fields.TargetPoint.cx + 8, 16 * entity.fields.TargetPoint.cy + 8)

	self.target = self.endPoint

	self.speed = entity.fields.Speed

	GameManagerInstance:add(self)
	GameManagerInstance:addPhysicsObject(self)

	self.direction = pd.geometry.vector2D.new(0, 0)
end

function MovingPlatform:collisionResponse(other)
	return "slide"
end


function MovingPlatform:updateObject()
	self.direction.x = self.target.x - self.x
	self.direction.y = self.target.y - self.y
	if self.direction:magnitude() > self.speed then
		self.direction:normalize()
		self.direction *= self.speed
	end
	-- print((self.PhysicsComponent.position - self.target):magnitude())
	if (self.PhysicsComponent.position - self.target):magnitude() == 0 then
		if self.target == self.endPoint then
			self.target = self.startPoint
		else
			self.target = self.endPoint
		end
	end

	self.PhysicsComponent.velocity = self.direction
end
