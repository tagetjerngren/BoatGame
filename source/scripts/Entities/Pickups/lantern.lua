local pd <const> = playdate
local gfx <const> = pd.graphics

class('Lantern').extends(gfx.sprite)

function Lantern:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/Lantern"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self.PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

end

function Lantern:collect(player)
	PopupTextBox("*LANTERN*\nHelps make the dark more bearable", 3000, 20)
	self.PickupSound:play()
	player.lightRadius = 200
	player.GameManager:collect(self.entity.iid)
	self:remove()
end
