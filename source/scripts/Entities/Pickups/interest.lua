local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('Interest').extends(gfx.sprite)

function Interest:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/Interest"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function Interest:pickup(player)
	PopupTextBox("*INTEREST*\nAccrue both health and wealth over time", 3000, 20)
	PickupSound:play()
	player.bHasInterest = true
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
