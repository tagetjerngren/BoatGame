local Min <const> = math.min
local Max <const> = math.max

function Clamp(value, min, max)
	return Min(Max(value, min), max)
end

function abs(value)
	if value >= 0 then
		return value
	else
		return -value
	end
end

local point_new <const> = playdate.geometry.point.new
local QuerySpriteInfoAlongLine <const> = playdate.graphics.sprite.querySpriteInfoAlongLine

function Raycast(sourceX, sourceY, directionX, directionY, ignoreSpritesList, ignoreClassesList)
	local source = point_new(sourceX, sourceY)
	local collisions, _ = QuerySpriteInfoAlongLine(sourceX, sourceY, sourceX + directionX, sourceY + directionY)
	local closestCollision, closestCollisionLength, collisionPoint
	for _, collision in ipairs(collisions) do
		local distance = (collision.entryPoint - source):magnitude()
		if not closestCollision or distance < closestCollisionLength then
			local ignored = false
			if ignoreSpritesList then
				for _, ignoreSprite in ipairs(ignoreSpritesList) do
					if collision.sprite == ignoreSprite then
						ignored = true
						break
					end
				end
			end
			if not ignored and ignoreClassesList then
				for _, ignoreClass in ipairs(ignoreClassesList) do
					if collision.sprite.className == ignoreClass then
						ignored = true
						break
					end
				end
			end

			if not ignored then
				closestCollisionLength = distance
				closestCollision = collision.sprite
				collisionPoint = collision.entryPoint
			end
		end
	end
	return closestCollision, collisionPoint
end
