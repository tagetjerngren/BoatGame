local pd <const> = playdate
local gfx <const> = pd.graphics

class("DpadNotif").extends(gfx.sprite)

function DpadNotif:init(x, y, width, height)
	self:setCollideRect(0, 0, width, height)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x, y)
	local anim = gfx.imagetable.new("images/d-pad-notif")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(300, anim, true)

	self.width = width

	-- self:add()
	GameManagerInstance:add(self)

	self.bCollected = false

	-- TODO: Reconsider this implementation
	self.bPlayerMustBeGrounded = true
end

function DpadNotif:updateObject()
	local spritesInArea = self:overlappingSprites()
	local bPlayerInRect = false
	local player = nil
	for _, value in ipairs(spritesInArea) do
		if value:isa(Player) or value:isa(PlayerBoat) then
			bPlayerInRect = true
			player = value
		end
	end

	if bPlayerInRect then
		if player:isa(Player) and self.bPlayerMustBeGrounded then
			if player.bGrounded then
				UISystem:drawImageAtWorld(self.animationLoop:image(), self.x + self.width / 2 - 16, self.y - 32)
			end
		else
			-- self.animationLoop:draw(self.x + 16, self.y - 16)
			UISystem:drawImageAtWorld(self.animationLoop:image(), self.x + self.width / 2 - 16, self.y - 32)
		end
	end
end
