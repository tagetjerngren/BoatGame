local pd <const> = playdate
local gfx <const> = pd.graphics

class('Detector').extends(gfx.sprite)

function Detector:init(x, y, entity)
	self:setCenter(0, 0)
	self:moveTo(x, y)

	local sprite1 = gfx.image.new(entity.size.width, entity.size.height)
	local sprite2 = gfx.image.new(entity.size.width, entity.size.height)

	local ns1 = gfx.nineSlice.new("images/Detector1", 5, 8, 20, 16)
	local ns2 = gfx.nineSlice.new("images/Detector2", 5, 8, 20, 16)

	-- Frame 1
	gfx.lockFocus(sprite1)
	ns1:drawInRect(0, 0, entity.size.width, entity.size.height)
	gfx.unlockFocus()

	-- Frame 2
	gfx.lockFocus(sprite2)
	ns2:drawInRect(0, 0, entity.size.width, entity.size.height)
	gfx.unlockFocus()

	self.timer = pd.timer.keyRepeatTimerWithDelay(150, 150, function ()
		if self:getImage() == sprite2 then
			self:setImage(sprite1)
		else
			self:setImage(sprite2)
		end
	end)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:setCollideRect(0, 0, entity.size.width, entity.size.height)
	self:setImage(sprite1)
	self:setZIndex(-10)
	self:add()
	self.bDetectedPlayer = false
end

function Detector:update()
	self.bDetectedPlayer = false
	local others = self:overlappingSprites()
	for _, other in ipairs(others) do
		if other:isa(Player) and not other.bInvisible then
			self.bDetectedPlayer = true
		end
	end
end
