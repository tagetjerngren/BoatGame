local pd <const> = playdate
local gfx <const> = pd.graphics

class('WaterDrop').extends(gfx.sprite)

local WaterDropImage = gfx.image.new("images/water-drop")

function WaterDrop:init(x, y, water)
	self:moveTo(x + 8, y + 8)
	self:setImage(WaterDropImage)
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 10)
	self.water = water
	self:add()
end

function WaterDrop:update()
	self.PhysicsComponent:addForce(0, 0.5)
	self.PhysicsComponent:move(self)
	if self.water:GetHeight(self.PhysicsComponent.position.x) > self.PhysicsComponent.position.y then
		self.water:Poke(self.PhysicsComponent.position.x, 2)
		self:remove()
	end
end
