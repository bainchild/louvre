local love = require("love")
local utf8 = require("utf8")
-- require("love.filesystem")
do
	local rfs = lovr.filesystem
	local fs = {}
	-- newFile
	-- setSymlinksEnabled
	-- areSymlinksEnabled
	-- newFileData
	-- isSymlink
	-- lines
	-- getInfo
	function fs.exists(path)
		return rfs.isFile(path) or rfs.isDirectory(path)
	end
	function fs._setAndroidSaveExternal()end
	function fs.setSource()end
	function fs.setFused()end
	function fs.init()end
	fs.getCRequirePath = rfs.getRequirePath
	fs.setCRequirePath = rfs.setRequirePath
	fs.getSourceBaseDirectory = rfs.getSource
	for i,v in next, {
		"load";
		"getAppdataDirectory";
		"getLastModified";
		"isFile";
		"setIdentity";
		"append";
		"createDirectory";
		"getSource";
		"isFused";
		"getExecutablePath";
		"getIdentity";
		"getRealDirectory";
		"getRequirePath";
		"getSaveDirectory";
		"getSize";
		"getUserDirectory";
		"getWorkingDirectory";
		"isDirectory";
		"mount";
		"remove";
		"setRequirePath";
		"unmount";
		"getDirectoryItems";
		"read";
		"write";
	} do
		fs[v] = rfs[v]
	end
	love.filesystem = fs
end
for k,v in ipairs{
	"data",
	"thread",
	"timer",
	"event",
	"keyboard",
	"joystick",
	"mouse",
	"touch",
	"sound",
	"system",
	"audio",
	"image",
	"video",
	"font",
	"window",
	"graphics",
	"math",
	"physics",
} do
	require("love." .. v)
end
love.timer = lovr.timer
love.window.setMode(800,600)
-- require("love.boot")()
-- for i,v in next, love.graphics.getCanvasFormats() do
-- 	print("canvas format",i,v)
-- end
-- custom functions I added
-- love.graphics.setCreated(true)
-- love.graphics.setActive(true)
--
love.handlers = lovr.handlers
function love.run()
end
function love.threaderror(t, err)
	error("Thread error ("..tostring(t)..")\n\n"..err, 0)
end
local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
function love.errhand(msg)
	msg = tostring(msg)
	error_printer(msg, 2)
	if not love.window or not love.graphics or not love.event then
		return
	end
	-- if not love.graphics.isCreated() or not love.window.isOpen() then
	-- 	local success, status = pcall(love.window.setMode, 800, 600)
	-- 	if not success or not status then
	-- 		return
	-- 	end
	-- end
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(14)
	love.graphics.setColor(1, 1, 1)
	local trace = debug.traceback()
	love.graphics.origin()
	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)
	local err = {}
	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)
	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end
	table.insert(err, "\n")
	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
	local p = table.concat(err, "\n")
	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")
	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end
	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end
	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end
	return function()
		love.event.pump()
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			-- elseif e == "touchpressed" then
			-- 	local name = love.window.getTitle()
			-- 	if #name == 0 or name == "Untitled" then name = "Game" end
			-- 	local buttons = {"OK", "Cancel"}
			-- 	if love.system then
			-- 		buttons[3] = "Copy to clipboard"
			-- 	end
			-- 	local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
			-- 	if pressed == 1 then
			-- 		return 1
			-- 	elseif pressed == 3 then
			-- 		copyToClipboard()
			-- 	end
			end
		end
		draw()
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end
local orig_setcanvas = love.graphics.setCanvas
local orig_getcanvas = love.graphics.getCanvas
function lovr.run()
	if lovr.timer then lovr.timer.step() end
	if lovr.load then lovr.load(arg) end
	local curcanv = orig_getcanvas()
	orig_setcanvas()
	if love.load then love.load(arg) end
	orig_setcanvas(curcanv)
	local dt = 0
	return function()
		if lovr.system then lovr.system.pollEvents() end
		if lovr.event then
			for name, a, b, c, d in lovr.event.poll() do
				if name == 'restart' then
					local cookie = lovr.restart and lovr.restart()
					return 'restart', cookie
				elseif name == 'quit' and (not lovr.quit or not lovr.quit(a)) then
					if love.quit then love.quit() end
					return a or 0
				end
				if lovr.handlers[name] then lovr.handlers[name](a, b, c, d) end
			end
		end
		local curcanv = orig_getcanvas()
		orig_setcanvas()
		if love.event then
			love.event.pump()
			for name, a, b, c, d in love.event.poll() do
				if name == 'quit' then
					lovr.event.push("quit",a)
				end
				if love.handlers[name] then love.handlers[name](a, b, c, d) end
			end
		end
		orig_setcanvas(curcanv)
		local dt = 0
		if lovr.timer then dt = lovr.timer.step() end
		if lovr.headset then dt = lovr.headset.update() end
		if lovr.update then lovr.update(dt) end
		if love.update then love.update(dt) end
		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())
			if love.draw then love.draw() end
			love.graphics.present()
		end
		if lovr.graphics then
			local headset = lovr.headset and lovr.headset.getPass()
			if headset and (not lovr.draw or lovr.draw(headset)) then headset = nil end
			local window = lovr.graphics.getWindowPass()
			if window and (not lovr.mirror or lovr.mirror(window)) then window = nil end
			lovr.graphics.submit(headset, window)
			lovr.graphics.present()
		end
		if lovr.headset then lovr.headset.submit() end
		if lovr.math then lovr.math.drain() end
	end
