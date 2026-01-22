local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('WheelPickup').extends(gfx.sprite)

function WheelPickup:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/Wheel"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function WheelPickup:pickup(player)
	PopupTextBox("*WHEELS*\nLet's you drive around out of the water", 3000, 20)
	PickupSound:play()
	player.bHasWheels = true
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
