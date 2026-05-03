local pd <const> = playdate
local gfx <const> = pd.graphics

class('Offering').extends(gfx.sprite)

function Offering:init(x, y, entity)
	self.entity = entity
	self:moveTo(x + 8, y + 8)
	self:setImage(gfx.image.new("images/Offering"))
	self:setCollideRect(0, 0, 16, 16)
	self:setGroups(COLLISION_GROUPS.PICKUPS)
	self:setCollidesWithGroups({COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.WALL})
	self.PhysicsComponent = PhysicsComponent(x, y, 10)
	-- self:add()
	GameManagerInstance:add(self)
end

function Offering:collisionResponse(other)
	if EntityIsCollisionGroup(other, COLLISION_GROUPS.PLAYER) then
		return "overlap"
	elseif EntityIsCollisionGroup(other, COLLISION_GROUPS.WALL) then
		return "slide"
	end
end

function Offering:pickup(player)
	-- player.bActive = false
	-- player.GameManager:collect(self.entity.iid)
	-- self.entity.fields.PickedUp = true
	--
	-- OptionBox("Pick a weapon", self.entity.fields.Abilities, function (index, string)
	-- 	PopupTextBox(AbilityExplanation[string], 4000, 10)
	-- 	player.setAbilityA(player, Abilities[string], string)
	-- end)
	-- -- AbilitySelectionMenu(player, self.entity)
	--
	-- self:remove()
	player.PlayerData.bHoldingObject = true
	player.PlayerData.HeldImage = self:getImage()
	player.PlayerData.HeldObject = self
	self:setVisible(false)
end

function Offering:throw(player)
	player.PlayerData.bHoldingObject = false
	self:setVisible(true)
	self.PhysicsComponent.position.x = player.x
	self.PhysicsComponent.position.y = player.y - 32
	self.PhysicsComponent.velocity = player.PhysicsComponent.velocity
	self:moveTo(self.PhysicsComponent.position.x, self.PhysicsComponent.position.y)
	self.PhysicsComponent:addForce(player.direction * 4, -4)
end

function Offering:drop(player)
	player.PlayerData.bHoldingObject = false
	self:setVisible(true)
	self.PhysicsComponent.position.x = player.x
	self.PhysicsComponent.position.y = player.y - 32
	self.PhysicsComponent.velocity = player.PhysicsComponent.velocity
	self:moveTo(self.PhysicsComponent.position.x, self.PhysicsComponent.position.y)
end

function Offering:keepWithinMap()
	local CollideRect = self:getCollideRect()
	local HalfWidth = CollideRect.width / 2

	local LeftEdge = self.x - HalfWidth
	local RightEdge = self.x + HalfWidth

	if RightEdge > GameManagerInstance.LevelWidth then
		self:moveTo(GameManagerInstance.LevelWidth - HalfWidth, self.y)
		self.PhysicsComponent.position.x = GameManagerInstance.LevelWidth - HalfWidth
	end

	if LeftEdge < 0 then
		self:moveTo(HalfWidth, self.y)
		self.PhysicsComponent.position.x = HalfWidth
	end
end

function Offering:updateObject()
	local Gravity = 0.5
	self.PhysicsComponent:addForce(0, Gravity)

	if self.bGrounded or self.bUnderwater then
		self.PhysicsComponent:addForce(-self.PhysicsComponent.velocity.x * 0.1, 0)
	end

	self.bGrounded = false
	local collisions, _ = self.PhysicsComponent:move(self)
	self.bUnderwater = self.y > GameManagerInstance.water.height
	for i = 1, #collisions do
		if collisions[i].normal.y == -1 and collisions[i].other:getGroupMask() == 8 then
			self.bGrounded = true
		end
	end
	self:keepWithinMap()
end
