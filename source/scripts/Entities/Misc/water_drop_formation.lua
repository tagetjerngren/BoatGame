local pd <const> = playdate
local gfx <const> = pd.graphics

import "water_drop"

class('WaterDropFormation').extends(gfx.sprite)

function WaterDropFormation:init(x, y, water)
	self:moveTo(x + 8, y + 8)
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 10)
	self.water = water

	local anim = gfx.imagetable.new("images/water-drop-formation")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(300, anim, true)

	self:add()
end

function WaterDropFormation:update()
	self.PhysicsComponent:addForce(0, 0.5)
	self.PhysicsComponent:move(self)
	if self.water:GetHeight(self.PhysicsComponent.position.x) > self.PhysicsComponent.position.y then
		self.water:Poke(self.PhysicsComponent.position.x, 2)
		self:remove()
	end

	self:setImage(self.animationLoop)

	if not self.animationLoop:isValid() then

	end
end
