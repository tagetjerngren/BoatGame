local pd <const> = playdate
local gfx <const> = pd.graphics

import "CoreLibs/nineslice"
import "scripts/Misc/saves"
import "scripts/UIElements/text_box"

class('Intro').extends(gfx.sprite)

function Intro:init()
	self:setImage(gfx.image.new(400, 240))
	self:moveTo(200, 120)
	self:setZIndex(10)

	self.introTrack = pd.sound.fileplayer.new("sounds/songs/HeavyIntro")
	self.introTrack:play(0)
	self.decisionSound = pd.sound.sampleplayer.new("sounds/SelectionMade")

	local planetSpaceImage = gfx.image.new("images/PlanetAmongStars")
	local allBlackImage = gfx.image.new(400, 240)
	gfx.lockFocus(allBlackImage)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 400, 240)
	gfx.unlockFocus()
	local planetSurfaceImage = gfx.image.new("images/PlanetSurface")

	self.slideShow = {	{planetSpaceImage, {"", "In the year 202X, a rogue planet\nsuddenly appears in the solar system", "The Planet's sudden appearance\ndemanded our curiosity"}, 50},
						{allBlackImage, {"It was no larger than the moon,\nbut the interloper had a secret..."}, 0},
						{planetSurfaceImage, {"The planet was coated\nin oceans and mountains", "An environment\nplenty suitable for life"}, 50},
						{allBlackImage, {"So we created you, a rover that can maneuver\nthese oceans and collect samples for us", "We call you Brave,\nwe believe in you, don't let us down"}, 0}}
	self.currentSlide = 1
	self.currentString = 1

	self:updateImage()
	TextBox(self.slideShow[self.currentSlide][2][self.currentString], 10, function ()
		self:next()
	end, self.slideShow[self.currentSlide][3])

	self:add()
end

function Intro:updateImage()
	gfx.lockFocus(self:getImage())
	self.slideShow[self.currentSlide][1]:draw(0, 0)
	gfx.unlockFocus()
end

function Intro:next()
	-- If there are more strings go to that
	if self.currentString < #self.slideShow[self.currentSlide][2] then
		self.currentString += 1
	elseif self.currentSlide < #self.slideShow then
		self.currentSlide += 1
		self.currentString = 1
	else
		self.done = true
		self.introTrack:stop()
	end

	self:updateImage()
	TextBox(self.slideShow[self.currentSlide][2][self.currentString], 10, function ()
		self:next()
	end, self.slideShow[self.currentSlide][3])
end
