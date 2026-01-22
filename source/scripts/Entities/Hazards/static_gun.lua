local pd <const> = playdate
local gfx <const> = pd.graphics
local vector_new <const> = pd.geometry.vector2D.new
local PerformAfterDelay <const> = pd.frameTimer.performAfterDelay

class('StaticGun').extends(gfx.sprite)

function StaticGun:init(x, y, entity)
	self:moveTo(x + 32, y + 16)
	self:setImage(gfx.image.new("images/GunBody"))
	self.mountImage = gfx.image.new("images/GunMount")

	if entity.fields.Facing == "Right" then
		self:setImageFlip(gfx.kImageFlippedX)
		self.inverted = -1
	else
		self.inverted = 1
	end

	self.range = entity.fields.Range
	self.shootDelay = entity.fields.ShootDelay
	self.bCanShoot = true
	self:setCollideRect(0, 0, 64, 64)
	self:add()
end

function StaticGun:update()
	self.mountImage:draw(self.x - 32, self.y - 16)

	local hitTarget, hitPoint = Raycast(self.x, self.y, -self.range * self.inverted, 0, {self}, {"Bullet"})
	if hitTarget then
		gfx.drawLine(self.x, self.y, hitPoint.x, hitPoint.y)
	else
		gfx.drawLine(self.x, self.y, self.x - self.range * self.inverted, self.y)
	end

	if self.bCanShoot and hitTarget and hitTarget:isa(Player) then
		Bullet(self.x - self.inverted * 20, self.y, vector_new(10 * -self.inverted, 0))
		self.bCanShoot = false
		PerformAfterDelay(self.shootDelay, function ()
			self.bCanShoot = true
		end)
	end
end