end
local love_canvas,love_texture = love.graphics.newCanvas(800,600),lovr.graphics.newTexture(800,600,{usage={"transfer","render","sample"},label="love2d-canvas"})
-- love.window.close()
orig_setcanvas(love_canvas)
function love.graphics.setCanvas(canvas)
	if rawequal(canvas,nil) then
		orig_setcanvas(love_canvas)
	else
		orig_setcanvas(canvas)
	end
end
function love.graphics.getCanvas()
	local canvas = orig_getcanvas()
	if rawequal(canvas,nil) then
		return nil
	else
		return res
	end
end
function love.graphics.present()
	-- THIS is the bottleneck
   local canv = orig_getcanvas()
   orig_setcanvas()
   local width,height = canv:getDimensions()
   local img = canv:newImageData()
   local img2 = lovr.data.newImage(canv:getDimensions())
   for x=0,width-1 do
      for y=0,height-1 do
         img2:setPixel(x,y,img:getPixel(x,y))
      end
   end
	love_texture = lovr.graphics.newTexture(img2,{usage={"transfer","render","sample"},label="love2d-canvas"})
   orig_setcanvas(canv)
end
function love.init()
   local c = {
      identity = false;
      appendidentity = false;
      version = love._version;
      console = false;
      accelerometerjoystick = true;
      externalstorage = false;
      gammacorrect = false;
      audio={
         mic = false;
         mixwithsystem = true;
      };
      window={
         title = "LOVEtas";
         icon = nil;
         width = 800;
         height = 600;
         borderless = false;
         resizable = false;
         minwidth = 1;
         minheight = 1;
         fullscreen = false;
         fullscreentype = "desktop";
         vsync = 1;
         msaa = 0;
         depth = nil;
         stencil = nil;
         display = 1;
         highdpi = false;
         usedpiscale = true;
         x = nil;
         y = nil;
      };
      modules={
         audio = true;
         data = true;
         event = true;
         font = true;
         graphics = true;
         image = true;
         joystick = true;
         keyboard = true;
         math = true;
         mouse = true;
         physics = true;
         sound = true;
         system = true;
         thread = true;
         timer = true;
         touch = true;
         video = true;
         window = true;
      }
   }
   if love.conf then love.conf(c) end
	c.version = tostring(c.version)
	if not love.isVersionCompatible(c.version) then
		local major, minor, revision = c.version:match("^(%d+)%.(%d+)%.(%d+)$")
		if (not major or not minor or not revision) or (major ~= love._version_major and minor ~= love._version_minor) then
			local msg = ("This game indicates it was made for version '%s' of LOVE.\n"..
				"It may not be compatible with the running version (%s)."):format(c.version, love._version)

			print(msg)

			if love.window then
				love.window.showMessageBox("Compatibility Warning", msg, "warning")
			end
		end
	end
   if c.window and c.modules.window then
		love.window.setTitle(c.window.title or c.title)
		local pcanv = orig_getcanvas()
		orig_setcanvas()
		assert(love.window.setMode(c.window.width, c.window.height,
		{
			fullscreen = c.window.fullscreen,
			fullscreentype = c.window.fullscreentype,
			vsync = c.window.vsync,
			msaa = c.window.msaa,
			stencil = c.window.stencil,
			depth = c.window.depth,
			resizable = c.window.resizable,
			minwidth = c.window.minwidth,
			minheight = c.window.minheight,
			borderless = c.window.borderless,
			centered = c.window.centered,
			display = c.window.display,
			highdpi = c.window.highdpi,
			usedpiscale = c.window.usedpiscale,
			x = c.window.x,
			y = c.window.y,
		}), "Could not set window mode")
		if c.window.icon then
			-- assert(love.image, "If an icon is set in love.conf, love.image must be loaded!")
			if love.image and love.window then
			   love.window.setIcon(love.image.newImageData(c.window.icon))
			end
		end
		orig_setcanvas(orig)
	end
end
function love.load_project(path,unload)
	if unload then
		(love.filesystem.unmountFullPath or love.filesystem.unmount)(love.filesystem.getSource())
	end
	local file
	do
	   local err = not (love.filesystem.mountFullPath or love.filesystem.mount)(path, "")
	   if err then
	      error("Error mounting directory/zip",2)
	   end
	   file,err = love.filesystem.load("main.lua")
	   if file==nil then
	      error("Error loading file: "..tostring(err),2)
	   end
	end
	if love.filesystem.exists("conf.lua") then
	   local file2,err = love.filesystem.load("conf.lua")
	   if file==nil then
	      error("Error loading conf.lua: "..tostring(err),2)
	   end
	   print(pcall(file2,love.errhand))
	   love.init()
	end
	print(pcall(file,love.errhand))
end
return {
   get_texture=function() return love_texture end,
   canvas=love_canvas,
   love=love
}
