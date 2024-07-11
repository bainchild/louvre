local prelude = require("prelude")
local love,get_texture = prelude.love,prelude.get_texture
-- function love.load()
-- end
-- function love.update()
-- end
-- function love.draw()
-- 	love.graphics.setBackgroundColor(1,1,1,1)
-- 	love.graphics.setColor(0,0,0,1)
-- 	love.graphics.print("Hello louvre!!",50,50)
-- 	love.graphics.rectangle("fill",60,60,80,80)
-- end
do
	local s,r = pcall(love.load_project,"picolove.love")
	if not s then
		print(r)
		require("love.nogame")()
	end
end
function lovr.load()
end
function lovr.update(dt)
end
function lovr.draw(pass)
	pass:cube(0,-10,-10,3)
	pass:setMaterial(get_texture())
	pass:plane(0,0,-10,8,6)
end
