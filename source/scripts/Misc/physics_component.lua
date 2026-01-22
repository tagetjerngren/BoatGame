local pd <const> = playdate
local gfx <const> = pd.graphics

class('PhysicsComponent').extends()

function PhysicsComponent:init(x, y, maxVelocity)
	self.position = pd.geometry.vector2D.new(x, y)
	self.velocity = pd.geometry.vector2D.new(0, 0)
	self.acceleration = pd.geometry.vector2D.new(0, 0)
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

function PhysicsComponent:setPosition(x, y)
	self.x = x
	self.y = y
	self.position = pd.geometry.vector2D.new(x, y)
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

	-- Actual moving
	local collisions, length
	self.position.x, self.position.y, collisions, length = owner:moveWithCollisions(self.position.x, self.position.y)

	-- If we hit a surface set our velocity in that direction to zero 
	-- NOTE: Kinda hacky, this only works so long as there are no slanted normals, feel free to be more cleverer
	for i = 1, length, 1 do
		if collisions[i].other:isa(MovingPlatform) then
			print(collisions[i].other.velocity)
			self.velocity += collisions[i].other.velocity * 0.25
		end

		-- NOTE: So that it allows the player to go through overlap collisions
		if collisions[i].type ~= 2 then
			self.velocity.x *= math.abs(collisions[i].normal.y)
			self.velocity.y *= math.abs(collisions[i].normal.x)
		end
	end

	return collisions, length
end
