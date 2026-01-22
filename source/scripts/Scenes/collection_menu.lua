local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
-- import "scripts/saves"
-- import "scripts/water"
-- import "scripts/entities/dummyPlayer"

class('CollectionMenu').extends(gfx.sprite)

function CollectionMenu:init(gameManager)
	local allSprites = gfx.sprite.getAllSprites()
	for _, sprite in ipairs(allSprites) do
		sprite:setUpdatesEnabled(false)
	end
	self.gameManager = gameManager

	self:setZIndex(2000)
	self:setIgnoresDrawOffset(true)

	self:setImage(gfx.image.new("images/CollectionScreen"))
	-- self:setCenter(0, 0)
	self:moveTo(200, 120)

	self.grid = pd.ui.gridview.new(44, 44)
	self.grid:setNumberOfColumns(7)
	self.grid:setNumberOfRows(3)
	self.grid:setCellPadding(2, 2, 2, 2)
	-- self.grid.backgroundImage = gfx.nineSlice.new("images/gridBackground", 8, 8, 47, 47)
	-- self.grid:setContentInset(10, 10, 10, 10)
	self.sampleCollection = self.gameManager.player.sampleCollection
	local icons = {}
	for i = 1, #self.gameManager.player.sampleCollection do
		table.insert(icons, gfx.image.new(self.gameManager.player.sampleCollection[i]["iconPath"]))
	end

	-- local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	-- local nsBlank = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)
	local ns = gfx.nineSlice.new("images/CollectionCellSelected", 12, 12, 24, 24)
	local nsBlank = gfx.nineSlice.new("images/CollectionCell", 12, 12, 24, 24)
	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			ns:drawInRect(x, y, width, height)
			-- gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.setImageDrawMode(gfx.kDrawModeInverted)
			gfx.setColor(gfx.kColorWhite)
			icons[(row - 1) * 7 + column]:draw(x + 6, y + 6)
			-- gfx.drawTextInRect("*"..options[row].."*", x, y + (height/2) - 5 + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			nsBlank:drawInRect(x, y, width, height)
			icons[(row - 1) * 7 + column]:draw(x + 6, y + 6)
			-- gfx.drawTextInRect(options[row], x, y + (height/2) - 5, width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:add()
	self.bActive = true
end

local movingSound = pd.sound.sampleplayer.new("sounds/ChangingSelection")
local decisionSound = pd.sound.sampleplayer.new("sounds/SelectionMade")

function CollectionMenu:update()
	if self.bActive then
		if pd.buttonJustPressed(pd.kButtonDown) then
			self.grid:selectNextRow(false)
			movingSound:play()
		elseif pd.buttonJustPressed(pd.kButtonUp) then
			self.grid:selectPreviousRow(false)
			movingSound:play()
		elseif pd.buttonJustPressed(pd.kButtonLeft) then
			self.grid:selectPreviousColumn(false)
			movingSound:play()
		elseif pd.buttonJustPressed(pd.kButtonRight) then
			self.grid:selectNextColumn(false)
			movingSound:play()
		elseif pd.buttonJustReleased(pd.kButtonA) then
			local _, row, column = self.grid:getSelection()
			self.bActive = false
			TextBox("*"..self.sampleCollection[(row - 1) * 7 + column]["name"].."*\n"..self.sampleCollection[(row - 1) * 7 + column]["description"], 10, function()
				self.bActive = true
			end, 0, 3000)
		elseif pd.buttonJustReleased(pd.kButtonB) then
			local allSprites = gfx.sprite.getAllSprites()
			for _, sprite in ipairs(allSprites) do
				self:remove()
				sprite:setUpdatesEnabled(true)
			end
			self.gameManager:ActivatePhysicsComponents()
		end
	end


	-- if #self.options == 2 then
	-- 	self.grid:drawInRect(0, 0, 235 - 60, 240 - 60)
	-- else
	-- local gridImage = gfx.image.new(385, 178)
	gfx.lockFocus(self:getImage())
	self.grid:drawInRect(32, 48, 385, 178)
	gfx.unlockFocus()
	-- gridImage:drawIgnoringOffset(32, 48)
	-- end

	gfx.setColor(gfx.kColorBlack)
end
