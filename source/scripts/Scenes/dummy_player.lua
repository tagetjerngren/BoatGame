import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "scripts/Misc/physics_component"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('DummyPlayer').extends(gfx.sprite)

function DummyPlayer:init(x, y, image, speed)
	self:moveTo(x,y)
	self:setImage(image)

	-- NOTE: Smaller collision size to cover the boat more snugly
	self:setCollideRect(4, 10, 26, 22)
	self.Speed = speed

	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.PLAYER)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PICKUPS})

	self.direction = 1

	self.boatImage = gfx.image.new("images/Boat")
	self.currentImage = self.boatImage
end

function DummyPlayer:addForce(Force)
	self.PhysicsComponent:addForce(Force)
end

function DummyPlayer:update()
	local Gravity = 0.5
	if self.PhysicsComponent.bBuoyant or not self.bUnderwater then
		self.PhysicsComponent:addForce(0, Gravity)
	end

	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:setImageFlip(gfx.kImageFlippedX)
		self.direction = -1
		if ((not self.bGrounded) or self.bHasWheels) then
			self.PhysicsComponent.velocity.x = -self.Speed
		end
	end

	if pd.buttonIsPressed(pd.kButtonRight) then
		self.direction = 1
		self:setImageFlip(gfx.kImageUnflipped)
		if ((not self.bGrounded) or self.bHasWheels) then
			self.PhysicsComponent.velocity.x = self.Speed
		end
	end

	self.PhysicsComponent:addForce(-self.PhysicsComponent.velocity.x * 0.2, 0)
	self.PhysicsComponent:move(self)
end
