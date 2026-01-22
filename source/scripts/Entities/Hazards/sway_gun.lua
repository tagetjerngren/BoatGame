local pd <const> = playdate
local gfx <const> = pd.graphics
local vector_new <const> = pd.geometry.vector2D.new
local Cos <const> = math.cos
local Sin <const> = math.sin
local PerformAfterDelay <const> = pd.frameTimer.performAfterDelay

class('SwayGun').extends(gfx.sprite)

function SwayGun:init(x, y, entity)
	self:moveTo(x + 32, y + 16)
	self:setImage(gfx.image.new("images/GunBody"))
	self.mountImage = gfx.image.new("images/GunMount")

	if entity.fields.Facing == "Right" then
		self:setImageFlip(gfx.kImageFlippedX)
		self.inverted = -1
	else
		self.inverted = 1
	end

	self.angle = entity.fields.InitialAngle
	self.angleSpeed = entity.fields.AngleSpeed
	self.maxAngle = entity.fields.MaxAngle
	self.range = entity.fields.Range
	self.shootDelay = entity.fields.ShootDelay
	self.bCanShoot = true
	self:setCollideRect(0, 0, 64, 64)
	self:add()
end

function SwayGun:update()
	self.mountImage:draw(self.x - 32, self.y - 16)

	local radAngle = self.angle * math.pi/180
	local hitTarget, hitPoint = Raycast(self.x, self.y, -self.range * Cos(radAngle) * self.inverted, -self.range * Sin(radAngle) * self.inverted, {self}, {"Bullet"})
	local bSeeingPlayer
	if hitTarget then
		bSeeingPlayer = hitTarget:isa(Player)
		gfx.drawLine(self.x, self.y, hitPoint.x, hitPoint.y)
	else
		gfx.drawLine(self.x, self.y, self.x - self.range * Cos(radAngle) * self.inverted, self.y - self.range * Sin(radAngle) * self.inverted)
	end

	if not bSeeingPlayer then
		self.angle += self.angleSpeed
		if math.abs(self.angle) > math.abs(self.maxAngle) then
			if self.angle < 0 then
				self.angle = -self.maxAngle
			else
				self.angle = self.maxAngle
			end
			self.angleSpeed *= -1
		end
	else
		if self.bCanShoot then
			Bullet(self.x, self.y, vector_new(10 * -Cos(radAngle) * self.inverted, 10 * -Sin(radAngle) * self.inverted))
			self.bCanShoot = false
			PerformAfterDelay(self.shootDelay, function ()
				self.bCanShoot = true
			end)
		end
		local playerCheck, _ = Raycast(self.x, self.y, hitTarget.x - self.x, hitTarget.y - 8 - self.y, {self}, {"Bullet"})
		if playerCheck and playerCheck:isa(Player) then
			local toPlayer = vector_new(hitTarget.x - self.x, hitTarget.y - 8 - self.y)
			local currentDirection = vector_new(self.range*-Cos(radAngle) * self.inverted, self.range*-Sin(radAngle) * self.inverted)
			local angleDiff = toPlayer:angleBetween(currentDirection)
			self.angle -= angleDiff
		end
	end
	self:setRotation(self.angle * self.inverted)
end
