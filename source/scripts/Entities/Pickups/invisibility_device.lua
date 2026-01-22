local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('InvisibilityDevice').extends(gfx.sprite)

function InvisibilityDevice:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/InvisibilityDevice"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function InvisibilityDevice:pickup(player)
	PopupTextBox("*INVISIBILITY DEVICE*\nHold B to turn invisible", 3000, 20)
	PickupSound:play()
	player.bHasInvisibilityDevice = true
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
