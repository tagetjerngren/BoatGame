import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "scripts/physicsComponent"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Player').extends(gfx.sprite)

function Player:init(x, y, image, speed, gameManager)
	self.GameManager = gameManager

	self:moveTo(x,y)
	self:setImage(image)

	-- NOTE: Smaller collision size to cover the boat more snugly
	self:setCollideRect(4, 10, 26, 22)
	self.Speed = speed

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

	self.weaponTier = 1
	self.AbilityA = nil
	self.AbilityB = nil
	self.PassiveAbility = nil

	self.hurtSound = pd.sound.sampleplayer.new("sounds/Hurt")

	self.lightRadius = 50

	self.boatImage = gfx.image.new("images/Boat")
	self.wheelBoatImage = gfx.image.new("images/WheelBoat")
	self.currentImage = self.boatImage

	self.sampleCollection = {}
	for i = 1, 21 do
		table.insert(self.sampleCollection, {name = "???", description = "Undiscovered", iconPath = "images/QuestionMark", worldImagePath = "images/QuestionMark"})
	end
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
local HealthImage = nil
local OldCoin = nil
local CoinImage = nil

local HalfHeartImage = gfx.image.new("images/HalfHeartIcon")
local FullHeartImage = gfx.image.new("images/HeartIcon")
local EmptyHeartImage = gfx.image.new("images/EmptyHeartIcon")

function Player:DrawHealthBar()
	HealthImage = gfx.image.new(150, 100)
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
		CoinImage = gfx.image.new(100, 100)
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
	if self.PhysicsComponent.bBuoyant or not self.bUnderwater then
		self.PhysicsComponent:addForce(0, Gravity)
	end

	-- NOTE: This whole chunk just determines which sprite the player should be, it kind of disgusts me but I can't really think of anything better. Maybe implement a state machine and let that sort out sprite changing?
	if self.bHasWheels and self.bGrounded then
		if self.currentImage ~= self.wheelBoatImage then
			self:setImage(self.wheelBoatImage)
			self.currentImage = self.wheelBoatImage
			if self.direction == -1 then
				self:setImageFlip(gfx.kImageFlippedX)
			end
		end
	else
		if self.currentImage ~= self.boatImage then
			self:setImage(self.boatImage)
			self.currentImage = self.boatImage
			if self.direction == -1 then
				self:setImageFlip(gfx.kImageFlippedX)
			end
		end
	end


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

		-- NOTE: I've decided that only the weapon will be an optionable upgrade, otherwise there is just too much world to make, I still sort of like the idea but it would need more work than I'm willing to implement
		-- if self.AbilityB then
		-- 	self:AbilityB(pd.kButtonB)
		-- end

		-- if self.PassiveAbility then
		-- 	self:PassiveAbility()
		-- end

		local TeleportDistance = 64
		-- NOTE: Press the same button within this many frames for it to count as a double tap
		local TeleportDoubleTapFrames = 5

		if self.bCanTeleport then
			if pd.buttonJustPressed(pd.kButtonLeft) and self.bDoubleLeft then
				self:moveBy(-TeleportDistance, 0)
				local Collisions = self:overlappingSprites()
				if #Collisions > 0 then
					self:moveBy(TeleportDistance, 0)
				else
					self.PhysicsComponent.position = pd.geometry.vector2D.new(self.x, self.y)
				end
			elseif pd.buttonJustPressed(pd.kButtonLeft) then
				self.bDoubleLeft = true
				pd.frameTimer.performAfterDelay(TeleportDoubleTapFrames, function ()
					self.bDoubleLeft = false
				end)
			end

			if pd.buttonJustPressed(pd.kButtonRight) and self.bDoubleRight then
				self:moveBy(TeleportDistance, 0)
				local Collisions = self:overlappingSprites()
				if #Collisions > 0 then
					self:moveBy(-TeleportDistance, 0)
				else
					self.PhysicsComponent.position = pd.geometry.vector2D.new(self.x, self.y)
				end
			elseif pd.buttonJustPressed(pd.kButtonRight) then
				self.bDoubleRight = true
				pd.frameTimer.performAfterDelay(TeleportDoubleTapFrames, function ()
					self.bDoubleRight = false
				end)
			end
		end

		if self.bGrounded and not self.bHasWheels then
			if pd.buttonJustPressed(pd.kButtonLeft) then
				self:setImageFlip(gfx.kImageFlippedX)
				self.direction = -1
				self.PhysicsComponent:addForce(-1, 0)
			end

			if pd.buttonJustPressed(pd.kButtonRight) then
				self:setImageFlip(gfx.kImageUnflipped)
				self.direction = 1
				self.PhysicsComponent:addForce(1, 0)
			end
		end

		if pd.buttonIsPressed(pd.kButtonLeft) then
			self:setImageFlip(gfx.kImageFlippedX)
			self.direction = -1
			if ((not self.bGrounded) or self.bHasWheels) then
				self.PhysicsComponent.velocity.x = -self.Speed
			end
		end

		if pd.buttonIsPressed(pd.kButtonRight) then
			self.direction = 1
			self:setImageFlip(gfx.kImageUnflipped)
			if ((not self.bGrounded) or self.bHasWheels) then
				self.PhysicsComponent.velocity.x = self.Speed
			end
		end

		if self.bHasSubmerge then
			DoSubmerge(self)
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
