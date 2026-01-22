local pd <const> = playdate
local gfx <const> = pd.graphics

class('SpikeBall').extends(gfx.sprite)

function SpikeBall:init(x, y)
	self:setImage(gfx.image.new("images/SpikeBall"))
	assert(self:getImage())
	self:setCollideRect(8, 8, 16, 16)
	self:moveTo(x, y)
	self:setZIndex(5)
	self:add()
end

function SpikeBall:update()
	local collisions = gfx.sprite.querySpritesInRect(self.x - 8, self.y - 8, 16, 16)
	for _, collision in ipairs(collisions) do
		if collision:isa(Player) then
			collision:damage(1, 10)
			collision:knockback(pd.geometry.vector2D.new(collision.x - self.x, collision.y - self.y):normalized() * 10)
			-- collision.PhysicsComponent:AddForce(collision.x - self.x, collision.y - self.y)
		end
	end
	-- gfx.fillRect(self.x - 16, self.y - 16, 32, 32)
end
