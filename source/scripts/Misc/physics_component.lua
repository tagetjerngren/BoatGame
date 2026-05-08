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
end

function PhysicsComponent:addForce(Force, ForceY)
	if not ForceY then
		local Force = Force
		self.acceleration += Force
	else
		local force = pd.geometry.vector2D.new(Force, ForceY)
		self.acceleration += force
	end
end

function PhysicsComponent:setPosition(owner, x, y)
	self.x = x
	self.y = y
	self.position = pd.geometry.vector2D.new(x, y)
	owner:moveTo(self.position.x, self.position.y)
end

function PhysicsComponent:setVelocity(x, y)
	self.velocity = pd.geometry.vector2D.new(x, y)
end

function PhysicsComponent:setAcceleration(x, y)
	self.velocity = pd.geometry.vector2D.new(x, y)
end

function PhysicsComponent:move(owner)
	-- Updates all of the info before moving it
	self.velocity += self.acceleration
	self.position += self.velocity
	self.acceleration = pd.geometry.vector2D.new(0, 0)

	-- Limits the velocity of the object
	if self.velocity:magnitude() > self.maxVelocity then
		self.velocity = self.velocity:normalized() * self.maxVelocity
	end

	owner:moveTo(self.position.x, self.position.y)
end
