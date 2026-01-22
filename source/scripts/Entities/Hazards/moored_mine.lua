import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/Misc/physics_component"
import "scripts/Misc/buoyancy"
import "scripts/Entities/player"
import "scripts/Entities/Misc/explosion"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('MooredMine').extends(gfx.sprite)

local ChainImage = gfx.image.new("images/Chain")
local MineImage = gfx.image.new("images/Mine")

function MooredMine:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self:setImage(MineImage)
	self:setCollideRect(4, 4, 24, 24)
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 10)

	self:setGroups(COLLISION_GROUPS.EXPLOSIVE)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.PLAYER})
	self.AttachmentPoint = pd.geometry.vector2D.new(entity.fields.AttachmentPoint.cx, entity.fields.AttachmentPoint.cy) * 16
	self.AttachmentPoint.x += 16
	self.ChainLength = self.AttachmentPoint.y - self.y--entity.fields.ChainLength
	self:add()
	self.chainImage = ChainImage

end

function MooredMine:update()
	self.PhysicsComponent:addForce(0, 0.5)
	self.PhysicsComponent:move(self)

	local chainPixelLength = (self.PhysicsComponent.position - self.AttachmentPoint):magnitude()
	local chainChunks = math.ceil(chainPixelLength / 16)
	for i = 0, chainChunks do
		self.chainImage:draw(self.x - 8, self.y + 12 + i * 16)
	end

	if (self.AttachmentPoint - self.PhysicsComponent.position):magnitude() > self.ChainLength then
		self.PhysicsComponent.position.x = self.AttachmentPoint.x
		self.PhysicsComponent.position.y = self.AttachmentPoint.y + -self.ChainLength
		self.x, self.y = self.PhysicsComponent.position.x, self.PhysicsComponent.position.y
		self.PhysicsComponent.velocity.x = 0
		self.PhysicsComponent.velocity.y = 0
	end
end

function MooredMine:damage(amount)
	self:Explode()
end

function MooredMine:Explode()
	self:remove()
	Explosion(self.x, self.y)
end

function MooredMine:collisionResponse(other)
	if other:isa(Player) or other:isa(Fish) then
		self:Explode()
		return "overlap"
	end
	return "slide"
end
