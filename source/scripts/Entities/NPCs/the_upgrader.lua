local pd <const> = playdate
local gfx <const> = pd.graphics

class('TheUpgrader').extends(gfx.sprite)

function TheUpgrader:init(x, y)
	self:setCollideRect(0, 0, 64, 48)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x + 32, y + 24)
	local anim = gfx.imagetable.new("images/TheUpgrader")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(400, anim, true)

	self:setImage(self.animationLoop:image())
	self:add()
	self.coinPickupSound = pd.sound.sampleplayer.new("sounds/BigCoinPickup")
end

function TheUpgrader:update()
	self:setImage(self.animationLoop:image())
end

function TheUpgrader:interact(player)
	local upgradeCost = 5 ^ (player.weaponTier + 1)
	self.coinPickupSound:play()
	if player.weaponTier == 4 then
		TextBox("*UPGRADER*\nYou've already reached your full potential\n_sorry_", 10)
	else
		TextBox("*UPGRADER*\nI can upgrade your weapon for only "..math.floor(upgradeCost).."g", 10, function ()
			OptionBox("Upgrade weapon?", {"Yes ("..math.floor(upgradeCost).."g)", "No"}, function (index, selectionString)
				if selectionString == "No" then
					TextBox("*UPGRADER*\nAlright then, I'll still be here.", 10)
				else
					if player.coins >= upgradeCost then
						TextBox("*UPGRADER*\nYour weapon is more powerful now,\n careful not to hurt yourself", 10)
						player.coins -= upgradeCost
						player.weaponTier += 1
					else
						TextBox("You don't have enough money,\n _come back when you're a little richer_", 10)
					end
				end
			end)
		end)
	end
end
