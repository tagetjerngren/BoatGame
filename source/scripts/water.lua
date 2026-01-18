import "CoreLibs/crank"

import "scripts/utils"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends(gfx.sprite)

function Water:init(Height, Width, LowerBound, UpperBound, RateOfChange, DistanceBetweenParticles)
	self.bFirstCollection = true
	self.bOldSystem = true
	self.height = Height
	self.width = Width
	self.lowerBound = LowerBound
	self.upperBound = UpperBound
	self.rateOfChange = RateOfChange
	self.bActive = false

	self.pointPositions = {}
	self.pointVelocity = {}
	self.pointAcceleration = {}

	self.distanceBetweenParticles = DistanceBetweenParticles

	for i = 1, self.width / DistanceBetweenParticles + 2 do
		table.insert(self.pointPositions, {(i - 1) * DistanceBetweenParticles, self.height})
		table.insert(self.pointVelocity, {0, 0})
		table.insert(self.pointAcceleration, {0, 0})
	end

	self.waterImage = gfx.image.new(400, 400)
	gfx.pushContext(self.waterImage)
		gfx.setColor(gfx.kColorWhite)
	-- TODO: MAKE THIS THE SHAPE OF THE WATER INSTEAD OF JUST A RECT
		gfx.fillRect(0, 0, self.width, 240)
	gfx.popContext()

	local ditherMask = self.waterImage:getMaskImage():copy()

	gfx.pushContext(ditherMask)
		gfx.setColor(gfx.kColorBlack)
		gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
		gfx.fillRect(0, 0, ditherMask:getSize())
	gfx.popContext()

	self.waterImage:setMaskImage(ditherMask)

	self:add()
end

function Water:SetHeight(newHeight)
	self.height = newHeight

	for i = 1, #self.pointPositions do
		self.pointPositions[i][2] = newHeight
	end
end

function Water:SetWidth(newWidth)
	self.width = newWidth

	self.pointPositions = {}
	self.pointVelocity = {}
	self.pointAcceleration = {}

	-- NOTE: This +2 thing is just so that I have enough points to cover the width of the map
	-- It should probably not be this way, but +1 probably makes since since lua is 1-indexed
	for i = 1, self.width / self.distanceBetweenParticles + 2 do
		table.insert(self.pointPositions, {(i - 1) * self.distanceBetweenParticles, self.height})
		table.insert(self.pointVelocity, {0, 0})
		table.insert(self.pointAcceleration, {0, 0})
	end
end

function Water:UpdateWaves()
	for i = 1, #self.pointPositions do
		self.pointVelocity[i][1] += self.pointAcceleration[i][1]
		self.pointVelocity[i][2] += self.pointAcceleration[i][2]

		self.pointPositions[i][1] += self.pointVelocity[i][1]
		self.pointPositions[i][2] += self.pointVelocity[i][2]

		self.pointAcceleration[i][1] = 0
		self.pointAcceleration[i][2] = 0
	end
end

