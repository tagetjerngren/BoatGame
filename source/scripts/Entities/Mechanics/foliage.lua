local pd <const> = playdate
local gfx <const> = pd.graphics

class('Foliage').extends(gfx.sprite)

function Foliage:init(x, y, GameManager)
	self:moveTo(x + 16, y + 16)
	-- TODO: Make an image for foliage
	self:setImage(gfx.image.new("images/Vines"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.WALL)
	self.GameManager = GameManager
	self:add()
	self.bIgnited = false
end

function Foliage:ignite()
	if self.bIgnited then
		return
	end
	self.bIgnited = true
	local fireAnim = AnimatedSprite(self.x, self.y, 200, "images/Fire", true)
	-- Ignite neighbors in 15 frames
	pd.frameTimer.performAfterDelay(15, function ()
		local neighbors = gfx.sprite.querySpritesInRect(self.x - 32, self.y - 32, 64, 64)
		for _, neighbor in ipairs(neighbors) do
			if neighbor.ignite then
				neighbor:ignite()
			end
		end
	end)
	-- Delete self in 60 frames
	pd.frameTimer.performAfterDelay(60, function ()
		fireAnim:remove()
		self:remove()
	end)
end
