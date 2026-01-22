local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"

class('SightDoor').extends(gfx.sprite)

function SightDoor:init(x, y, entity, detector)
	self.detector = detector
	self.entity = entity
	self:moveTo(x + self.entity.size.width/2, y + self.entity.size.height/2)
	local sprite = gfx.image.new(self.entity.size.width, self.entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/SightDoor", 3, 3, 10, 10)
	ns:drawInRect(0, 0, self.entity.size.width, self.entity.size.height)
	gfx.unlockFocus()
	self:setImage(sprite)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setVisible(false)
	self:clearCollideRect()
	self:add()
end

function SightDoor:update()
	if self.detector then
		if not self.detector.bDetectedPlayer then
			self:setVisible(false)
			self:clearCollideRect()
			local hitting = gfx.sprite.querySpritesInRect(self.x - self.entity.size.width/2, self.y - self.entity.size.height/2, self.entity.size.width, self.entity.size.height)
			for _, value in ipairs(hitting) do
				if value.PhysicsComponent then
					local horizontalVelocitySign = value.PhysicsComponent.velocity.x/math.abs(value.PhysicsComponent.velocity.x)
					value.PhysicsComponent:setPosition(self.x + 16 * horizontalVelocitySign + self.entity.size.width/2 * horizontalVelocitySign, value.y)
				end
			end
		else
			-- NOTE: Kills the player if they bring back the door that they're on, find a more elegant way to do this though
			self:setVisible(true)
			self:setCollideRect(0, 0, self.entity.size.width, self.entity.size.height)
		end
	end
end
