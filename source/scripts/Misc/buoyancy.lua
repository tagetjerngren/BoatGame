-- Clamp
import "utils"

local pd <const> = playdate
local vector2D_new <const> = pd.geometry.vector2D.new
local abs <const> = math.abs

-- NOTE: Returns the buoyancy force and the water drag as a sum
function CalculateBuoyancy(WaterHeight, ObjectHeight, WaterPixelDepth, WaterDrag, buoyantForce, physicsObject)
	local DesiredHeight = WaterHeight
	local DirectionToWater = (ObjectHeight - DesiredHeight)

	-- Return early if we aren't in the water
	if DirectionToWater <= 0 then
		return vector2D_new(0, 0)
	end

	local DirectionToWaterNormalized = DirectionToWater / abs(DirectionToWater)
	if DirectionToWater == 0 then
		DirectionToWaterNormalized = 0
	end

	-- Buoyancy values
	local displacementNum = Clamp(abs(DirectionToWater), 0, WaterPixelDepth) / WaterPixelDepth

	-- Applies buoyancy forces and water drag
	return vector2D_new(0, -DirectionToWaterNormalized * buoyantForce * displacementNum + -physicsObject.velocity.y * WaterDrag)
end

function EntityIsCollisionGroup(object, group)
	return (((2^(group - 1)) & object:getGroupMask()) ~= 0)
end

