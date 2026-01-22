local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"

class('Door').extends(gfx.sprite)

function Door:init(x, y, entity, button)
	self:moveTo(x, y)
	self.button = button
	self:setCenter(0, 0)
	self.entity = entity
	local sprite = gfx.image.new(self.entity.size.width, self.entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/Door", 8, 8, 16, 16)
	ns:drawInRect(0, 0, self.entity.size.width, self.entity.size.height)
	gfx.unlockFocus()
	self:setImage(sprite)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollideRect(0, 0, self.entity.size.width, self.entity.size.height)
	self:add()
end

function Door:update()
	if self.button then
		if self.button.bPressed then
			self:setVisible(false)
			self:clearCollideRect()
		else
			-- NOTE: Kills the player if they bring back the door that they're on, find a more elegant way to do this though
			local hitting = gfx.sprite.querySpritesInRect(self.x, self.y, self.entity.size.width, self.entity.size.height)
			for _, value in ipairs(hitting) do
				if value.damage then
					value:damage(1000, 10)
				end
			end
			self:setVisible(true)
			self:setCollideRect(0, 0, self.entity.size.width, self.entity.size.height)
		end
	end
end
