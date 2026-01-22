local pd <const> = playdate
local gfx <const> = pd.graphics

class('SpikeRailPoint').extends(gfx.sprite)

function SpikeRailPoint:init(x, y)
	self:moveTo(x + 8, y + 8)
	self:setImage(gfx.image.new("images/SpikePathPoint"))
	self:setZIndex(-10)
	self:add()
end
