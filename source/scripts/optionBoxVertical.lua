local pd <const> = playdate
local gfx <const> = pd.graphics

import "scripts/abilities"
import "CoreLibs/nineslice"

class('OptionBoxVertical').extends(gfx.sprite)

function OptionBoxVertical:init(prompt, options, callback)
	SceneManager.player.bActive = false
	SceneManager.water.bActive = false

	self:setIgnoresDrawOffset(true)
	self:moveTo(200, 120)

	local promptWidth, promptHeight = gfx.getTextSize(prompt)

	local widthOfLongestString, heightOfLongestString = gfx.getTextSize(options[1])
	for i = 2, #options do
		local width, height = gfx.getTextSize(options[i])

		if width > widthOfLongestString then
			widthOfLongestString = width
		end

		if height > widthOfLongestString then
			widthOfLongestString = height
		end
	end

	local cellPadding = 2
	local contentInset = 10

	self.gridWidth = math.max((cellPadding * 2 + contentInset * 2 + (widthOfLongestString + 30)), promptWidth)
	self.gridHeight = (cellPadding * 2 + contentInset * 2 + heightOfLongestString) + promptHeight * 1.7 * #options
	self.gridWidth = Clamp(self.gridWidth, 200, 360)
	self.gridHeight = Clamp(self.gridHeight, 100, 180)

	self.options = options
	self.prompt = prompt
	self.callback = callback

	self:setImage(gfx.image.new(self.gridWidth, self.gridHeight))

	-- NOTE: This is the size of each cell
	local CellWidth = (self.gridWidth - contentInset * 2 - cellPadding * 2)
	local CellHeight = (self.gridHeight - contentInset * 2 - (promptHeight + 15) - cellPadding * 2 * #options)/#options
	CellHeight = math.max(CellHeight, 32)
	self.grid = pd.ui.gridview.new(CellWidth, CellHeight)

	self.grid:setNumberOfColumns(1)
	self.grid:setNumberOfRows(#options)
	self.grid:setCellPadding(cellPadding, cellPadding, cellPadding, cellPadding)
	self.grid:setContentInset(contentInset, contentInset, contentInset + promptHeight + 15, contentInset)

	self.grid.backgroundImage = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)

	local option = options
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	local nsBlank = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)

	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			nsBlank:drawInRect(x, y, width, height)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawTextInRect(option[row], x, y + (height/2) - 10 + 2 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			ns:drawInRect(x, y, width, height)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.drawTextInRect(option[row], x, y + (height/2) - 10, width, height, nil, nil, kTextAlignment.center)
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		end
	end
	self:setZIndex(1000)
	self:add()
end

function OptionBoxVertical:update()
	if pd.buttonJustPressed(pd.kButtonUp) then
		self.grid:selectPreviousRow(true)
	elseif pd.buttonJustPressed(pd.kButtonDown) then
		self.grid:selectNextRow(true)
	elseif pd.buttonJustReleased(pd.kButtonA) then
		local _, row, _ = self.grid:getSelection()
		SceneManager.player.bActive = true
		SceneManager.water.bActive = true
		self:remove()
		self.selection = row
		self.callback(self.selection, self.options[row])
	end

	gfx.lockFocus(self:getImage())
	self.grid:drawInRect(0, 0, self.gridWidth, self.gridHeight)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned(self.prompt, (self.gridWidth)/2, 20, kTextAlignment.center)
	-- self.grid:drawInRect(30 - offsetX, 30 - offsetY, 400 - 60, 240 - 60)
	gfx.unlockFocus()
end
