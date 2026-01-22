local pd <const> = playdate
local gfx <const> = pd.graphics

class('CompanionDoor').extends(gfx.sprite)

function CompanionDoor:init(x, y, entity)
	self.entity = entity
	local sprite = gfx.image.new(self.entity.size.width, self.entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	ns:drawInRect(0, 0, self.entity.size.width, self.entity.size.height)
	local companionOutlineImage = gfx.image.new("images/CompanionOutline")
	local cWidth, cHeight = companionOutlineImage:getSize()
	self.imX, self.imY = self.entity.size.width / 2 - cWidth / 2, self.entity.size.height / 2 - cHeight / 2
	companionOutlineImage:draw(self.imX, self.imY)
	gfx.unlockFocus()
	self:moveTo(x + self.entity.size.width / 2, y + self.entity.size.height / 2)
	self:setImage(sprite)
	self:setCollideRect(0, 0, self.entity.size.width, self.entity.size.height)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end


function CompanionDoor:clear(player)
	self:remove()
end