function Water:getHeight(x)
	local distBetweenPoints = self.width / #self.pointPositions -- 20 / 4 = 5
	local affectedIndex = x / distBetweenPoints -- 15 / 5 = 3

	-- NOTE: BECAUSE LUA DOES ONE INDEXING
	affectedIndex += 1

	local lowerAffected = math.floor(affectedIndex)
	local higherAffected = math.ceil(affectedIndex)

	-- NOTE: Tough to explain for me but if the x is between two points then both have to have a force applied to them, this number represents
	-- what percentage of the force each point should have.
	local diffRatio = affectedIndex - lowerAffected

	lowerAffected = Clamp(lowerAffected, 1, #self.pointPositions)
	higherAffected = Clamp(higherAffected, 1, #self.pointPositions)
	affectedIndex = Clamp(affectedIndex, 1, #self.pointPositions)

	if lowerAffected ~= higherAffected then
		return self.pointPositions[lowerAffected][2] + (self.pointPositions[higherAffected][2] - self.pointPositions[lowerAffected][2]) * diffRatio
	else
		return self.pointPositions[affectedIndex][2]
	end
end

function Water:Poke(xPoint, yForce)
	local distBetweenPoints = self.width / #self.pointPositions
	local affectedIndex = xPoint / distBetweenPoints

	-- NOTE: BECAUSE LUA DOES ONE INDEXING
	affectedIndex += 1

	local lowerAffected = math.floor(affectedIndex)
	local higherAffected = math.ceil(affectedIndex)

	-- NOTE: Tough to explain for me but if the x is between two points then both have to have a force applied to them, this number represents
	-- what percentage of the force each point should have.
	local diffRatio = affectedIndex - lowerAffected

	if lowerAffected > #self.pointPositions then
		lowerAffected = #self.pointPositions
	end
	if higherAffected > #self.pointPositions then
		higherAffected = #self.pointPositions
	end
	if affectedIndex > #self.pointPositions then
		affectedIndex = #self.pointPositions
	end

	if lowerAffected ~= higherAffected then
		self.pointAcceleration[lowerAffected][2] += yForce * diffRatio
		self.pointAcceleration[higherAffected][2] += yForce * (1 - diffRatio)
	else
		self.pointAcceleration[affectedIndex][2] += yForce
	end
end

function Water:Spring()
	local minimizeRatio = 0.1
	local dampingConstant = 0.01
	-- Force that brings it back to the desired height
	for i = 1, #self.pointPositions do
		self.pointAcceleration[i][2] += (self.height - self.pointPositions[i][2]) * minimizeRatio - dampingConstant * self.pointVelocity[i][2]
	end

	-- Force that affects points based on their neighbors
	for i = 1, #self.pointPositions do
		local leftPoint = i - 1
		local rightPoint = i + 1

		if leftPoint >= 1 then
			self.pointAcceleration[i][2] += (self.pointPositions[leftPoint][2] - self.pointPositions[i][2]) * minimizeRatio - dampingConstant * self.pointVelocity[i][2]
		end

		if rightPoint <= #self.pointPositions then
			self.pointAcceleration[i][2] += (self.pointPositions[rightPoint][2] - self.pointPositions[i][2]) * minimizeRatio - dampingConstant * self.pointVelocity[i][2]
		end
	end
end

function Water:update()
	if self.bActive then
		if self.bOldSystem then
			local change, _ = pd.getCrankChange()
			local oldHeight = self.height
			self.height -= change * self.rateOfChange
			self.height = Clamp(self.height, self.lowerBound, self.upperBound)
			local changeInHeight = self.height - oldHeight
			for i = 1, #self.pointPositions do
				self.pointPositions[i][2] += changeInHeight
			end
		else
			local change = 0
			local CrankPosition = pd.getCrankPosition()
			if 5 < CrankPosition and CrankPosition < 180 then
				change = CrankPosition - 5
			elseif 180 < CrankPosition and CrankPosition < 355 then
				change = -(355 - CrankPosition)
			end
			change *= 0.6

			local oldHeight = self.height
			self.height -= change * self.rateOfChange
			self.height = Clamp(self.height, self.lowerBound, self.upperBound)
			local changeInHeight = self.height - oldHeight
			for i = 1, #self.pointPositions do
				self.pointPositions[i][2] += changeInHeight
			end
		end
	end

	if pd.buttonIsPressed(pd.kButtonB) then
		self:Poke(40, 1)
	end
	if pd.buttonIsPressed(pd.kButtonA) then
		self:Poke(40, -1)
	end
	self:Spring()
	self:UpdateWaves()

	gfx.setColor(gfx.kColorWhite)
	for i = 1, #self.pointPositions - 1 do
		-- gfx.drawCircleAtPoint(self.pointPositions[i][1], self.pointPositions[i][2], 3)
		gfx.drawLine(self.pointPositions[i][1], self.pointPositions[i][2], self.pointPositions[i + 1][1], self.pointPositions[i + 1][2])
		gfx.drawLine(self.pointPositions[i][1], self.pointPositions[i][2] + 1, self.pointPositions[i + 1][1], self.pointPositions[i + 1][2] + 1)
	end

	local _, yOffset = gfx.getDrawOffset()
	self.waterImage:drawIgnoringOffset(0, self.height + yOffset)
end
