local pd <const> = playdate
local gfx <const> = pd.graphics

class('BigMan').extends(gfx.sprite)

function BigMan:init(x, y)
	self:setCollideRect(0, 0, 128, 96)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x + 64, y + 48)
	local anim = gfx.imagetable.new("images/BigMan")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(400, anim, true)

	self:setImage(self.animationLoop:image())
	self:add()
	self.coinPickupSound = pd.sound.sampleplayer.new("sounds/BigCoinPickup")
	self.applause = pd.sound.sampleplayer.new("sounds/applause")
end

function BigMan:update()
	self:setImage(self.animationLoop:image())
end

function BigMan:interact(player)
	self.coinPickupSound:play()
	TextBox("*BIG*\nYou've done it", 10, function ()
		self.applause:play()
		TextBox("*BIG*\n_Congrats_", 10, function ()
			OptionBox("*BIG*\nWhat was your favorite part?", {"The Water", "The Abilities", "I dunno"}, function (index, str)
				if index == 1 then
					TextBox("*BIG*\nYeah that was kind of cool", 10)
				elseif index == 2 then
					TextBox("*BIG*\nYeah well name ten of their\n effects then if you're such a fan", 10)
				else
					TextBox("*BIG*\nYou and me both man", 10)
				end
			end)
		end)
	end)
end
