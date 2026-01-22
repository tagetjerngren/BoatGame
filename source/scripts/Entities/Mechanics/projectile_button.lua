local pd <const> = playdate
local gfx <const> = pd.graphics

class('ProjectileButton').extends(gfx.sprite)

function ProjectileButton:init(x, y, entity)
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self.entity = entity
	-- self:setGroups(COLLISION_GROUPS.WALL)
	-- self:setCollideRect(6, 6, 20, 20)
	self:setZIndex(-1)
	self:release()
	self:add()
end

function ProjectileButton:press()
	self:setImage(gfx.image.new("images/ShotButtonOn"))
	self.bPressed = true
end

function ProjectileButton:release()
	self:setImage(gfx.image.new("images/ShotButtonOff"))
	self.bPressed = false
end

function ProjectileButton:update()
	local width, height = self:getSize()
	local collisions = gfx.sprite.querySpritesInRect(self.x, self.y, width, height)
	for _, collision in ipairs(collisions) do
		if collision:isa(Bullet) and not self.bPressed then
			self:press()
			collision:remove()
		elseif collision:isa(Bullet) and self.bPressed then
			self:release()
			collision:remove()
		end
	end
end
