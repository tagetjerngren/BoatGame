local pd <const> = playdate
local gfx <const> = playdate.graphics

class('TextBox').extends(gfx.sprite)

function TextBox:init(message, padding, callback, heightOffset, zIndex)
	if SceneManager then
		SceneManager.player.bActive = false
		SceneManager.water.bActive = false
	end
	self.callback = callback

	self.width, self.height = gfx.getTextSize(message)
	local MaxTextWidth = 365
	if self.width > MaxTextWidth then
		-- NOTE: This works but will only ever split it in two, and if the message is too long for that then this one won't do
		-- message = message:sub(1, #message//2) .. message:sub(#message//2 + 1, #message):gsub(" ", "\n", 1)
		-- self.width, self.height = gfx.getTextSize(message)

		local numberOfLines = math.ceil(self.width/MaxTextWidth)
		local newMessage = message:sub(1, #message//numberOfLines)
		for i = 2, numberOfLines do
			newMessage = newMessage .. message:sub(#message//numberOfLines * (i - 1) + 1, #message/numberOfLines * i):gsub(" ", "\n", 1)
			-- print("Does "..#message.." equal "..#message/numberOfLines * i.."?")
		end
		-- print(newMessage)

		message = newMessage
		self.width, self.height = gfx.getTextSize(message)
	end
	-- print("message length "..#message)
	-- print("width is "..self.width)
	local sprite = gfx.image.new(self.width + 2 * padding + 20, self.height + 2 * padding + 20)
	local sprite2

	if zIndex then
		self:setZIndex(zIndex)
	else
		self:setZIndex(100)
	end
	self:setIgnoresDrawOffset(true)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/WallResizable", 5, 5, 6, 6)
	ns:drawInRect(0, 0, self.width + 2*padding, self.height + 2*padding)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextAligned(message, self.width / 2 + padding, padding, kTextAlignment.center)
	gfx.unlockFocus()
	sprite2 = sprite:copy()

	-- DRAW BUTTON UP ON FIRST SPRITE
	gfx.lockFocus(sprite)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 17, 12)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 17, 10)
	gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	gfx.drawTextAligned('*A*', self.width + 17, self.height + 8, kTextAlignment.center)
	gfx.unlockFocus()

	-- DRAW BUTTON DOWN ON SECOND SPRITE
	gfx.lockFocus(sprite2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 19, 12)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(self.width + 17, self.height + 19, 10)
	gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	gfx.drawTextAligned('*A*', self.width + 17, self.height + 10, kTextAlignment.center)
	gfx.unlockFocus()

	self.timer = pd.timer.keyRepeatTimerWithDelay(400, 400, function ()
		if self:getImage() == sprite2 then
			self:setImage(sprite)
		else
			self:setImage(sprite2)
		end
	end)

	if heightOffset == nil then
		heightOffset = 0
	end
	self:moveTo(200, 120 + self.height / 2 + heightOffset)
	self:setImage(sprite)
	self:add()
end

function TextBox:update()
	if pd.buttonJustReleased(pd.kButtonA) then
		self.timer:remove()
		if SceneManager then
			SceneManager.player.bActive = true
			SceneManager.water.bActive = true
		end
		self:remove()
		if self.callback then
			self.callback()
		end
	end
end
