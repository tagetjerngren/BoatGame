local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/Entities/Hazards/bullet"
import "scripts/Entities/Misc/explosion"
import "CoreLibs/frameTimer"

local jumpTierValues = {8, 12, 30, 50}
local jumpDamageValues = {10, 20, 40, 60}

function Jump(player, button)
	-- TODO: Add a cooldown
	if pd.buttonJustPressed(button) and player.bCanJump then
		local sprites = gfx.sprite.querySpritesInRect(player.x - 25, player.y - 8, 50, 50)
		-- TODO: Add a poof animation
		gfx.fillRect(player.x - 25, player.y - 8, 50, 50)
		for _, sprite in ipairs(sprites) do
			if not sprite:isa(Player) and sprite.damage then
				sprite:damage(jumpDamageValues[player.weaponTier], 10)
			end
			if sprite.PhysicsComponent then
				local blastDirection = (sprite.PhysicsComponent.position - pd.geometry.vector2D.new(player.x, player.y + 25)):normalized()
				sprite.PhysicsComponent:addForce(blastDirection * jumpTierValues[player.weaponTier])
			end
		end
		player.bCanJump = false
		pd.frameTimer.new(30, function ()
			player.bCanJump = true
		end)
		-- player:addForce(pd.geometry.vector2D.new(0, -8))
		-- player.bCanJump = false
	end
end

local shootTierValues = {5, 15, 25, 40}
local shootDamageValues = {10, 20, 40, 60}

function Shoot(player, button)
	if pd.buttonJustPressed(button) then
		Bullet(player.PhysicsComponent.position.x + player.direction * 40, player.PhysicsComponent.position.y - 5, pd.geometry.vector2D.new(player.direction * shootTierValues[player.weaponTier], 0), shootDamageValues[player.weaponTier])
	end
end

local explosionMeterMax = 100
local anim = gfx.animation.loop.new(100, gfx.imagetable.new("images/Fire"), true)

local overheatTierValues = {5, 15, 30, 60}
local overheatIncreaseValues = {3, 2, 1, 0.5}
local overheatDecreaseValues = {1, 2, 3, 4}

function Overheat(player, button)
	if pd.buttonIsPressed(button) then
		anim:draw(player.x - 32, player.y - 32 - 20)
		local sprites = gfx.sprite.querySpritesInRect(player.x - 25, player.y - 25 - 8, 50, 50)
		-- NOTE: Visualization of the damage zone
		-- gfx.fillRect(player.x - 25, player.y - 25 - 8, 50, 50)
		for _, value in ipairs(sprites) do
			if not value:isa(Player) and value.damage then
				value:damage(overheatTierValues[player.weaponTier], 10)
			end
			if value.ignite then
				value:ignite()
			end
		end
		player.explosionMeter += overheatIncreaseValues[player.weaponTier]
	else
		player.explosionMeter -= overheatDecreaseValues[player.weaponTier]
	end

	player.explosionMeter = Clamp(player.explosionMeter, 0, explosionMeterMax)

	if player.explosionMeter > 0 then
		if player.explosionMeter == explosionMeterMax then
			player.explosionMeter = 0
			Explosion(player.x, player.y)
		end

		local img = gfx.image.new(100, 100)
		gfx.lockFocus(img)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 34, 14)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(1, 1, 32, 12)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(2, 2, (player.explosionMeter/explosionMeterMax) * 30, 10)
		gfx.unlockFocus()
		UISystem:drawImageAtWorld(img, player.x - 17, player.y - 50)
	end
end
function DoSubmerge(player)
	if player.bUnderwater then
		player.PhysicsComponent.bBuoyant = false
		if playdate.buttonIsPressed(playdate.kButtonDown) then
			-- player:AddForce(playdate.geometry.vector2D.new(0, 0.5 * player.Speed))
			player.PhysicsComponent.velocity.y = player.Speed
		elseif playdate.buttonIsPressed(playdate.kButtonUp) then
			-- player:AddForce(playdate.geometry.vector2D.new(0, -0.5 * player.Speed))
			player.PhysicsComponent.velocity.y = -player.Speed
		else
			player.PhysicsComponent.velocity.y = 0
		end
	end
end


function DoInterest(player)
	player.coins *= 1.0005
	player.Health *= 1.0005
	player.Health = Clamp(player.Health, 0, 100)
end

function Dive(player, button)
	if pd.buttonJustPressed(button) then
		player.PhysicsComponent.velocity = pd.geometry.vector2D.new(0, 300)
		player.bCanDive = false
	end
end

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
		player:setImage(gfx.image.new("images/BoatCorpse"))
		if player.direction == -1 then
			player:setImageFlip(gfx.kImageFlippedX)
		end
		player.bInvisible = true
	else
		player:setImage(gfx.image.new("images/Boat"))
		if player.direction == -1 then
			player:setImageFlip(gfx.kImageFlippedX)
		end
		player.bInvisible = false
	end
end


Abilities = {
	["Jump"] = Jump,
	["Shoot"] = Shoot,
	["Dive"] = Dive,
	["Overheat"] = Overheat,
	["ChangeSize"] = ChangeSize,
	["Invisibility"] = Invisibility
}

AbilityExplanation = {
	["Jump"] = "Press A to set off an\nexplosion beneath yourself",
	["Shoot"] = "Press A to shoot a bullet that can\nflip switches or do damage",
	["Dive"] = "Dive beneath the tide",
	["Overheat"] = "Hold A to momentarily make\nyour vessel extremely hot",
	["ChangeSize"] = "Hold B and tap up or down to alter your size",
	["Invisibility"] = "Hold B to turn yourself\ninvisble to enemies and others"
}
