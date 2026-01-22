local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
import "scripts/Entities/player"

class('OneWayDoor').extends(gfx.sprite)

function OneWayDoor:init(x, y, entity)
	self.entity = entity
	self.Blocking = entity.fields.Blocking
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
	self:close()
end

function OneWayDoor:open()
	local sprite = gfx.image.new(self.entity.size.width, self.entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 21, 21)
	-- NOTE: THE DOOR IMAGE
	if self.Blocking == "South" then
		ns:drawInRect(0, 0, self.entity.size.width, 6)
	elseif self.Blocking == "North" then
		ns:drawInRect(0, 4, self.entity.size.width, 6)
	elseif self.Blocking == "West" then
		ns:drawInRect(4, 0, 6, self.entity.size.height)
	elseif self.Blocking == "East" then
		ns:drawInRect(0, 0, 6, self.entity.size.height)
	end
	gfx.unlockFocus()
	self:setImage(sprite)
	self:clearCollideRect()
	self.bOpen = true
end

function OneWayDoor:close()
	local sprite = gfx.image.new(self.entity.size.width, self.entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/OneWayDoorSmall", 3, 3, 25, 25)
	-- NOTE: THE DOOR IMAGE
	if self.Blocking == "South" then
		ns:drawInRect(0, 0, self.entity.size.width, 6)
	elseif self.Blocking == "North" then
		ns:drawInRect(0, 8, self.entity.size.width, 6)
	elseif self.Blocking == "West" then
		ns:drawInRect(8, 0, 6, self.entity.size.height)
	elseif self.Blocking == "East" then
		ns:drawInRect(0, 0, 6, self.entity.size.height)
	end
	gfx.unlockFocus()
	self:setImage(sprite)
	-- NOTE: THE DOOR BLOCKING SHAPE
	if self.Blocking == "South" then
		self:setCollideRect(0, 6, self.entity.size.width, 1)
	elseif self.Blocking == "North" then
		self:setCollideRect(0, 7, self.entity.size.width, 1)
	elseif self.Blocking == "West" then
		self:setCollideRect(7, 0, 1, self.entity.size.height)
	elseif self.Blocking == "East" then
		self:setCollideRect(6, 0, 1, self.entity.size.height)
	end
	self.bOpen = false
end

function OneWayDoor:update()
	local width, height = self:getSize()
	if not self.bOpen then
		local collisionsInOpen
		-- NOTE: THE DOOR OPENING ZONE
		if self.Blocking == "South" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y, width, 6)
		elseif self.Blocking == "North" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y + 8, width, 6)
		elseif self.Blocking == "West" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x + 8, self.y, 6, height)
		elseif self.Blocking == "East" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y, 6, height)
		end
		if #collisionsInOpen > 0 then
			self:open()
		end
	else
		-- NOTE: THE DOOR STAY OPEN ZONE
		local collisionsInOpen
		if self.Blocking == "South" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y, width, 12)
		elseif self.Blocking == "North" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y + height - 8 - 6, width, 12)
		elseif self.Blocking == "West" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x + 8 - 6, self.y, 12, height)
		elseif self.Blocking == "East" then
			collisionsInOpen = gfx.sprite.querySpritesInRect(self.x, self.y, 12, height)
		end
		if #collisionsInOpen == 0 then
			self:close()
		end
	end
end
