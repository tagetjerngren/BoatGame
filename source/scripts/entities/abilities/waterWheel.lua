local pd <const> = playdate
local gfx <const> = pd.graphics

local PickupSound = pd.sound.sampleplayer.new("sounds/ImportantCollectible")

class('WaterWheel').extends(gfx.sprite)

function WaterWheel:init(x, y, entity, water)
	self.bElectrified = not water.bWaterWheelPossessed

	self.water = water
	self.entity = entity
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setImage(gfx.image.new("images/WaterWheel"))
	self:getImage():setInverted(not self.bElectrified)
	self:setCollideRect(0, 0, 64, 64)
	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()

	self.notif = DpadNotif(x, y, 64, 64)
end

function WaterWheel:interact(player)
	if not self.water.bWaterWheelPossessed then
		-- NOTE: On first pick up explain the power
		if self.water.bFirstCollection then
			PopupTextBox("*WATER WHEEL*\nCrank to change the water level", 3000, 20)
			self.water.bFirstCollection = false
		end
		PickupSound:play()
		self.water.bWaterWheelPossessed = true
		self.bElectrified = false
		self:getImage():setInverted(true)
	else
		PickupSound:play()
		self.entity.fields.PickedUp = true
		player.GameManager:collect(self.entity.iid)
		self.water.bWaterWheelPossessed = false
		self.bElectrified = true
		self:getImage():setInverted(false)
	end
end
