local pd <const> = playdate
local gfx <const> = pd.graphics

class('Laser').extends(gfx.sprite)

function Laser:init(x, y, entity)

	self:setImage(gfx.image.new("images/Laser"))

	self.range = entity.fields.Range

	if entity.fields.FacingDirection == "North" then
		self:setRotation(0)
		self:moveTo(x + 8, y)
		-- self.targetX, self.targetY = self.x, self.y - self.range
		self.targetX, self.targetY = 0, -self.range
	elseif entity.fields.FacingDirection == "East" then
		self:setRotation(90)
		self:moveTo(x + 16, y + 8)
		-- self.targetX, self.targetY = self.x + self.range, self.y
		self.targetX, self.targetY = self.range, 0
	elseif entity.fields.FacingDirection == "South" then
		self:setRotation(180)
		self:moveTo(x + 8, y + 16)
		-- self.targetX, self.targetY = self.x, self.y + self.range
		self.targetX, self.targetY = 0, self.range
	elseif entity.fields.FacingDirection == "West" then
		self:setRotation(270)
		self:moveTo(x, y + 8)
		-- self.targetX, self.targetY = self.x - self.range, self.y
		self.targetX, self.targetY = -self.range, 0
	end

	self:add()
end

function Laser:update()
	local hit, point = Raycast(self.x, self.y, self.targetX, self.targetY, {self})
	if point then
		gfx.drawLine(self.x, self.y, point.x, point.y)
		if hit:isa(Player) then
			hit:damage(50, 10)
		end
	else
		gfx.drawLine(self.x, self.y, self.x + self.targetX, self.y + self.targetY)
	end
end
