local pd <const> = playdate
local gfx <const> = pd.graphics
local sampleplayerNew <const> = pd.sound.sampleplayer.new

import "scripts/UIElements/popup_text_box"
import "scripts/UIElements/text_box"
import "scripts/UIElements/option_box_horizontal"

class('Coin').extends(gfx.sprite)

local CoinImage = gfx.image.new("images/Coin")
local CoinPickupSound = sampleplayerNew("sounds/CoinPickup")

function Coin:init(x, y, entity)
	self.entity = entity
	self:moveTo(x + 8, y + 8)
	self:setImage(CoinImage)
	self:setCollideRect(0, 0, 16, 16)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self.coinPickupSound = CoinPickupSound
end

function Coin:update()
	self:moveTo(self.x, self.y + 0.1 * math.cos(5 * pd.getElapsedTime()))
end

function Coin:pickup(player)
	player.coins += 1
	player.GameManager:collect(self.entity.iid)
	self.entity.fields.Collected = true
	self.coinPickupSound:play()
	self:remove()
end
