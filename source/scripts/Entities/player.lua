PLAYER_STATES = {
	IN_AIR = 1,
	STANDING = 2,
	WALKING = 3
}

import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "scripts/Misc/physics_component"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, gameManager)
	self.GameManager = gameManager

	self:moveTo(x,y)

	-- NOTE: Smaller collision size to cover the boat more snugly
	self:setCollideRect(4, 10, 26, 22)
	self.Speed = 1

	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.PLAYER)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PICKUPS})

	self.MaxHealth = 6
	self.Health = self.MaxHealth
	self.Invincible = 0
	self.coins = 0
	self.explosionMeter = 0

	self.bActive = true

	self.direction = 1

	self.hurtSound = pd.sound.sampleplayer.new("sounds/Hurt")
	self.PhysicsComponent.bBuoyant = false

	local frameTime = 150
	local animationImageTable = gfx.imagetable.new("images/PlayerWalk")
	self.animationLoop = gfx.animation.loop.new(frameTime, animationImageTable, true)

	self.playerImage = gfx.image.new("images/Player")
	self.playerJumpImage = gfx.image.new("images/PlayerJump")
	self.playerWalkingImage = gfx.image.new(32, 32)
	self.currentImage = self.playerImage
	self:setImage(self.currentImage)
end

function Player:damage(amount, iFrames)
	if self.Invincible > 0 then
		return
	end

	self.hurtSound:play()

	self:getImage():setInverted(true)
	pd.timer.performAfterDelay(75, function ()
		self:getImage():setInverted(false)
	end)
	self.Health -= amount
	self.Invincible = iFrames
	if self.Health <= 0 then
		self.Health = 0
		Explosion(self.x, self.y)
		self:setVisible(false)
		self.bActive = false
		self:remove()
		pd.timer.performAfterDelay(1000, function ()
			self:Respawn()
		end)
	end
end

function Player:knockback(force)
	self.PhysicsComponent:addForce(force)
	-- self.PhysicsComponent:setVelocity(force.x, force.y)
end

function Player:Respawn()
	self:add()
	self.Health = self.MaxHealth

	self.GameManager.playerCorpse = PlayerCorpse(self.x, self.y, self.GameManager.currentLevel, self.GameManager, self.coins, self.direction)
	self.coins = 0

	if self.savePoint then
		self.GameManager:goToLevel(self.savePoint.level)
		self:moveTo(self.savePoint.x, self.savePoint.y + 8)
	else
		self.GameManager:goToLevel("Starting_Area")
		self:moveTo(self.GameManager.SpawnX, self.GameManager.SpawnY)
	end

	self.PhysicsComponent.position = pd.geometry.vector2D.new(self.x, self.y)
	self.PhysicsComponent.velocity = pd.geometry.vector2D.new(0, 0)
	self.PhysicsComponent.acceleration = pd.geometry.vector2D.new(0, 0)

	-- self.GameManager.water.height = self.y
	self.GameManager.water:SetHeight(self.y)

	self.GameManager.camera:center(self.x, self.y)

	self:setVisible(true)
	self.bActive = true

end

local OldHealth = nil
local HealthImage = gfx.image.new(250, 100)
local OldCoin = nil
local CoinImage = gfx.image.new(100, 100)

local HalfHeartImage = gfx.image.new("images/HalfHeartIcon")
local FullHeartImage = gfx.image.new("images/HeartIcon")
local EmptyHeartImage = gfx.image.new("images/EmptyHeartIcon")

function Player:DrawHealthBar()
	HealthImage:clear(gfx.kColorClear)
	gfx.lockFocus(HealthImage)

	local FullHearts = math.floor(self.Health / 2)
	local HaveHalfHeart = (self.Health % 2) == 1
	local EmptyHearts = math.floor((self.MaxHealth - self.Health) / 2)

	for i = 1, FullHearts do
		FullHeartImage:draw(16 + (i - 1) * 32, 16)
	end

	if HaveHalfHeart then
		HalfHeartImage:draw(16 + (FullHearts) * 32, 16)
	end

	for i = math.ceil(self.Health / 2) + 1, self.MaxHealth / 2 do
		EmptyHeartImage:draw(16 + (i - 1) * 32, 16)
	end

	gfx.unlockFocus()

	UISystem:drawImageAt(HealthImage, 0, 0)

	if (OldCoin ~= self.coins) then
		CoinImage:clear(gfx.kColorClear)
		gfx.lockFocus(CoinImage)
		local nsCoins = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)
		local width, _ = gfx.getTextSize(math.floor(self.coins).."x")
		nsCoins:drawInRect(10, 50, width + 45, 28)
		gfx.drawText(math.floor(self.coins).." x", 20, 55)
		gfx.image.new("images/Coin"):draw(30 + width, 56)
		gfx.unlockFocus()
	end

	OldCoin = self.coins
	OldHealth = self.Health

	UISystem:drawImageAt(CoinImage, 300, -40)
end

function Player:addForce(Force)
	self.PhysicsComponent:addForce(Force)
end

