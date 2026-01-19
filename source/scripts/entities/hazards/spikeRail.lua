local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/entities/hazards/spikeRailPoint"

class('SpikeRail').extends(gfx.sprite)

function SpikeRail:init(x, y, entity)
	self.spikeBallDirection = 1
	self.spikeBallSpeed = entity.fields.SpikeBallSpeed
	self.target = 2

	self.bLoop = entity.fields.Loop

	self.path = {}
	table.insert(self.path, SpikeRailPoint(x, y))
	for i = 1, #entity.fields.Path do
		table.insert(self.path, SpikeRailPoint(entity.fields.Path[i].cx * 16, entity.fields.Path[i].cy * 16))
	end
	self:add()

	local InitialProgress = entity.fields.InitialProgress

	-- NOTE: If initial progress is zero then place the ball at the first point, otherwise calculate where it should be
	if InitialProgress == 0 then
		self.spikeBall = SpikeBall(self.path[1].x, self.path[1].y)
	else
		local Points = {}

		local Sum = 0
		table.insert(Points, 0)
		for i = 2, #self.path do
			local ToNextPoint = pd.geometry.vector2D.new(self.path[i].x - self.path[i - 1].x, self.path[i].y - self.path[i - 1].y)
			Sum += ToNextPoint:magnitude()
			table.insert(Points, Sum)
		end

		local EndPoint = InitialProgress * Sum

		for i = 1, #self.path do
			if EndPoint <= Points[i] then
				local Remainder = EndPoint - Points[i-1]
				local ToTarget = pd.geometry.vector2D.new(self.path[i].x - self.path[i - 1].x, self.path[i].y - self.path[i - 1].y)
				local StartPoint = ToTarget:normalized() * Remainder + pd.geometry.vector2D.new(self.path[i - 1].x, self.path[i - 1].y)
				self.spikeBall = SpikeBall(StartPoint.x, StartPoint.y)
				self.target = i
				break
			end
		end
	end
end

function SpikeRail:update()
	-- local toTarget = pd.geometry.vector2D.new(self.path[self.target].x - self.path[self.target - 1].x, self.path[self.target].y - self.path[self.target - 1].y)
	local toTarget = pd.geometry.vector2D.new(self.path[self.target].x - self.spikeBall.x, self.path[self.target].y - self.spikeBall.y)
	if toTarget:magnitude() > self.spikeBallSpeed then
		toTarget = toTarget:normalized() * self.spikeBallSpeed
	elseif toTarget:magnitude() == 0 then
		self.target += self.spikeBallDirection
		if self.bLoop then
			if self.target > #self.path then
				self.target = 1
			end
		else
			if self.target > #self.path then
				self.target -= 1
				self.spikeBallDirection = -1
			elseif self.target == 0 then
				self.target += 1
				self.spikeBallDirection = 1
			end
		end
	end

	if self.bLoop then
		for i = 1, #self.path - 1 do
			gfx.drawLine(self.path[i].x, self.path[i].y, self.path[i + 1].x, self.path[i + 1].y)
		end
		gfx.drawLine(self.path[1].x, self.path[1].y, self.path[#self.path].x, self.path[#self.path].y)
	else
		for i = 1, #self.path - 1 do
			gfx.drawLine(self.path[i].x, self.path[i].y, self.path[i + 1].x, self.path[i + 1].y)
		end
	end

	self.spikeBall:moveTo(self.spikeBall.x + toTarget.x, self.spikeBall.y + toTarget.y)
end
