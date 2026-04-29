import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "scripts/Misc/physics_component"
import "scripts/Scenes/ability_menu"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('PlayerBoat').extends(gfx.sprite)

function PlayerBoat:init(x, y, image, speed, gameManager)
	self.GameManager = gameManager

	self:moveTo(x,y)

	self.PlayerData = gameManager.PlayerData

	-- NOTE: Smaller collision size to cover the boat more snugly
	self:setCollideRect(4, 10, 26, 22)
	self.Speed = speed

	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.PLAYER)
	self:setCollidesWithGroups({COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PICKUPS})

	self.Invincible = 0
	self.explosionMeter = 0

	self.bActive = true

	self.direction = 1

	self.weaponTier = 1
	self.AbilityA = nil
	self.AbilityB = nil
	self.PassiveAbility = nil

	self.hurtSound = pd.sound.sampleplayer.new("sounds/Hurt")

	self.lightRadius = 50

	self.boatImage = gfx.image.new("images/PlayerBoat")
	self.boatHoldingImage = gfx.image.new("images/PlayerBoat-Holding")
	self.wheelBoatImage = gfx.image.new("images/WheelBoat")
	self.currentImage = self.boatImage
	self:setImage(self.boatImage)

	self.sampleCollection = {}
	for i = 1, 21 do
		table.insert(self.sampleCollection, {name = "???", description = "Undiscovered", iconPath = "images/QuestionMark", worldImagePath = "images/QuestionMark"})
	end
end

function PlayerBoat:damage(amount, iFrames)
	if self.Invincible > 0 then
		return
	end

	self.hurtSound:play()

	self:getImage():setInverted(true)
	pd.timer.performAfterDelay(75, function ()
		self:getImage():setInverted(false)
	end)
	self.PlayerData:DamageBoat(amount)
	self.Invincible = iFrames
	if self.PlayerData.BoatHealth == 0 then
		Explosion(self.x, self.y)
		self:setVisible(false)
		self.bActive = false
		self:remove()
		pd.timer.performAfterDelay(1000, function ()
			self:Respawn()
		end)
	end
end

function PlayerBoat:knockback(force)
	self.PhysicsComponent:addForce(force)
	-- self.PhysicsComponent:setVelocity(force.x, force.y)
end

function PlayerBoat:Respawn()
	self:add()
	self.PlayerData.BoatHealth = self.PlayerData.BoatMaxHealth

	self.GameManager.playerCorpse = PlayerCorpse(self.x, self.y, self.GameManager.currentLevel, self.GameManager, self.PlayerData.coins, self.direction)
	self.PlayerData.coins = 0

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

function PlayerBoat:addForce(Force)
	self.PhysicsComponent:addForce(Force)
end

function PlayerBoat:collisionResponse(other)
	if EntityIsCollisionGroup(other, COLLISION_GROUPS.WALL) then
		if other:isa(BlockedWall) and other:clear(self) then
			return "overlap"
		end
		return "slide"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.PICKUPS) then
		if other.collect then
			other:collect(self)
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

function PlayerBoat:update()
	local Gravity = 0.5
	if self.PhysicsComponent.bBuoyant or not self.bUnderwater then
		self.PhysicsComponent:addForce(0, Gravity)
	end

	-- NOTE: This whole chunk just determines which sprite the player should be, it kind of disgusts me but I can't really think of anything better. Maybe implement a state machine and let that sort out sprite changing?

	-- if self.bHasWheels and self.bGrounded then
	-- 	if self.currentImage ~= self.wheelBoatImage then
	-- 		self:setImage(self.wheelBoatImage)
	-- 		self.currentImage = self.wheelBoatImage
	-- 		if self.direction == -1 then
	-- 			self:setImageFlip(gfx.kImageFlippedX)
	-- 		end
	-- 	end
	-- else
	-- 	if self.currentImage ~= self.boatImage then
	-- 		self:setImage(self.boatImage)
	-- 		self.currentImage = self.boatImage
	-- 		if self.direction == -1 then
	-- 			self:setImageFlip(gfx.kImageFlippedX)
	-- 		end
	-- 	end
	-- end

	if self.PlayerData.bHoldingObject then
		self:setImage(self.boatHoldingImage)
	else
		self:setImage(self.boatImage)
	end
	if self.direction == -1 then
		self:setImageFlip(gfx.kImageFlippedX)
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

		if self.PlayerData.activeAbility then
			self.PlayerData.activeAbility.func(self, pd.kButtonA)
		end

		if pd.buttonJustReleased(pd.kButtonB) then
			AbilityMenu(self.GameManager)
		end
	end


	self.PhysicsComponent:addForce(-self.PhysicsComponent.velocity.x * 0.2, 0)

	self.bGrounded = false
	local collisions, _ = self.PhysicsComponent:move(self)

	if self.PlayerData.bHoldingObject then
		self.PlayerData.HeldImage:draw(self.x - 8, self.y - 32 - 8)
	end

	self.bUnderwater = self.y > self.GameManager.water.height
	for i = 1, #collisions do
		if collisions[i].normal.y == 1 and self.y - 22 > self.GameManager.water.height and self.PhysicsComponent.velocity.y == 0 then
			self:damage(1, 15)
		end
		if collisions[i].normal.y == -1 and collisions[i].other:getGroupMask() == 8 then
			self.bGrounded = true
		end
	end

	if self.bActive and pd.buttonIsPressed(pd.kButtonUp) and pd.buttonJustPressed(pd.kButtonB) then
		self.GameManager.player:remove()
		self.GameManager.player = Player(self.x, self.y - 0, self.GameManager)
		self.GameManager.unoccupiedBoat = UnoccupiedBoat(self.x, self.y, self.GameManager, self.GameManager.currentLevel)

		table.insert(self.GameManager.ActivePhysicsComponents, self.GameManager.unoccupiedBoat.PhysicsComponent)
		self.GameManager.player:add()
		self.GameManager.unoccupiedBoat:add()

		-- TODO: This loop and comparing feels pretty bad, make the array a map instead so it's easier to grab specific objects
		for i, v in ipairs(self.GameManager.ActivePhysicsComponents) do
			if v == self.PhysicsComponent then
				table.remove(self.GameManager.ActivePhysicsComponents, i)
				break
			end
		end
		self:remove()
	end

	self.PlayerData:DrawBoatHud()

	if self.Invincible > 0 then
		self.Invincible -= 1
	end
end

function PlayerBoat:setAbilityA(func, name)
	self.AbilityA = func
	self.AbilityAName = name
end

function PlayerBoat:setAbilityB(func, name)
	self.AbilityB = func
	self.AbilityBName = name
end

function PlayerBoat:setPassive(func, name)
	self.PassiveAbility = func
	self.PassiveAbilityName = name
end
