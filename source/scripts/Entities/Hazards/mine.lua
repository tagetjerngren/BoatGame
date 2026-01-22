import "CoreLibs/sprites"
import "CoreLibs/graphics"

import "scripts/Misc/physics_component"
import "scripts/Misc/buoyancy"
import "scripts/Entities/player"
import "scripts/Entities/Misc/explosion"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Mine').extends(gfx.sprite)

local MineImage = gfx.image.new("images/Mine")

function Mine:init(x, y)
	self:moveTo(x + 16, y + 16)
	self:setImage(MineImage)
	self:setCollideRect(4, 4, 24, 24)
	self.PhysicsComponent = PhysicsComponent(self.x, self.y, 10)

	self:setGroups(COLLISION_GROUPS.EXPLOSIVE)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.PLAYER})
	self:add()

end

function Mine:update()
	self.PhysicsComponent:addForce(0, 0.5)
	self.PhysicsComponent:move(self)
end

function Mine:damage(amount)
	self:Explode()
end

function Mine:Explode()
	self:remove()
	Explosion(self.x, self.y)
end

function Mine:collisionResponse(other)
	if other:isa(Player) or other:isa(Fish) then
		self:Explode()
		return "overlap"
	end
	return "slide"
end
