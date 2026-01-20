local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/saves"

class('SavePoint').extends(gfx.sprite)

function SavePoint:init(x, y, level)
	self.level = level
	self:moveTo(x + 16, y + 16)

	-- NOTE: This only exists to keep the save points collision still, check the note in update for more info
	self.originalY = y + 16

	self:setImage(gfx.image.new("images/SaveSpot"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:setZIndex(-1)
	self:add()
	self.bCanSave = true
	self.saveSound = pd.sound.sampleplayer.new("sounds/SaveJingle")

	self.notif = DpadNotif(x, y, 32, 32)
end

function SavePoint:update()
	self:moveTo(self.x, self.y + 0.2 * math.cos(5 * pd.getElapsedTime()))

	-- NOTE: This is kinda a hacky way to make the collision not move around while the save point bounces
	self:setCollideRect(0, self.originalY - self.y, 32, 32)
end

function SavePoint:save(GameManager)
	PopupTextBox("*SAVED*", 2000, 10)
	self.saveSound:play()
	SaveGame(GameManager, self.x, self.y)
end

function SavePoint:interact(player)
	if self.bCanSave then
		player.savePoint = self
		player.Health = 100
		self:save(player.GameManager)
		self.bCanSave = false
		pd.frameTimer.performAfterDelay(30, function()
			self.bCanSave = true
		end)
	end
end
