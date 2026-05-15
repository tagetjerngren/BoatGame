local pd <const> = playdate
local gfx <const> = pd.graphics

-- import "CoreLibs/frameTimer"

function ChangeSize(player, button)
	if pd.buttonIsPressed(button) then
		if pd.buttonJustPressed(pd.kButtonDown) then
			if player:getScale() == 1 then
				player:setScale(0.5)
				player:setCollideRect(4, 6, 13, 11)
			elseif player:getScale() == 2 then
				player:setScale(1)
				player:setCollideRect(4, 10, 26, 22)
			end
		elseif pd.buttonJustPressed(pd.kButtonUp) then
			if player:getScale() == 1 then
				player:setScale(2 * player:getScale())
				player:setCollideRect(4, 20, 52, 44)
			elseif player:getScale() == 0.5 then
				player:setScale(1)
				player:setCollideRect(4, 10, 26, 22)
			end
		end
	end
end


function Invisibility(player, button)
	if pd.buttonIsPressed(button) then
		player.bInvisible = true
		player:setImage(gfx.image.new("images/BoatCorpse"))
	else
		player.bInvisible = false
		player:setImage(gfx.image.new("images/Boat"))
	end

	if player.direction == -1 then
		player:setImageFlip(gfx.kImageFlippedX)
	end
end

function Teleport(player, button)
	local TeleportDistance = 64
	if pd.buttonJustPressed(button) then
		player:moveBy(TeleportDistance * player.direction, 0)
		local Collisions = player:overlappingSprites()
		local bTeleportedIntoObject = false
		for i = 1, #Collisions do
			if player:collisionResponse(Collisions[i]) ~= "overlap" then
				bTeleportedIntoObject = true
				break
			end
		end
		if bTeleportedIntoObject then
			player:moveBy(-TeleportDistance * player.direction, 0)
		else
			player.PhysicsComponent.position = pd.geometry.vector2D.new(player.x, player.y)
		end
	end
end

-- Abilities = {
-- 	["ChangeSize"] = ChangeSize,
-- 	["Invisibility"] = Invisibility
-- }
--
-- AbilityExplanation = {
-- 	["ChangeSize"] = "Hold B and tap up or down to alter your size",
-- 	["Invisibility"] = "Hold B to turn yourself\ninvisble to enemies and others"
-- }
