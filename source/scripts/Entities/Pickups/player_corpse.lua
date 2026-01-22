local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerCorpse').extends(gfx.sprite)

function PlayerCorpse:init(x, y, level, GameManager, coins, direction)
	self:moveTo(x - 16, y - 16)
	self.level = level
	self.GameManager = GameManager
	self.coins = coins
	self.direction = direction
	self:setImage(gfx.image.new("images/BoatCorpse"))
	if self.direction == -1 then
		self:setImageFlip(gfx.kImageFlippedX)
	end
	self:setCollideRect(0, 0, 32, 32)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self.corpseCollectedSound = pd.sound.sampleplayer.new("sounds/CorpseCollected")
end

function PlayerCorpse:update()
	self:moveTo(self.x, self.y + 0.1 * math.cos(5 * pd.getElapsedTime()))
end

function PlayerCorpse:pickup(player)
	self.corpseCollectedSound:play()
	player.coins += self.coins
	self.GameManager.playerCorpse = nil
	self:remove()
end
