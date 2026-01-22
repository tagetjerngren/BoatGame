local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/UIElements/dpad_prompt"

class("Plant").extends(gfx.sprite)

function Plant:init(x, y)
	self:setCollideRect(0, 0, 32, 32)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x + 16, y + 16)
	local anim = gfx.imagetable.new("images/SparkleAnimation")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(100, anim, true)

	self.image = gfx.image.new("images/Plant")
	self:setImage(gfx.image.new("images/Plant"))
	self:add()

	self.notif = DpadNotif(x, y)

	self.bCollected = false
end

function Plant:update()
	if not self.bCollected then
		gfx.lockFocus(self:getImage())
		self.image:draw(0,0)
		self.animationLoop:draw(0, 0)
		gfx.unlockFocus()
		-- self.animationLoop:draw(self.x - 16, self.y - 16)
	end
end

function Plant:interact(player)
	if not self.bCollected then
		player.sampleCollection[1] = {name = "Plant", description = "Grows in places", iconPath = "images/Plant", worldImagePath = "images/Plant"}
		self.bCollected = true
		PopupTextBox("*SAMPLE COLLECTED*", 2000, 10)
		self:setImage(self.image)
		self.notif:remove()
	end
end
