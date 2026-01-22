local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/UIElements/popup_text_box"

class('BigCoin').extends(gfx.sprite)

function BigCoin:init(x, y, entity)
	self.entity = entity
	self:moveTo(x + 8, y + 8)
	self:setImage(gfx.image.new("images/BigCoin"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self.coinPickupSound = pd.sound.sampleplayer.new("sounds/BigCoinPickup")
end

function BigCoin:update()
	self:moveTo(self.x, self.y + 0.2 * math.cos(2 * pd.getElapsedTime()))
end

function BigCoin:pickup(player)
	player.coins += 100
	self.entity.fields.Collected = true
	player.GameManager:collect(self.entity.iid)
	self.coinPickupSound:play()
	self:remove()
end
