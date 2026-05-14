local pd <const> = playdate
local gfx <const> = pd.graphics

class('PhysicsComponent').extends()

function PhysicsComponent:init(x, y, mass, maxVelocity)
	self.position = pd.geometry.vector2D.new(x, y)
	self.velocity = pd.geometry.vector2D.new(0, 0)
	self.acceleration = pd.geometry.vector2D.new(0, 0)
	self.mass = mass
	self.maxVelocity = maxVelocity
	self.bBuoyant = true
	self.bGrounded = false
	self.StoodOnObject = nil -- Represents the object the physicscomponent is grounded on
end

function PhysicsComponent:addForce(Force, ForceY)
	if not ForceY then
		local Force = Force
		self.acceleration += Force
	else
		-- local force = pd.geometry.vector2D.new(Force, ForceY)
		-- self.acceleration += force
		-- local force = pd.geometry.vector2D.new(Force, ForceY)
		self.acceleration.x += Force
		self.acceleration.y += ForceY
	end
end

function PhysicsComponent:setPosition(owner, x, y)
	self.x = x
	self.y = y
	-- self.position = pd.geometry.vector2D.new(x, y)
	self.position.x = x
	self.position.y = y
	owner:moveTo(self.position.x, self.position.y)
end

function PhysicsComponent:setVelocity(x, y)
	-- self.velocity = pd.geometry.vector2D.new(x, y)
	self.velocity.x = x
	self.velocity.y = y
end

function PhysicsComponent:setAcceleration(x, y)
	-- self.velocity = pd.geometry.vector2D.new(x, y)
	self.acceleration.x = x
	self.acceleration.y = y
end

function PhysicsComponent:move(owner)
	-- Updates all of the info before moving it
	self.velocity += self.acceleration
	self.position += self.velocity
	self.acceleration.x = 0
	self.acceleration.y = 0

	-- NOTE: This adjusts the position based on the objects the owner is standing on
	if self.bGrounded and self.StoodOnObject and self.StoodOnObject.PhysicsComponent then
		self.position += self.StoodOnObject.PhysicsComponent.velocity

		local parentStoodOn = self.StoodOnObject
		while parentStoodOn do
			if parentStoodOn.PhysicsComponent.bGrounded and parentStoodOn.PhysicsComponent.StoodOnObject and parentStoodOn.PhysicsComponent.StoodOnObject.PhysicsComponent then
				self.position += parentStoodOn.PhysicsComponent.StoodOnObject.PhysicsComponent.velocity
			end
			parentStoodOn = parentStoodOn.PhysicsComponent.StoodOnObject
		end
	end

	-- Limits the velocity of the object
	if self.velocity:magnitude() > self.maxVelocity then
		self.velocity = self.velocity:normalized() * self.maxVelocity
	end

	owner:moveTo(self.position.x, self.position.y)
end
