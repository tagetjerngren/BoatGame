local pd <const> = playdate
local gfx <const> = pd.graphics

class('Companion').extends(gfx.sprite)

function Companion:init(x, y, player)
	self:moveTo(x, y)
	self.player = player
	self:setImage(gfx.image.new("images/Companion"))
	self:add()
	self:setZIndex(10)
	self.searchSize = 250
end

function Companion:update()
	-- NOTE: Uncomment to visualise what the companion sees
	-- gfx.fillRect(self.player.x - self.searchSize / 2, self.player.y - self.searchSize / 2, self.searchSize, self.searchSize)

	local inSearchRadius = gfx.sprite.querySpritesInRect(self.player.x - self.searchSize / 2, self.player.y - self.searchSize / 2, self.searchSize, self.searchSize)
	local door
	for _, sprite in ipairs(inSearchRadius) do
		if sprite:isa(CompanionDoor) then
			door = sprite
		end
	end

	if door then
		local xTar = pd.math.lerp(self.x, door.x, 0.2)
		local yTar = pd.math.lerp(self.y, door.y, 0.2)
		self:moveTo(xTar, yTar)
		if math.abs(self.x - (door.x)) < 0.1 and math.abs(self.y - (door.y)) < 0.1 and not self.bDeletionStarted then
			self.bDeletionStarted = true
			pd.frameTimer.performAfterDelay(15, function ()
				door:clear()
				self.bDeletionStarted = false
			end)
		end
	else
		local xTar = pd.math.lerp(self.x, self.player.x + self.player.direction * -30, 0.2)
		local yTar = pd.math.lerp(self.y, self.player.y - 30, 0.2)
		self:moveTo(xTar, yTar)
	end
end

