class('PlayerData').extends()

-- NOTE: Stores generic info on the player that should persist between boat mode and person mode

local pd <const> = playdate
local gfx <const> = pd.graphics

local CoinBackgroundImage = gfx.image.new(100, 100)
local HudHealthImage = gfx.image.new(250, 100)
local HudCoinImage = gfx.image.new(100, 100)

local ActiveAbilityBackgroundImage = gfx.image.new("images/CollectionCellSelected")

local HalfHeartImage = gfx.image.new("images/HalfHeartIcon")
local FullHeartImage = gfx.image.new("images/HeartIcon")
local EmptyHeartImage = gfx.image.new("images/EmptyHeartIcon")

function PlayerData:DrawHearts(Health, MaxHealth, additionalXOffset)
	local xOffset = 48 + 4
	local yOffset = 8
	HudHealthImage:clear(gfx.kColorClear)
	gfx.lockFocus(HudHealthImage)

	ActiveAbilityBackgroundImage:draw(0, 0)

	if GameManagerInstance.PlayerData.activeAbility then
		if GameManagerInstance.player:isa(PlayerBoat) then
			GameManagerInstance.PlayerData.activeAbility.icon:draw(8, 8)
		end
	end

	local FullHearts = math.floor(Health / 2)
	local HaveHalfHeart = (Health % 2) == 1
	-- local EmptyHearts = math.floor((MaxHealth - Health) / 2)

	for i = 1, FullHearts do
		FullHeartImage:draw(xOffset + (i - 1) * 32, yOffset)
	end

	if HaveHalfHeart then
		HalfHeartImage:draw(xOffset + (FullHearts) * 32, yOffset)
	end

	for i = math.ceil(Health / 2) + 1, MaxHealth / 2 do
		EmptyHeartImage:draw(xOffset + (i - 1) * 32, yOffset)
	end

	gfx.unlockFocus()

	UISystem:drawImageAt(HudHealthImage, 0, 0)
end

function PlayerData:DrawCoins()
	HudCoinImage:clear(gfx.kColorClear)
	gfx.lockFocus(HudCoinImage)

	CoinBackgroundImage:draw(0, 0)
	local coins = math.floor(self.coins)
	local coinsString = tostring(coins)
	local zeroesToPrepend = 4 - string.len(coinsString)
	for i = 1, zeroesToPrepend do
		coinsString = "0"..coinsString
	end

	local width, _ = gfx.getTextSize("9999")
	gfx.drawText(coinsString, 20, 55)
	gfx.image.new("images/Coin"):draw(30 + width, 56)
	gfx.unlockFocus()

	UISystem:drawImageAt(HudCoinImage, 300, -40)
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

function PlayerData:addCoins(amount)
	self.coins = math.min(self.MaxCoins, self.coins + amount)
end

function PlayerData:init()
	gfx.lockFocus(CoinBackgroundImage)
	local nsCoins = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)
	local width, _ = gfx.getTextSize("9999")
	nsCoins:drawInRect(10, 50, width + 42, 28)
	gfx.unlockFocus()

	self.bHoldingObject = false
	self.HeldImage = nil
	self.HeldObject = nil

	self.PlayerMaxHealth = 6
	self.PlayerHealth = self.PlayerMaxHealth

	self.BoatMaxHealth = 6
	self.BoatHealth = self.BoatMaxHealth

	self.MaxCoins = 9999
	self.coins = 0

	self.abilities = {}
	self.activeAbility = nil
	for i = 1, 8 do
		table.insert(self.abilities, {func = nil, icon = gfx.image.new("images/QuestionMark")})
	end
end
