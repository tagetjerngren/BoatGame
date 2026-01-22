local pd <const> = playdate
local gfx <const> = pd.graphics
local imageNew <const> = gfx.image.new
local vector2DNew <const> = pd.geometry.vector2D.new

class('DiagonalEnemy').extends(gfx.sprite)

local DiagonalEnemyImage = imageNew("images/DiagonalEnemy")

function DiagonalEnemy:init(x, y, entity)
	self:moveTo(x + 8, y + 8)
	self:setImage(DiagonalEnemyImage)
	self:setCollideRect(0, 0, 16, 16)
	self:setGroups(COLLISION_GROUPS.ENEMY)
	self:setCollidesWithGroups({COLLISION_GROUPS.PROJECTILE, COLLISION_GROUPS.WALL, COLLISION_GROUPS.TRIGGER, COLLISION_GROUPS.PLAYER, COLLISION_GROUPS.ENEMY})
	local velocity = vector2DNew(entity.fields.Direction.cx * 16 - x, entity.fields.Direction.cy * 16 - y)
	velocity:normalize()
	self.xVel = velocity.x * entity.fields.Speed
	self.yVel = velocity.y * entity.fields.Speed
	self:add()
end

function DiagonalEnemy:collisionResponse(other)
	if other:isa(DoorTrigger) then
		return "slide"
	elseif other:isa(Player) then
		other:damage(20, 30)
		return "overlap"
	else
		return "slide"
	end

end

function DiagonalEnemy:update()
	local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVel, self.y + self.yVel)
	for i = 1, length do
		if collisions[i].other:isa(Player) then
			break
		elseif math.abs(collisions[i].normal.x) == 1 then
			self.xVel *= -1
		elseif math.abs(collisions[i].normal.y) == 1 then
			self.yVel *= -1
		end
	end
end
