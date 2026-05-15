local pd <const> = playdate
local gfx <const> = pd.graphics

class('TeleportationDevice').extends(gfx.sprite)

function TeleportationDevice:init(x, y, entity)
	self:moveTo(x + 16, y + 16)
	self.entity = entity
	self:setImage(gfx.image.new("images/TeleportationDevice"))
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self.id = 2
	self.PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

end

function TeleportationDevice:collect(player)
	PopupTextBox("*TELEPORTATION DEVICE*\nDouble tap left or right to warp", 3000, 20)
	self.PickupSound:play()
	player.GameManager:collect(self.entity.iid)
	-- player.bCanTeleport = true
	player.PlayerData.abilities[self.id] = {
		icon = gfx.image.new("images/TeleportationDevice"),
		func = Teleport
	}
	self:remove()
end
