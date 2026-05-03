PLAYER_STATES = {
	IN_AIR = 1,
	STANDING = 2,
	WALKING = 3,
	CROUCHING = 4
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
	-- self:setCollideRect(4, 10, 26, 22)
	self:setCollideRect(8, 4, 32 - 8 * 2, 32 - 4)

	self.PlayerData = gameManager.PlayerData

	self.desiredVelocity = 0

	self.maxAcceleration = 1
	self.maxDeceleration = 0.8
	self.maxTurnSpeed = 1.3

	self.maxAirAcceleration = 0.3
	self.maxAirDeceleration = 0.02
	self.maxAirTurnSpeed = 0.4

	self.MaxSpeed = 4

	self.jumpHeight = 60
	self.timeToJumpApex = 10

	self.gravityScale = 1
	self.gravMultiplier = 1

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

	self.hurtSound = pd.sound.sampleplayer.new("sounds/Hurt")
	self.PhysicsComponent.bBuoyant = false

	local frameTime = 150
	local animationImageTable = gfx.imagetable.new("images/PlayerWalk")
	self.animationLoop = gfx.animation.loop.new(frameTime, animationImageTable, true)

	local holdingAnimationImageTable = gfx.imagetable.new("images/PlayerWalk-Holding")
	self.animationLoopHolding = gfx.animation.loop.new(frameTime, holdingAnimationImageTable, true)

	self.playerImage = gfx.image.new("images/Player")
	self.playerJumpImage = gfx.image.new("images/PlayerJump")
	self.playerCrouchImage = gfx.image.new("images/PlayerCrouch")

	self.playerHoldingImage = gfx.image.new("images/Player-Holding")
	self.playerJumpHoldingImage = gfx.image.new("images/PlayerJump-Holding")
	self.playerCrouchHoldingImage = gfx.image.new("images/PlayerCrouch-Holding")

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
	self.PlayerData:DamagePlayer(amount)
	self.Invincible = iFrames
	if self.PlayerData.PlayerHealth == 0 then
		Explosion(self.x, self.y)
		self:setVisible(false)
		self.bActive = false
		-- self:remove()
		self.GameManager:remove(self)
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
	-- self:add()
	self.GameManager:add(self)
	self.PlayerData.PlayerHealth = self.PlayerData.PlayerMaxHealth

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

	self.GameManager.water:SetHeight(self.y)

	self.GameManager.camera:center(self.x, self.y)

	self:setVisible(true)
	self.bActive = true

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

function Player:calculateGrounded(collisions)
	self.bGrounded = false
	-- local collisions, _ = self.PhysicsComponent:move(self)
	self.bUnderwater = self.y - 32 > self.GameManager.water.height
	for i = 1, #collisions do
		if collisions[i].normal.y == -1 and collisions[i].other:getGroupMask() == 8 then
			self.bGrounded = true
		end
	end
end

function Player:keepPlayerWithinMap()
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
end

function Player:calculateState()
	if not self.bGrounded then
		self.state = PLAYER_STATES.IN_AIR
	else
		if self.desiredVelocity ~= 0 then
			self.state = PLAYER_STATES.WALKING
		elseif self.bCrouching then
			self.state = PLAYER_STATES.CROUCHING
		else
			self.state = PLAYER_STATES.STANDING
		end
	end
end

function Player:setPlayerImage()
	if self.state == PLAYER_STATES.IN_AIR then
		if self.PlayerData.bHoldingObject then
			self:setImage(self.playerJumpHoldingImage)
		else
			self:setImage(self.playerJumpImage)
		end
	elseif self.state == PLAYER_STATES.CROUCHING then
		if self.PlayerData.bHoldingObject then
			self:setImage(self.playerCrouchHoldingImage)
		else
			self:setImage(self.playerCrouchImage)
		end
	elseif self.state == PLAYER_STATES.STANDING then
		if self.PlayerData.bHoldingObject then
			self:setImage(self.playerHoldingImage)
		else
			self:setImage(self.playerImage)
		end
	elseif self.state == PLAYER_STATES.WALKING then
		if self.PlayerData.bHoldingObject then
			self.playerWalkingImage:clear(gfx.kColorClear)
			self:setImage(self.playerWalkingImage)
			gfx.lockFocus(self:getImage())
			self.animationLoopHolding:draw(0, 0)
			gfx.unlockFocus()
		else
			self.playerWalkingImage:clear(gfx.kColorClear)
			self:setImage(self.playerWalkingImage)
			gfx.lockFocus(self:getImage())
			self.animationLoop:draw(0, 0)
			gfx.unlockFocus()
		end
	end

	if self.direction == -1 then
		self:setImageFlip(gfx.kImageFlippedX)
	end
end

function Player:handleWalk()
	local acceleration = self.bGrounded and self.maxAcceleration or self.maxAirAcceleration
	local deceleration = self.bGrounded and self.maxDeceleration or self.maxAirDeceleration
	local turnSpeed = self.bGrounded and self.maxTurnSpeed or self.maxAirTurnSpeed

	self.desiredVelocity = 0

	if pd.buttonJustPressed(pd.kButtonLeft) or pd.buttonJustPressed(pd.kButtonRight) then
		self.animationLoop.frame = 2
		self.animationLoopHolding.frame = 2
	end

	self.bCrouching = false
	if pd.buttonIsPressed(pd.kButtonLeft) then
		self:setImageFlip(gfx.kImageFlippedX)
		self.direction = -1
			self.desiredVelocity = -self.MaxSpeed
	elseif pd.buttonIsPressed(pd.kButtonRight) then
		self.direction = 1
		self:setImageFlip(gfx.kImageUnflipped)
			self.desiredVelocity = self.MaxSpeed
	elseif pd.buttonIsPressed(pd.kButtonDown) then
		self.bCrouching = true
	end

	local maxSpeedChange

	if self.desiredVelocity ~= 0 then
		if self.desiredVelocity/abs(self.desiredVelocity) ~= self.PhysicsComponent.velocity.x/abs(self.PhysicsComponent.velocity.x) then
			maxSpeedChange = turnSpeed
		else
			maxSpeedChange = acceleration
		end
	else
		maxSpeedChange = deceleration
	end

	if abs(self.desiredVelocity - self.PhysicsComponent.velocity.x) ~= 0 then
		-- NOTE: THIS PREVENTS OVERSHOOT
		 maxSpeedChange = abs(self.desiredVelocity - self.PhysicsComponent.velocity.x) < maxSpeedChange and abs(self.desiredVelocity - self.PhysicsComponent.velocity.x) or maxSpeedChange
		self.PhysicsComponent.velocity.x += ((self.desiredVelocity - self.PhysicsComponent.velocity.x) / abs(self.desiredVelocity - self.PhysicsComponent.velocity.x)) * maxSpeedChange
	end
end

function Player:jump(gravity)
	self.bDesireJump = false

	if self.bGrounded then
		local jumpSpeed = math.sqrt(2 * gravity * self.gravityScale * self.jumpHeight)

		if self.PhysicsComponent.velocity.y > 0 then
			jumpSpeed = math.max(jumpSpeed - self.PhysicsComponent.velocity.y, 0)
		elseif self.PhysicsComponent.velocity.y < 0 then
			jumpSpeed = math.abs(self.PhysicsComponent.velocity.y)
		end

		print("Jump Speed: "..jumpSpeed)
		self.PhysicsComponent.velocity.y -= jumpSpeed
	end
end

-- NOTE: This name sucks and doesn't cover everything it does, reconsider
function Player:saveGroundedPosition()
	if self.bUnderwater then
		self:moveTo(self.LastGroundedX, self.LastGroundedY - 5)
		self.PhysicsComponent:setPosition(self.x, self.y)
		self.PhysicsComponent:setVelocity(0, 0)
		self:damage(1, 0)
	elseif self.bGrounded then
		local checkWidth = 5
		local leftCollisionSprite, _ = Raycast(self.x - checkWidth, self.y, 0, 17, {self}, {"DpadNotif"})
		local rightCollisionSprite, _ = Raycast(self.x + checkWidth, self.y, 0, 17, {self}, {"DpadNotif"})
		if leftCollisionSprite and rightCollisionSprite then
			if self:collisionResponse(leftCollisionSprite) == "slide" and self:collisionResponse(rightCollisionSprite) == "slide" then
				self.LastGroundedX = self.x
				self.LastGroundedY = self.y
			end
		end
	end
end

function Player:updateObject()
	local Gravity = 0.5
	self.PhysicsComponent:addForce(0, Gravity * self.gravityScale)
	-- print("Gravity: "..Gravity * self.gravityScale)
	local collisions

	if self.bActive then
		if pd.buttonJustPressed(pd.kButtonUp) then
			local CollidingWithSprites = self:overlappingSprites()
			for _, sprite in ipairs(CollidingWithSprites) do
				if sprite.interact then
					sprite:interact(self)
				end
			end
		end

		if pd.buttonJustPressed(pd.kButtonA) then
			if self.bGrounded then
				self.PhysicsComponent.velocity.y = -8
				self.bJumped = true
			else
				self.bDesireJump = true
				pd.frameTimer.performAfterDelay(5, function ()
					self.bDesireJump = false
				end)
			end
		end

		-- NOTE: Buffer jump
		if self.bGrounded and self.bDesireJump then
			self.PhysicsComponent.velocity.y = -8
			self.bJumped = true
			self.bDesireJump = false
		end

		-- NOTE: This is so the player falls faster in their descent, doesn't apply when they walk off the edge
		if self.bJumped and self.PhysicsComponent.velocity.y > 0 then
			self.gravityScale = 1.5
		else
			self.gravityScale = 1
		end

		self:handleWalk()

		collisions, _ = self.PhysicsComponent:move(self)

		-- NOTE: Pickup physics objects
		if self.PlayerData.bHoldingObject then
			if self.bCrouching then
				self.PlayerData.HeldImage:draw(self.x - 8, self.y - 32 - 10)
			else
				if self.state == PLAYER_STATES.WALKING and self.animationLoop.frame % 2 == 0 then
					self.PlayerData.HeldImage:draw(self.x - 8, self.y - 32 - 14 - 1)
				else
					self.PlayerData.HeldImage:draw(self.x - 8, self.y - 32 - 14)
				end
			end

			if pd.buttonJustPressed(pd.kButtonB) then
				if pd.buttonIsPressed(pd.kButtonDown) then
					self.PlayerData.HeldObject:drop(self)
				else
					self.PlayerData.HeldObject:throw(self)
				end
			end
		elseif pd.buttonJustPressed(pd.kButtonB) then
			local CollidingWithSprites = self:overlappingSprites()
			for _, sprite in ipairs(CollidingWithSprites) do
				if sprite.pickup then
					sprite:pickup(self)
				end
			end
		end
	end

	self:calculateGrounded(collisions)

	-- NOTE: Resets the jumped state when the player is on the ground
	if self.bGrounded then
		self.bJumped = false
	end

	self:keepPlayerWithinMap()

	self:calculateState()

	self:setPlayerImage()

	self.PlayerData:DrawPlayerHud()

	if self.Invincible > 0 then
		self.Invincible -= 1
	end
	self:saveGroundedPosition()
end
