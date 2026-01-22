local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
import "scripts/Misc/saves"
import "scripts/Misc/water"
import "dummy_player"

class('MainMenu').extends(gfx.sprite)

function MainMenu:init()

	self:setImage(gfx.image.new(400, 240))
	-- self:setCenter(0, 0)
	self:moveTo(200, 120)

	if LoadGame() then
		self.options = {"Continue", "New Game"}
	else
		self.options = {"New Game"}
	end

	self.grid = pd.ui.gridview.new(150, 75)
	self.grid:setNumberOfColumns(1)
	self.grid:setNumberOfRows(#self.options)
	self.grid:setCellPadding(2, 2, 2, 2)
	-- self.grid.backgroundImage = gfx.nineSlice.new("images/gridBackground", 8, 8, 47, 47)
	self.grid:setContentInset(10, 10, 10, 10)

	local options = self.options
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	local nsBlank = gfx.nineSlice.new("images/OneWayDoor", 5, 5, 22, 22)
	function self.grid:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setColor(gfx.kColorBlack)
		if selected then
			ns:drawInRect(x, y, width, height)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.setColor(gfx.kColorWhite)
			gfx.drawTextInRect("*"..options[row].."*", x, y + (height/2) - 5 + 3 * math.sin(7 * pd.getElapsedTime()), width, height, nil, nil, kTextAlignment.center)
		else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
			nsBlank:drawInRect(x, y, width, height)
			gfx.drawTextInRect(options[row], x, y + (height/2) - 5, width, height, nil, nil, kTextAlignment.center)
		end
	end
	self:setZIndex(-1000)
	self:add()
	self.water = Water(180, 400, 150, 220, 0.2, 30)
	self.water.bActive = true

	local delay = 500
	local magnitude = 2
	local tm = pd.timer.performAfterDelay(delay, function ()
		self.water:Poke(math.random(0, 400), math.random(-magnitude, magnitude))
	end)
	tm.repeats = true

	self.player = DummyPlayer(270, 140, gfx.image.new("images/Boat"), 5)
	self.player:add()
end

local movingSound = pd.sound.sampleplayer.new("sounds/ChangingSelection")
local decisionSound = pd.sound.sampleplayer.new("sounds/SelectionMade")
local mainMenuTrack = pd.sound.fileplayer.new("sounds/songs/MainMenuLoop")
mainMenuTrack:play(0)


function MainMenu:update()
	if pd.buttonJustPressed(pd.kButtonDown) then
		self.grid:selectNextRow(false)
		movingSound:play()
	elseif pd.buttonJustPressed(pd.kButtonUp) then
		self.grid:selectPreviousRow(false)
		movingSound:play()
	elseif pd.buttonJustPressed(pd.kButtonA) then
		local _, row, column = self.grid:getSelection()
		self:remove()
		mainMenuTrack:stop()
		decisionSound:play()
		self.done = true
		self.loadGame = self.options[row] == "Continue"
	end

	if #self.options == 2 then
		self.grid:drawInRect(0, 0, 235 - 60, 240 - 60)
	else
		self.grid:drawInRect(0, 50, 235 - 60, 240 - 60 - 50)
	end

	local TitleImage = gfx.image.new(100, 100)
	gfx.pushContext(TitleImage)
	gfx.setColor(gfx.kColorWhite)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextInRect("*Stubbhorn*", 0, 0, 100, 100, nil, nil, kTextAlignment.center)
	gfx.popContext()
	TitleImage:drawScaled(180, 80 + 5 * math.sin(pd.getElapsedTime() * 3), 2)

	local buoyancyForces = CalculateBuoyancy(self.water:getHeight(self.player.PhysicsComponent.position.x), self.player.PhysicsComponent.position.y, 50, 0.3, 5.5, self.player.PhysicsComponent)
	self.player.PhysicsComponent:addForce(buoyancyForces)

	-- NOTE: Limits the player to the main menu range, disallowing them from going too far left or right
	self.player.PhysicsComponent.position.x = Clamp(self.player.PhysicsComponent.position.x, -32, 432)

	if pd.buttonJustPressed(pd.kButtonB) then
		self.water:Poke(math.random(0, 400), 10)
	end
	gfx.setColor(gfx.kColorBlack)
end