function Player:collisionResponse(other)
	if EntityIsCollisionGroup(other, COLLISION_GROUPS.WALL) then
		if other:isa(BlockedWall) and other:clear(self) then
			return "overlap"
		end
		return "slide"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.PICKUPS) then
		if other.pickup then
			other:pickup(self)
		end
		return "overlap"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.ENEMY) then
		return "overlap"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.TRIGGER) then
		if other:isa(DoorTrigger) then
			self.Door = other
		end
		return "overlap"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.PROJECTILE) then
		return "overlap"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.EXPLOSIVE) then
		return "overlap"
	end

	assert(false, "Couldn't figure out how we wanted to respond to the collision")
end

function Player:update()
	local Gravity = 0.5
	self.PhysicsComponent:addForce(0, Gravity)

	if self.bHasInterest then
		DoInterest(self)
	end

	if self.bHasInvisibilityDevice then
		Invisibility(self, pd.kButtonB)
	end

	if self.bHasChangeSizeDevice then
		ChangeSize(self, pd.kButtonA)
	end

	if self.bActive then
		if pd.buttonJustPressed(pd.kButtonUp) then
			local CollidingWithSprites = self:overlappingSprites()
			for _, sprite in ipairs(CollidingWithSprites) do
				if sprite.interact then
					sprite:interact(self)
				end
			end
		end

		if self.AbilityA then
			self:AbilityA(pd.kButtonA)
		end

		if pd.buttonJustPressed(pd.kButtonA) and self.bGrounded then
				self.PhysicsComponent.velocity.y = -8
		end

		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:setImageFlip(gfx.kImageFlippedX)
			self.direction = -1
			-- if (self.bGrounded) then
				-- self.PhysicsComponent.velocity.x = -self.Speed
				self.PhysicsComponent:addForce(-self.Speed, 0)
			-- end
		end

		if pd.buttonIsPressed(pd.kButtonRight) then
			self.direction = 1
			self:setImageFlip(gfx.kImageUnflipped)
			-- if (self.bGrounded) then
				-- self.PhysicsComponent.velocity.x = self.Speed
				self.PhysicsComponent:addForce(self.Speed, 0)
			-- end
		end
	end

	self.PhysicsComponent:addForce(-self.PhysicsComponent.velocity.x * 0.2, 0)

	self.bGrounded = false
	local collisions, _ = self.PhysicsComponent:move(self)
	self.bUnderwater = self.y > self.GameManager.water.height
	for i = 1, #collisions do
		if collisions[i].normal.y == 1 and self.y - 22 > self.GameManager.water.height and self.PhysicsComponent.velocity.y == 0 then
			self:damage(1, 15)
		end
		if collisions[i].normal.y == -1 and collisions[i].other:getGroupMask() == 8 then
			self.bGrounded = true
		end
	end

	local bCollidingWithDoorTrigger = false

	local CollidingWithSprites = self:overlappingSprites()
	for _, sprite in ipairs(CollidingWithSprites) do
		if sprite:isa(DoorTrigger) or sprite:isa(InteractDoorTrigger) then
			bCollidingWithDoorTrigger = true
			break
		end
	end

	-- NOTE: KEEPS THE PLAYER WITHIN THE LEVEL UNLESS THEY ARE COLLIDING WITH A DOOR
	if not bCollidingWithDoorTrigger then
		local PlayerCollideRect = self:getCollideRect()
		local HalfWidth = PlayerCollideRect.width / 2

		local PlayerLeft = self.x - HalfWidth
		local PlayerRight = self.x + HalfWidth

		if PlayerRight > self.GameManager.LevelWidth then
			self:moveTo(self.GameManager.LevelWidth - HalfWidth, self.y)
			self.PhysicsComponent.position.x = self.GameManager.LevelWidth - HalfWidth
		end

		if PlayerLeft < 0 then
			self:moveTo(HalfWidth, self.y)
			self.PhysicsComponent.position.x = HalfWidth
		end
	end

	-- NOTE: Figuring out player state
	if not self.bGrounded then
		self.state = PLAYER_STATES.IN_AIR
	else
		if abs(self.PhysicsComponent.velocity.x) < 0.1 then
			self.state = PLAYER_STATES.STANDING
		else
			self.state = PLAYER_STATES.WALKING
		end
	end

	print(self.state)

	-- NOTE: SETTING THE PLAYER IMAGE
	if self.state == PLAYER_STATES.IN_AIR then
		self:setImage(self.playerJumpImage)
		if self.direction == -1 then
			self:setImageFlip(gfx.kImageFlippedX)
		end
	elseif self.state == PLAYER_STATES.STANDING then
		self:setImage(self.playerImage)
		if self.direction == -1 then
			self:setImageFlip(gfx.kImageFlippedX)
		end
	elseif self.state == PLAYER_STATES.WALKING then
		self.playerWalkingImage:clear(gfx.kColorClear)
		self:setImage(self.playerWalkingImage)
		gfx.lockFocus(self:getImage())
		self.animationLoop:draw(0, 0)
		gfx.unlockFocus()
		if self.direction == -1 then
			self:setImageFlip(gfx.kImageFlippedX)
		end
	end

	self:DrawHealthBar()

	if self.Invincible > 0 then
		self.Invincible -= 1
	end
end

function Player:setAbilityA(func, name)
	self.AbilityA = func
	self.AbilityAName = name
end

function Player:setAbilityB(func, name)
	self.AbilityB = func
	self.AbilityBName = name
end

function Player:setPassive(func, name)
	self.PassiveAbility = func
	self.PassiveAbilityName = name
end
