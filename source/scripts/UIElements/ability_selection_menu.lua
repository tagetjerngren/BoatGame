local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
import "scripts/Misc/abilities"

class('AbilitySelectionMenu').extends(gfx.sprite)

function AbilitySelectionMenu:init(player, entity)
	self.fields = entity.fields
	self.upgrades = self.fields.Abilities

	if self.fields.AbilityType == "AButton" then
		self.func = player.setAbilityA
	elseif self.fields.AbilityType == "BButton" then
		self.func = player.setAbilityB
	elseif self.fields.AbilityType == "Passive" then
		self.func = player.setPassive
	end
	self:setImage(gfx.image.new(400 - 60, 240 - 60))
	self:setCenter(0, 0)

	self.grid = pd.ui.gridview.new((400 - 60 - 20 - 4 * #self.upgrades)/#self.upgrades, 156)
	self.grid:setNumberOfColumns(#self.upgrades)
	self.grid:setNumberOfRows(1)
	self.grid:setCellPadding(2, 2, 2, 2)
	self.grid.backgroundImage = gfx.nineSlice.new("images/gridBackground", 8, 8, 47, 47)
	self.grid:setContentInset(10, 10, 10, 10)
	local upgrades = self.upgrades
	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.fillRect(x, y, width, height)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawTextInRect(upgrades[column], x, y + (height/2) + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			gfx.drawRect(x, y, width, height)
			gfx.drawTextInRect(upgrades[column], x, y + (height/2), width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:setZIndex(10)
	self:add()
	self.player = player
end

function AbilitySelectionMenu:update()
	if pd.buttonJustPressed(pd.kButtonRight) then
		self.grid:selectNextColumn(false)
	elseif pd.buttonJustPressed(pd.kButtonLeft) then
		self.grid:selectPreviousColumn(false)
	elseif pd.buttonJustPressed(pd.kButtonA) then
		local _, _, column = self.grid:getSelection()
		self.func(self.player, Abilities[self.upgrades[column]], self.upgrades[column])
		self.player.bActive = true
		self:remove()
	end
	local offsetX, offsetY = gfx.getDrawOffset()
	self:moveTo(30 - offsetX, 30 - offsetY)

	gfx.lockFocus(self:getImage())
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, 400 - 60, 240 - 60)
	self.grid:drawInRect(0, 0, 400 - 60, 240 - 60)
	-- self.grid:drawInRect(30 - offsetX, 30 - offsetY, 400 - 60, 240 - 60)
	gfx.unlockFocus()
end
