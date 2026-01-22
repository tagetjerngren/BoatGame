local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('Submerge').extends(gfx.sprite)

function Submerge:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/Submerge"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end

function Submerge:pickup(player)
	PopupTextBox("*SUBMERGE*\nCan now dive underwater with the d-pad", 3000, 20)
	PickupSound:play()
	player.bHasSubmerge = true
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
