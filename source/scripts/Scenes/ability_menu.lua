local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"

class('AbilityMenu').extends(gfx.sprite)

function AbilityMenu:init(gameManager)
	self.gameManager = gameManager
	self.gameManager.player.bActive = false

	self:setZIndex(2000)
	self:setIgnoresDrawOffset(true)

	self:setImage(gfx.image.new(400, 240))
	-- self:setCenter(0, 0)
	self:moveTo(200, 120)

	self.grid = pd.ui.gridview.new(44, 44)
	self.grid:setNumberOfColumns(4)
	self.grid:setNumberOfRows(2)
	self.grid:setCellPadding(2, 2, 2, 2)
	-- self.grid.backgroundImage = gfx.nineSlice.new("images/gridBackground", 8, 8, 47, 47)
	self.grid.backgroundImage = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	self.grid:setContentInset(5, 5, 5, 5)
	self.abilities = self.gameManager.PlayerData.abilities
	local icons = {}
	for i = 1, #self.gameManager.PlayerData.abilities do
		table.insert(icons, self.gameManager.PlayerData.abilities[i].icon)
	end

	if self.gameManager.PlayerData.activeAbility then
		for i = 1, #self.abilities do
			if self.gameManager.PlayerData.activeAbility == self.abilities[i] then
				local row = math.floor(i / 4) + 1
				local column = (i % 4)
				self.grid:setSelection(1, row, column)
				print("Row: "..row.."\nColumn: "..column)
				-- local a = (row - 1) * 4 + column
				break
			end
		end
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
			icons[(row - 1) * 4 + column]:draw(x + 6, y + 6)
			-- gfx.drawTextInRect("*"..options[row].."*", x, y + (height/2) - 5 + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			nsBlank:drawInRect(x, y, width, height)
			icons[(row - 1) * 4 + column]:draw(x + 6, y + 6)
			-- gfx.drawTextInRect(options[row], x, y + (height/2) - 5, width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:add()
	self.bActive = true
end

local movingSound = pd.sound.sampleplayer.new("sounds/ChangingSelection")
local decisionSound = pd.sound.sampleplayer.new("sounds/SelectionMade")

function AbilityMenu:update()
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
			print("Row: "..row.."\nColumn: "..column)
			if self.abilities[(row - 1) * 4 + column].func then
				self.gameManager.player.bActive = true
				self.gameManager.PlayerData.activeAbility = self.abilities[(row - 1) * 4 + column]
				self:remove()
			else
				-- TODO: PLAY ERROR SOUND
			end
		elseif pd.buttonJustReleased(pd.kButtonB) then
			self.gameManager.player.bActive = true
			self:remove()
		end
	end


	-- if #self.options == 2 then
	-- 	self.grid:drawInRect(0, 0, 235 - 60, 240 - 60)
	-- else
	-- local gridImage = gfx.image.new(385, 178)
	gfx.lockFocus(self:getImage())
	local GridWidth = 48 * 4 + 10
	local GridHeight = 48 * 2 + 10
	self.grid:drawInRect((GridWidth / 2), (GridHeight / 2) + 30, GridWidth, GridHeight)
	gfx.unlockFocus()
	-- gridImage:drawIgnoringOffset(32, 48)
	-- end

	gfx.setColor(gfx.kColorBlack)
end
