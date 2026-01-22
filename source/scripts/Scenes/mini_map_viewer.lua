local pd <const> = playdate
local gfx <const> = pd.graphics

class('MiniMapViewer').extends(gfx.sprite)

function MiniMapViewer:init(gameManager)
	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		sprite:setUpdatesEnabled(false)
	end
	self:setImage(gfx.image.new(400, 240))
	self.gameManager = gameManager
	self.miniMap = gameManager.miniMapWithHighlight:copy()
	self:setZIndex(2000)
	self:setIgnoresDrawOffset(true)
	self.mapOffsetX = 0
	self.mapOffsetY = 0
	self.mapPanMinX = -100
	self.mapPanMinY = -100
	self.mapPanMaxX = 100
	self.mapPanMaxY = 100
	self:setCenter(0, 0)
	self:add()
	self.cameraPanSpeed = 3
	self.zoomLevel = 1
end

function MiniMapViewer:update()
	self:setImage(gfx.image.new(400, 240, gfx.kColorWhite))

	if pd.buttonIsPressed(pd.kButtonLeft) then
		self.mapOffsetX += self.cameraPanSpeed
	end
	if pd.buttonIsPressed(pd.kButtonRight) then
		self.mapOffsetX -= self.cameraPanSpeed
	end
	if pd.buttonIsPressed(pd.kButtonUp) then
		self.mapOffsetY += self.cameraPanSpeed
	end
	if pd.buttonIsPressed(pd.kButtonDown) then
		self.mapOffsetY -= self.cameraPanSpeed
	end
	self.mapOffsetX = Clamp(self.mapOffsetX, self.mapPanMinX, self.mapPanMaxX)
	self.mapOffsetY = Clamp(self.mapOffsetY, self.mapPanMinY, self.mapPanMaxY)

	if pd.buttonJustReleased(pd.kButtonB) then
		local allSprites = gfx.sprite.getAllSprites()
		for _, sprite in ipairs(allSprites) do
			self:remove()
			sprite:setUpdatesEnabled(true)
		end
		self.gameManager:ActivatePhysicsComponents()
	end

	-- gfx.setColor(gfx.kColorBlack)
	-- local mapMask = gfx.image.new(1000, 1000)
	-- gfx.lockFocus(mapMask)
	-- -- gfx.fillRect(30 - self.mapOffsetX, 30 - self.mapOffsetY, 400 - 60, 240 - 60)
	-- gfx.fillRect(0, 0, 1000, 1000)
	-- gfx.unlockFocus()
	-- self.miniMap:setMaskImage(mapMask)

	local change, _ = pd.getCrankChange()
	self.zoomLevel += change/100

	gfx.lockFocus(self:getImage())
	gfx.drawRect(30, 30, 400 - 60, 240 - 60)
	self.miniMap:drawScaled(self.mapOffsetX, self.mapOffsetY, self.zoomLevel)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400, 30)
	gfx.fillRect(0, 0, 30, 240)
	gfx.fillRect(370, 0, 30, 240)
	gfx.fillRect(0, 210, 400, 30)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawTextAligned("*MAP*", 200, 10, kTextAlignment.center)
	gfx.fillCircleAtPoint(150, 227, 12)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned("*B*", 150, 220, kTextAlignment.center)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.drawTextAligned("*CLOSE MAP*", 165, 220, kTextAlignment.left)
	-- self.gameManager:highlightLevelMiniMap(self.gameManager.currentLevel, self.mapOffsetX - 1, self.mapOffsetY - 1)
	gfx.unlockFocus()
end
