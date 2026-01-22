local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/UIElements/dpad_prompt"

class("Sample").extends(gfx.sprite)

function Sample:init(x, y, entity, collected)
	self:setCollideRect(0, 0, entity.size.width, entity.size.height)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x + entity.size.width/2, y + entity.size.height/2)
	local anim = gfx.imagetable.new("images/SparkleAnimation")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(100, anim, true)

	self.entity = entity
	local IconPath = string.sub(entity.fields.IconPath, 4, #entity.fields.IconPath - 4)
	local WorldImagePath = string.sub(entity.fields.WorldImagePath, 4, #entity.fields.WorldImagePath - 4)
	self.image = gfx.image.new(WorldImagePath)
	self:setImage(gfx.image.new(WorldImagePath))
	self:add()

	self.sparklePoints = {}
	self.width, self.height = self.image:getSize()
	local numberOfTiles = (self.width / 32) * (self.height / 32)
	local tilesToAdd = numberOfTiles / 2
	if self.width > 32 or self.height > 32 then
		-- NOTE: This draws the sparkles all over the image, doesn't look great though
		for x = 0, self.width / 32 do
			for y = 0, self.height / 32 do
				if math.random(2) > 1 then
					table.insert(self.sparklePoints, {x * 32, y * 32})
				end
			end
		end
	else
		self.sparklePoints = {{0, 0}}
	end

	self.name = entity.fields.Name
	self.id = entity.fields.ID
	self.description = entity.fields.Description
	self.iconPath = IconPath
	self.worldImagePath = WorldImagePath

	self.bCollected = self.entity.fields.Collected or collected
	if not self.bCollected then
		self.notif = DpadNotif(x, y, entity.size.width, entity.size.height)
	end
end

function Sample:update()
	if not self.bCollected then
		gfx.lockFocus(self:getImage())
		self.image:draw(0,0)

		for i = 1, #self.sparklePoints do
			self.animationLoop:draw(self.sparklePoints[i][1], self.sparklePoints[i][2])
		end

		gfx.unlockFocus()
	end
end

function Sample:interact(player)
	if not self.bCollected then
		self.entity.fields.Collected = true
		player.sampleCollection[self.id] = {name = self.name, description = self.description, iconPath = self.iconPath, worldImagePath = self.worldImagePath}
		self.bCollected = true
		player.GameManager:collect(self.entity.iid)
		PopupTextBox("*"..self.name.." Collected*", 2000, 10)
		self:setImage(self.image)
		self.notif:remove()
	end
end
