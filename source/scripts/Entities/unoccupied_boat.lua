import "CoreLibs/sprites"
import "CoreLibs/graphics"
import "CoreLibs/animation"

import "scripts/Misc/physics_component"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('UnoccupiedBoat').extends(gfx.sprite)

function UnoccupiedBoat:init(x, y, gameManager, level)
	self.GameManager = gameManager
	self.level = level

	self:moveTo(x,y)
	self:setImage(gfx.image.new("images/Boat"))
	-- NOTE: Smaller collision size to cover the boat more snugly
	local CollisionHeight = 4
	self:setCollideRect(0, 32 - CollisionHeight, 32, CollisionHeight)

	self.PhysicsComponent = PhysicsComponent(x, y, 10)

	self.bUnderwater = false
	self.bCanJump = true

	self:setCenter(0.5,1)

	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.WALL, COLLISION_GROUPS.ENEMY, COLLISION_GROUPS.EXPLOSIVE, COLLISION_GROUPS.PICKUPS})

	self.direction = 1

	self.boatImage = gfx.image.new("images/Boat")
	self.currentImage = self.boatImage

	self.notif = DpadNotif(x - 32, y - 32, 64, 32)
end

function UnoccupiedBoat:updateObject()
	if pd.buttonJustPressed(pd.kButtonUp) then
		local CollidingWithSprites = gfx.sprite.querySpritesInRect(self.x - 32, self.y - 32, 64, 64)
		for _, sprite in ipairs(CollidingWithSprites) do
			if sprite:isa(Player) then
				-- self.GameManager.player:remove()
				self.GameManager:remove(self.GameManager.player)
				-- self.GameManager.player = PlayerBoat(self.x, self.y, gfx.image.new("images/PlayerBoat"), 5, self.GameManager)
				self.GameManager.player = self.GameManager.playerBoatInstance
				self.GameManager.player:moveTo(self.x, self.y)
				self.GameManager.player.PhysicsComponent.position.x = self.x
				self.GameManager.player.PhysicsComponent.position.y = self.y

				table.insert(self.GameManager.ActivePhysicsComponents, self.GameManager.player.PhysicsComponent)
				-- self.GameManager.player:add()
				self.GameManager:add(self.GameManager.player)

				-- TODO: This loop and comparing feels pretty bad, make the array a map instead so it's easier to grab specific objects
				for i, v in ipairs(self.GameManager.ActivePhysicsComponents) do
					if v == self.PhysicsComponent then
						table.remove(self.GameManager.ActivePhysicsComponents, i)
						break
					end
				end
				self.GameManager:remove(self)
				-- self:remove()
				self.GameManager:remove(self.notif)
				-- self.notif:remove()
			end
		end
	end

	local Gravity = 0.5
	self.PhysicsComponent:addForce(0, Gravity)
	local collisions, _ = self.PhysicsComponent:move(self)
end
