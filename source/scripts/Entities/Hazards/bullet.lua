import "CoreLibs/sprites"
import "CoreLibs/graphics"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Bullet').extends(gfx.sprite)

function Bullet:init(x, y, direction, damage)
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/Bullet"))
	self:setCollideRect(4, 4, 8, 8)

	self.x = x
	self.y = y
	self.direction = direction
	if damage then
		self.damage = damage
	else
		self.damage = 1
	end

	self:setGroups(COLLISION_GROUPS.PROJECTILE)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.WALL, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.ENEMY})

	self:add()
end

function Bullet:update()
	local x, y, c, n = self:moveWithCollisions(self.x + self.direction.x, self.y + self.direction.y)

	if n >= 1 then
		for i = 1, #c do
			if c[i].other.damage then
				c[i].other:damage(self.damage, 5)
			end
		end
		self:remove()
	end
end
