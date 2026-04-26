class('PlayerData').extends()

-- NOTE: Stores generic info on the player that should persist between boat mode and person mode

local pd <const> = playdate
local gfx <const> = pd.graphics

local HealthImage = gfx.image.new(250, 100)
local OldCoin = nil
local CoinImage = gfx.image.new(100, 100)

local HalfHeartImage = gfx.image.new("images/HalfHeartIcon")
local FullHeartImage = gfx.image.new("images/HeartIcon")
local EmptyHeartImage = gfx.image.new("images/EmptyHeartIcon")

function PlayerData:DrawHearts(Health, MaxHealth)
	HealthImage:clear(gfx.kColorClear)
	gfx.lockFocus(HealthImage)

	local FullHearts = math.floor(Health / 2)
	local HaveHalfHeart = (Health % 2) == 1
	local EmptyHearts = math.floor((MaxHealth - Health) / 2)

	for i = 1, FullHearts do
		FullHeartImage:draw(16 + (i - 1) * 32, 16)
	end

	if HaveHalfHeart then
		HalfHeartImage:draw(16 + (FullHearts) * 32, 16)
	end

	for i = math.ceil(Health / 2) + 1, MaxHealth / 2 do
		EmptyHeartImage:draw(16 + (i - 1) * 32, 16)
	end

	gfx.unlockFocus()

	UISystem:drawImageAt(HealthImage, 0, 0)
end

function PlayerData:DrawCoins()
	if (OldCoin ~= self.coins) then
		CoinImage:clear(gfx.kColorClear)
		gfx.lockFocus(CoinImage)
		local nsCoins = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)
		local width, _ = gfx.getTextSize(math.floor(self.coins).."x")
		nsCoins:drawInRect(10, 50, width + 45, 28)
		gfx.drawText(math.floor(self.coins).." x", 20, 55)
		gfx.image.new("images/Coin"):draw(30 + width, 56)
		gfx.unlockFocus()
	end

	OldCoin = self.coins

	UISystem:drawImageAt(CoinImage, 300, -40)
end

function PlayerData:DrawPlayerHud()
	self:DrawHearts(self.PlayerHealth, self.PlayerMaxHealth)
	self:DrawCoins()
end

function PlayerData:DrawBoatHud()
	self:DrawHearts(self.BoatHealth, self.BoatMaxHealth)
	self:DrawCoins()
end

function PlayerData:DamagePlayer(amount)
	self.PlayerHealth = math.max(0, self.PlayerHealth - amount)
end

function PlayerData:DamageBoat(amount)
	self.BoatHealth = math.max(0, self.BoatHealth - amount)
end

function PlayerData:init()
	self.bHoldingObject = false
	self.HeldImage = nil
	self.HeldObject = nil

	self.PlayerMaxHealth = 6
	self.PlayerHealth = self.PlayerMaxHealth

	self.BoatMaxHealth = 6
	self.BoatHealth = self.BoatMaxHealth

	self.coins = 0
end
