local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('HeartExpansion').extends(gfx.sprite)

function HeartExpansion:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/HeartIcon"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function HeartExpansion:pickup(player)
	PopupTextBox("*Health Expansion*", 3000, 20)
	PickupSound:play()
	player.MaxHealth += 2
	player.Health += 2
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
