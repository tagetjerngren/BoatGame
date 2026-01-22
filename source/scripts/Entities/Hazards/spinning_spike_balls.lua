local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/Entities/Hazards/spike_ball"

class('SpinningSpikeBalls').extends(gfx.sprite)

function SpinningSpikeBalls:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self:setImage(gfx.image.new("images/SpinningSpikeBallRoot"))
	assert(self:getImage())
	self.spikes = {}
	for i = 1, entity.fields.NumberOfSpikes do
		table.insert(self.spikes, SpikeBall(self.x, self.y + 32 * i))
	end
	self.angle = entity.fields.InitialAngle
	self.speed = entity.fields.Speed
	if entity.fields.Direction == "Counter_Clockwise" then
		self.speed *= -1
	end
	self:add()
end

function SpinningSpikeBalls:update()
	for index, spike in ipairs(self.spikes) do
		spike:moveTo(self.x + 26 * index * math.cos(self.angle), self.y + 26 * index * math.sin(self.angle))
	end
	self.angle += self.speed
end
