local pd <const> = playdate
local gfx <const> = pd.graphics

class('TheTall').extends(gfx.sprite)

function TheTall:init(x, y)
	self:setCollideRect(0, 0, 64, 48)

	self:setZIndex(-1)

	self:setGroups(COLLISION_GROUPS.TRIGGER)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)

	self:moveTo(x + 32, y + 24)
	local anim = gfx.imagetable.new("images/TheTall")
	assert(anim)
	self.animationLoop = gfx.animation.loop.new(400, anim, true)

	self:setImage(self.animationLoop:image())
	self:add()
	self.coinPickupSound = pd.sound.sampleplayer.new("sounds/BigCoinPickup")
end

function TheTall:update()
	self:setImage(self.animationLoop:image())
end

function TheTall:interact(player)
	self.coinPickupSound:play()
	local phrases = {"hello, hello, hello, hello", "Hello, I got places to be", "Hold up I'm readjusting my speed", "It's me after you, and you after me"}
	local randInt = math.random(#phrases)
	TextBox("*TALL*\n"..phrases[randInt], 10, function ()
		self:moveBy(0, randInt-2)
	end)
end
