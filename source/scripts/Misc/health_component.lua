local pd <const> = playdate

class('HealthComponent').extends()

-- NOTE: The health component has two methods that are allowed to be overwritten, the damageCallback called every time you get damaged and the deathCallback called once you die. They have default behaviour of setting the sprite image inverted for 5 frames then removing sprite upon death
function HealthComponent:init(owner, maxHealth, iframes)
	self.owner = owner
	self.health = maxHealth
	self.iframes = iframes

	self.hurtSound = pd.sound.sampleplayer.new("sounds/EnemyHurt")

	self.damageCallback = (function ()
		self.owner:getImage():setInverted(true)
		self.hurtSound:setRate(math.random(7, 13)/10)
		self.hurtSound:play()
		pd.frameTimer.performAfterDelay(5, function ()
			self.owner:getImage():setInverted(false)
		end)
	end)

	self.deathCallback = (function ()
		self.owner:remove()
	end)

	self.invincible = false

end

function HealthComponent:damage(amount)
	if self.invincible then
		return
	end

	self.invincible = true
	self.health -= amount
	if self.damageCallback then
		self:damageCallback()
	end
	pd.frameTimer.performAfterDelay(self.iframes, function ()
		self.invincible = false
	end)
	if self.health <= 0 then
		if self.deathCallback then
			self:deathCallback()
		end
	end
end

