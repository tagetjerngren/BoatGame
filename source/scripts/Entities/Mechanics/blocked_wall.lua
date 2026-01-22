local pd <const> = playdate
local gfx <const> = pd.graphics

class('BlockedWall').extends(gfx.sprite)

function BlockedWall:init(x, y, entity)
	self.entity = entity
	local sprite = gfx.image.new(self.entity.size.width, self.entity.size.height)
	gfx.lockFocus(sprite)
	local ns = gfx.nineSlice.new("images/BlockedWallBorder", 9, 9, 13, 13)
	ns:drawInRect(0, 0, self.entity.size.width, self.entity.size.height)
	local coinImage = gfx.image.new("images/Coin")
	local cWidth, cHeight = coinImage:getSize()
	coinImage:draw(self.entity.size.width / 2 - cWidth / 2 + 1, self.entity.size.height / 2 - cHeight / 2 + 1)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.drawTextInRect(tostring(self.entity.fields.Cost), 0, self.entity.size.height / 2 + 16, self.entity.size.width, self.entity.size.height, nil, nil, kTextAlignment.center)
	gfx.unlockFocus()
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self:setImage(sprite)
	self:setCollideRect(0, 0, self.entity.size.width, self.entity.size.height)
	self:setGroups(COLLISION_GROUPS.WALL)
	self:setCollidesWithGroups(COLLISION_GROUPS.PLAYER)
	self:add()
end


function BlockedWall:clear(player)
	if player.coins >= self.entity.fields.Cost then
		OptionBox("Delete block for "..self.entity.fields.Cost.."g", {"Yes ("..self.entity.fields.Cost..")", "No"}, function (index, option)
			if index == 1 then
				player.coins -= self.entity.fields.Cost
				self.entity.fields.Cleared = true
				player.GameManager:collect(self.entity.iid)
				self:remove()
			end
		end)
		return false
	else
		TextBox("Insufficient funds, needs "..self.entity.fields.Cost, 10)
		return false
	end
end
