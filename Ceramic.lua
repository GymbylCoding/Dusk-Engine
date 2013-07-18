--[[
Ceramic Tile Engine

An open-source, easy to use, fast tile engine for Corona SDK.

Written by Caleb Place of Gymbyl Coding and Michael Wilson of No. 2 Games

www.no2games.org
www.gymbyl.com
--]]

local Ceramic={}

-- Localize
local json					= require("json")
local tabLevel			= 0
local assert				= assert
local pairs					= pairs
local type					= type
local getmetatable	= getmetatable
local setmetatable	= setmetatable
local tonumber			= tonumber
local tostring			= tostring
local newImageSheet	= graphics.newImageSheet
local newGroup			= display.newGroup
local newLine				= display.newLine
local newSprite			= display.newSprite
local remove				= display.remove
local newCircle			= display.newCircle
local newRect				= display.newRect
local newImage			= display.newImage
local math_min			= math.min
local math_floor		= math.floor
local math_ceil			= math.ceil
local table_insert	= table.insert
local ellipseShape	= {-181, -181, 0, -256, 181, -181, 256, 0, 181, 181, 0, 256, -181, 181, -256, 0}
local ellipseSize		= 512 -- Width/height of shape created with ellipseShape
local physicsData		= {["density"]=true,["friction"]=true,["bounce"]=true,["radius"]=true,["shape"]=true} -- All possible physics parameters to add to physics table if existent - do not edit!
local addBody
if physics then addBody=physics.addBody else addBody=function() print("physics.addBody failed: the physics library was not found on Ceramic startup. Make sure that you are loading physics before loading Ceramic.") end end

--------------------------------------------------------------------------------
-- Miscellaneous Functions
--------------------------------------------------------------------------------
local function multiply(t, m1, m2) local nt={} for i=1, #t, 2 do nt[i]=t[i]*m1 nt[i+1]=t[i+1]*m2 end return nt end
local function strRight(str,pattern) local s,e=str:find(pattern) local ret if e then ret=str:sub(e+1) return ret~="" and ret or nil end return nil end
local function isNumeric(str) return tonumber(str) and true or false  end
local function getCenterPointOfPoints(points) local pointsSum={x=0, y=0} for i=1, #points do pointsSum.x=pointsSum.x+points[i].x; pointsSum.y=pointsSum.y+points[i].y end return {x=pointsSum.x/#points, y=pointsSum.y/#points} end
local function getIsLess(a, b) local center=pointsCenterPoint if a.x>=0 and b.x<0 then return true elseif a.x==0 and b.x==0 then return a.y>b.y end local det=(a.x-center.x)*(b.y-center.y)-(b.x-center.x)*(a.y-center.y) if det<0 then return true elseif det > 0 then return false end local d1=(a.x-center.x)*(a.x-center.x)+(a.y-center.y)*(a.y-center.y) local d2=(b.x-center.x)*(b.x-center.x)+(b.y-center.y)*(b.y-center.y) return d1>d2 end
local function sortPointsClockwise(points) local centerPoint=getCenterPointOfPoints(points) table.sort(points, getIsLess) return points end
local function saveTable(t, filename) local path=system.pathForFile(filename, system.DocumentsDirectory) local file=io.open(path, "w") if file then local contents=json.encode(t) file:write(contents) io.close(file) return true else return false end end
local function getFile(filename, base) if not base then base=system.ResourceDirectory; end local path=system.pathForFile(filename, base) local contents local file=io.open(path, "r") if file then contents=file:read("*a") io.close(file) end return contents end
local function loadTilesets(data) local data=data local tilesets=data.tilesets local tileRef={} local tileStack={} tileStack.n=1 for i=1, #tilesets do tileStack[tileStack.n]={} tileStack[tileStack.n].tilewidth=tilesets[i].tilewidth tileStack[tileStack.n].tileheight=tilesets[i].tileheight tileStack[tileStack.n].image=tilesets[i].image tileStack[tileStack.n].imagewidth=tilesets[i].imagewidth tileStack[tileStack.n].imageheight=tilesets[i].imageheight tileStack[tileStack.n].numCol=math.floor(tileStack[tileStack.n].imagewidth/tileStack[tileStack.n].tilewidth) tileStack[tileStack.n].numRow=math.floor(tileStack[tileStack.n].imageheight/tileStack[tileStack.n].tileheight) tileStack[tileStack.n].numFrames=tileStack[tileStack.n].numCol*tileStack[tileStack.n].numRow tileStack[tileStack.n].sheet=graphics.newImageSheet(tileStack[tileStack.n].image, {width=tileStack[tileStack.n].tilewidth, height=tileStack[tileStack.n].tileheight, numFrames=tileStack[tileStack.n].numFrames}) for l=1, tileStack[tileStack.n].numFrames do tileRef[#tileRef+1]={tileset=tilesets[i], sheet=tileStack[tileStack.n].sheet, frame=l, data={start=1, count=tileStack[tileStack.n].numFrames}} end tileStack.n=tileStack.n+1 end return tileStack, tileRef end
local function tprint(t) if Ceramic.showPrints then local t=t or " " local message="" for i=1, tabLevel do message=message.."  " end message=message..t print(message) end end
local function clamp(v, l, h) if v<l then return l elseif v>h then return h else return v end end
local function convertProperties(p) local tileProperties={physics={}, tile={}, layer={}} for k, v in pairs(p) do if v=="true" or v=="false" then v=(v=="true" and true) or false elseif isNumeric(v) then v=tonumber(v) end local ref=k:sub(1, k:find("s:")) local title=strRight(k, "s:") if ref=="physics" then tileProperties.physics[title]=v elseif ref=="tiles" then tileProperties.tile[title]=v elseif ref=="layer" then tileProperties.layer[title]=v end end return tileProperties end
local function getFileContents(filename, base) local base=base or system.ResourceDirectory local path=system.pathForFile(filename, base) local contents local file=io.open(path, "r") if file then contents=file:read("*a") io.close(file) file=nil end return contents end
local function clipTable(t, max) if #t>max then for i=#t, max+1, -1 do t[i]=nil end end return t end
local function isPolyClockwise(pointList) local area=0 for i=1, #pointList-2, 2 do local pointStart={x=pointList[i]-pointList[1], y=pointList[i+1]-pointList[2]} local pointEnd={x=pointList[i+2]-pointList[1], y=pointList[i+3]-pointList[2]} area=area+(pointStart.x*-pointEnd.y)-(pointEnd.x*-pointStart.y) end return (area<0) end
local function reverse(t) local nt={} for i=1, #t, 2 do nt[#nt+1]=t[#t-i] nt[#nt+1]=t[#t-i+1] end return nt end
local function toV(value) local v if value=="true" or value=="false" then if value=="true" then v=true else v=false end elseif value:match("[+-]?%d+%.?[%d]+")==value then v=tonumber(value) elseif value:match("^!json!") then v=json.decode(value:sub(7)) else if value:sub(1,1)=="\"" and value:sub(-1)=="\"" then v=value:sub(2, -2) else v=value end end return v end
local function getObjectLayerProperties(data) local p={options={physicsExistent=false}, physics={}, objects={}, layer={}} local insertionTable for key, value in pairs(data) do local k, v if key:match("^physics:") then insertionTable=p.physics k=key:sub(9) elseif key:match("^objects:") then insertionTable=p.objects k=key:sub(9) else insertionTable=p.layer if key:match("^layer:") then k=key:sub(7) end end  v=toV(value)  if k=="enabled" and insertionTable==p.physics then if v==true then p.options.physicsExistent=true end else insertionTable[k]=v end end return p end
local function getObjProperties(data) local p={options={}, physics={}, object={}} local insertionTable for key, value in pairs(data) do local k, v if key:match("^physics:") then insertionTable=p.physics k=key:sub(9) else insertionTable=p.object k=key end v=toV(value) if k=="enabled" and insertionTable==p.physics then if v==true then p.options.physicsExistent=true elseif v==false then p.options.physicsExistent=false end else insertionTable[k]=v end end return p end
local function getTileLayerProperties(data) local p={options={}, physics={}, tile={}, layer={}} local insertionTable for key, value in pairs(data) do local k, v if key:match("^physics:") then insertionTable=p.physics k=key:sub(9) elseif key:match("^tiles:") then insertionTable=p.tile k=key:sub(7) else insertionTable=p.layer if key:match("^layer:") then k=key:sub(7) else k=key end end v=toV(value) if k=="enabled" and insertionTable==p.physics then if v==true then p.options.physicsExistent=true end else insertionTable[k]=v end end return p end
local function fnn(...) for i=1, #arg do if arg[i]~=nil then return arg[i] end end end


--------------------------------------------------------------------------------
-- Load File Data
--------------------------------------------------------------------------------
local function loadFileData(filename, base)
	local base=base or system.ResourceDirectory
	local fileData
	
	local extension=filename:match("%..+$")
	assert(extension~=nil, "File name missing extension")
	extension=extension:lower()
	
	if extension==".lua" then
		assert(base==system.ResourceDirectory, "Cannot load a Lua file that is not in the resource directory")
		local luaName=filename:gsub("/", "."):sub(1, -5)
		fileData=require(luaName)
		tprint("Loaded Map File"); tabLevel=tabLevel+1
		tprint("Filename: \""..filename.."\"")
		tprint("Map Format: Lua"); tabLevel=tabLevel-1
	elseif extension==".json" then
		fileData=json.decode(getFileContents(filename, base))	
		tprint("Loaded Map File"); tabLevel=tabLevel+1
		tprint("Filename: \""..filename.."\"")
		tprint("Map Format: JSON"); tabLevel=tabLevel-1
	else
		error("Maps with extension \""..extension.."\" not supported")
	end
	
	tprint() -- newline
	
	return fileData
end


--------------------------------------------------------------------------------
-- Ceramic Public Values
--
-- Miscellaneous values for testing and building - edit to your liking
--------------------------------------------------------------------------------
Ceramic.useEllipseShape=true -- Use an 8-point shape for ellipse objects
Ceramic.drawPrefs={
	lineWidth=2, -- Line width of test build objects
	color={128, 128, 128, 128}, -- Fill color of test build objects
	lineColor={255, 255, 255, 255} -- Color of test build lines
}
Ceramic.autoSortShapePoints=true -- Automatically reverse anti-clockwise shapes
Ceramic.showPrints=false -- Show debug and info messages
Ceramic.buildForTesting=false -- Show object layers
Ceramic.baseDirectory=system.ResourcesDirectory -- Where map files are located

--------------------------------------------------------------------------------
-- generateMap()
--
-- The loading function; builds a map from file data.
--------------------------------------------------------------------------------
local function generateMap(mapFile, useBasic)
	tprint("Generating Map: \""..mapFile.."\""); tprint()
	local mapData=loadFileData(mapFile, Ceramic.baseDirectory)
	if not mapData then return nil end
	local map=display.newGroup()
	map.layer={}
	
	local sheets={} -- Tileset sheets
	local frames={} -- Tileset frame data
	local tsprops={} -- Tileset properties (per-tile)
	local index={} -- Data table for loading each tile
	
	------------------------------------------------------------------------------
	-- Set Up Data
	------------------------------------------------------------------------------
	local data={
		layerCount=#mapData.layers,
		tilesetCount=#mapData.tilesets,
		orientation=mapData.orientation,
		mapHeight=mapData.height,
		mapWidth=mapData.width,
		tileHeight=mapData.tileheight,
		tileWidth=mapData.tilewidth,
		pixelHeight=mapData.tileheight/display.contentScaleY,
		pixelWidth=mapData.tilewidth/display.contentScaleX,
		scaledTileHeight=0,
		scaledTileWidth=0,
		contentZoomY=0,
		contentZoomX=0,
		leftTile=0,
		rightTile=0,
		topTile=0,
		bottomTile=0
	}
	
	data.scaledTileHeight=math_floor(data.pixelHeight)*display.contentScaleY
	data.scaledTileWidth=math_floor(data.pixelWidth)*display.contentScaleX
	data.contentZoomY=data.scaledTileHeight/data.tileHeight
	data.contentZoomX=data.scaledTileWidth/data.tileWidth
	
	assert(data.orientation=="orthogonal", "ERROR: Ceramic only supports orthogonal maps")
	
	tprint("Map Stats"); tabLevel=tabLevel+1
	tprint("Layer Count: "..data.layerCount)
	tprint("Tileset Count: "..data.tilesetCount)
	tprint("Map Dimensions: "..data.mapWidth.." by "..data.mapHeight.." t")
	tprint("Tile Dimensions: "..data.tileWidth.." by "..data.tileHeight.." px"); tabLevel=tabLevel-1
	tprint()
	
	map._mapData=mapData

	local map_mt=getmetatable(map)

	function map_mt.__call(m, s)
		if s and type(s)=="string" then
			if data[s] then
				return data[s]
			else
				tprint("No data value \""..tostring(s).."\"")
			end
		end
	end

	setmetatable(map, map_mt)
	

	------------------------------------------------------------------------------
	-- Load Tilesets
	------------------------------------------------------------------------------
	tprint("Loading Tilesets"); tabLevel=tabLevel+1
	local c=0
	for i=1, #mapData.tilesets do
		tprint("Tileset "..i..":"); tabLevel=tabLevel+1
		
		local gid
		local strGid
		local tilesetProperties
		local options
		
		mapData.tilesets[i].tileproperties=mapData.tilesets[i].tileproperties or {}
		
		gid=0
		strGid="0"
		tilesetProperties={}
		
		options={
			sheet={ -- Sheet data
				frames={},
				sheetContentWidth=mapData.tilesets[i].imagewidth,
				sheetContentHeight=mapData.tilesets[i].imageheight,
				start=1,
				count=0
			},
			image=mapData.tilesets[i].image:match("[%w%s_\\/-]+%.%w+$"),
			margin=mapData.tilesets[i].margin,
			spacing=mapData.tilesets[i].spacing,
			tileheight=mapData.tilesets[i].tileheight,
			tilewidth=mapData.tilesets[i].tilewidth,
			tilesetWidth=0,
			tilesetHeight=0,
		}
		
		-- Remove opening slash, if existent
		if options.image:sub(1,1)=="/" or options.image:sub(1,1)=="\\" then options.image=options.image:sub(2) end
		
		tprint("Image: \""..options.image.."\"")
		tprint("Image Dimensions: "..options.sheet.sheetContentWidth.." by "..options.sheet.sheetContentHeight.." px")
		tprint("Tile Dimensions: "..options.tilewidth.." by "..options.tileheight.." px")
		tprint("Margin: "..options.margin.." px")
		tprint("Spacing: "..options.spacing.." px")
		
		options.tilesetWidth=math_ceil((options.sheet.sheetContentWidth-options.margin*2-options.spacing)/(options.tilewidth+options.spacing)) 		
		options.tilesetHeight=math_ceil((options.sheet.sheetContentHeight-options.margin*2-options.spacing)/(options.tileheight+options.spacing))
		
		tprint("Tileset Dimensions: "..options.tilesetWidth.." by "..options.tilesetHeight.." t")

		tprint("Generating Tileset")
		for y=1, options.tilesetHeight do
			for x=1, options.tilesetWidth do
				local element={
					x=(x-1)*(options.tilewidth+options.spacing)+options.margin,
					y=(y-1)*(options.tileheight+options.spacing)+options.margin,
					width=options.tilewidth,
					height=options.tileheight
				}
				gid=gid+1
				c=c+1
				table_insert(options.sheet.frames, gid, element)
				index[c]={i, gid}
				
				strGid=tostring(gid-1) -- Tiled tile properties start at 0, so we must subtract 1
				
				if mapData.tilesets[i].tileproperties[strGid] then
					tilesetProperties[gid]=getObjProperties(mapData.tilesets[i].tileproperties[strGid])
				end
			end
		end
		options.sheet.count=gid
		tprint("Tile Count: "..gid.." t")
		tprint("Generation Finished")

		sheets[i]=newImageSheet(options.image, options.sheet)
		frames[i]=options.sheet
		tsprops[i]=tilesetProperties

		tprint("Finished Loading Tileset "..i); tabLevel=tabLevel-1
	end
	tprint("Finished Loading Tilesets"); tabLevel=tabLevel-1; tprint()
	

	------------------------------------------------------------------------------
	-- Build Layers
	------------------------------------------------------------------------------
	tprint("Building Layers"); tabLevel=tabLevel+1
	for i=1, #mapData.layers do
		tprint("Layer "..i..":"); tabLevel=tabLevel+1
		
		local layer
		local props
		
		if mapData.layers[i].type=="tilelayer" and not (mapData.layers[i].properties or {})["!!!inactive!!!"] then
			props=getTileLayerProperties(mapData.layers[i].properties or {})
			tprint("Type: Tile Layer")
			tprint("Name: \""..mapData.layers[i].name.."\"")
			
			layer=newGroup()
			layer.tile={}
			layer._name=mapData.layers[i].name

			local tile_mt={}

			function tile_mt.__call(t, x, y)
				if layer.tile[x]~=nil and layer.tile[x][y]~=nil then
					return layer.tile[x][y]
				end
			end

			setmetatable(layer.tile, tile_mt)

			if not useBasic then
				layer._locked={}

				local render={}
				function layer.resetRenderParams()
					render.eraseMargin=0
					render.drawMargin=0
					render.renderMarginL=1
					render.renderMarginR=1
					render.renderMarginT=1
					render.renderMarginB=1
					render.renderOffsetX=1
					render.renderOffsetY=1
					render.visibleX=math.ceil(display.contentWidth/data.scaledTileWidth*layer.xScale)
					render.visibleY=math.ceil(display.contentHeight/data.scaledTileHeight*layer.yScale)
					render.leftPixel=0
					render.topPixel=0
					render.left=1
					render.top=1
					render.right=render.left+render.visibleX
					render.bottom=render.top+render.visibleY
					render.pLeft=1
					render.pRight=1
					render.pTop=1
					render.pBottom=1
					render.pX=0
					render.pY=0
					render.buffer1=0
					render.buffer2=0
				end

				function layer.resetVisible()
					render.visibleX=math.ceil((display.contentWidth/(data.tileWidth*layer.xScale*map.xScale)))
					render.visibleY=math.ceil((display.contentHeight/(data.tileHeight*layer.yScale*map.yScale)))
				end


				--------------------------------------------------------------------------
				-- layer.render()
				--
				-- The backbone culling function for tile layers.
				--------------------------------------------------------------------------
				function layer.render(x, y)
					render.pLeft=render.left
					render.pRight=render.right
					render.pTop=render.top
					render.pBottom=render.bottom

					-- Calculate sides
					if render.pX~=x then
						render.leftPixel=data.pixelWidth-x-data.pixelWidth
						render.left=render.renderOffsetX+math.floor(render.leftPixel/data.tileWidth*layer.xScale)-render.renderMarginL
						render.right=render.renderOffsetX+render.left+render.visibleX+render.renderMarginR
					end

					if render.pY~=y then
						render.topPixel=data.pixelHeight-y-data.pixelHeight
						render.top=render.renderOffsetY+math.floor(render.topPixel/data.tileHeight*layer.yScale)-render.renderMarginT
						render.bottom=render.renderOffsetY+render.top+render.visibleY+render.renderMarginB
					end

					-- Cull X
					if render.pLeft~=render.left or render.pRight~=render.right then
						if render.pX<x then
							layer.draw(render.pLeft, render.left, render.top-render.drawMargin, render.bottom+render.drawMargin)
							layer.erase(render.pRight, render.right, render.top-render.eraseMargin, render.bottom+render.eraseMargin)
						elseif render.pX>x then
							layer.draw(render.pRight, render.right, render.top-render.drawMargin, render.bottom+render.drawMargin)
							layer.erase(render.pLeft, render.left, render.top-render.eraseMargin, render.bottom+render.eraseMargin)
						end
					end
					
					-- Cull Y
					if render.pTop~=render.top or render.pBottom~=render.bottom then
						if render.pY<y then
							layer.draw(render.left-render.drawMargin, render.right+render.drawMargin, render.pTop, render.top)
							layer.erase(render.left-render.drawMargin, render.right+render.eraseMargin, render.pBottom, render.bottom)
						elseif render.pY>y then
							layer.draw(render.left-render.drawMargin, render.right+render.drawMargin, render.pBottom, render.bottom)
							layer.erase(render.left-render.eraseMargin, render.right+render.eraseMargin, render.pTop, render.top)
						end
					end

					-- Remove extra tiles created by fast diagonal movement
					if render.pTop~=render.top and render.pLeft~=render.left and render.pBottom~=render.bottom and render.pRight~=render.right then
						if render.pX>x and render.pY>y then
							render.buffer1=render.left-(render.left-render.pLeft)
							render.buffer2=render.top-(render.top-render.pTop)
							layer.erase(render.buffer1-1, render.left-1, render.buffer2-1, render.top-1)
						elseif render.pX>x and render.pY<y then
							render.buffer1=render.left-(render.left-render.pLeft)
							render.buffer2=render.bottom-(render.bottom-render.pBottom)
							layer.erase(render.buffer1-1, render.left-1, render.buffer2+1, render.bottom+1)
						elseif render.pX<x and render.pY>y then
							render.buffer1=render.right-(render.right-render.pRight)
							render.buffer2=render.top-(render.top-render.pTop)
							layer.erase(render.buffer1+1, render.right+1, render.buffer2-1, render.top-1)
						elseif render.pX<x and render.pY<y then
							render.buffer1=render.right-(render.right-render.pRight)
							render.buffer2=render.bottom-(render.bottom-render.pBottom)
							layer.erase(render.buffer1+1, render.right+1, render.buffer2+1, render.bottom+1)
						end
					end

					render.pX=x; render.pY=y
				end

				--------------------------------------------------------------------------
				-- layer.setLock()
				--------------------------------------------------------------------------
				function layer.setLock(x1, x2, y1, y2, lock)
					local x1=x1 or 0
					local x2=x2 or x1
					local y1=y1 or 0
					local y2=y2 or y1
					local lock=(lock==nil and true) or lock

					if x1>x2 then x1, x2=x2, x1 end
					if y1>y2 then y1, y2=y2, y1 end

					for x=x1, x2 do
						if x>0 and x<=data.mapWidth then
							if not layer._locked[x] then layer._locked[x]={} end
							for y=y1, y2 do
								if y>0 and y<=data.mapHeight then
									layer._locked[x][y]=lock
								end -- if y>0 and
							end -- for y=
						end -- if x>0 and
					end -- for x
				end -- layer.setLock

				layer.resetRenderParams()
			end -- if not useBasic

			--------------------------------------------------------------------------
			-- layer.draw()
			--------------------------------------------------------------------------
			function layer.draw(x1, x2, y1, y2)
				local x1=x1 or 0
				local x2=x2 or x1
				local y1=y1 or 0
				local y2=y2 or y1
				
				if x1>x2 then x1, x2=x2, x1 end
				if y1>y2 then y1, y2=y2, y1 end

				for x=x1, x2 do
					if x>0 and x<=data.mapWidth then
						if not layer.tile[x] then layer.tile[x]={} end
						for y=y1, y2 do
							if y>0 and y<=data.mapHeight then
								local id=mapData.layers[i].data[(y-1)*data.mapWidth+x]
								
								if id and id~=0 then
									if not layer.tile[x][y] then
										-- No tile in position, so build one
										local reference=index[id]
										
										local tile=newSprite(sheets[reference[1]], frames[reference[1]])
										tile:setFrame(reference[2])
										tile.x, tile.y=(x-0.5)*data.tileWidth, (y-0.5)*data.tileHeight
										
										local tileProps

										if tsprops[reference[1] ][reference[2] ] then
											tileProps=tsprops[reference[1] ][reference[2] ]
										else
											tileProps={object={},options={},physics={}}
										end

										tileProps.options.physicsExistent=fnn(tileProps.options.physicsExistent, props.options.physicsExistent)
										for k, v in pairs(physicsData) do tileProps.physics[k]=fnn(tileProps.physics[k], props.physics[k]) end
										for k, v in pairs(props.tile) do tile[k]=fnn(tileProps.object[k], props.tile[k]) end
										for k, v in pairs(tileProps.object) do tile[k]=tileProps.object[k] end

										if tileProps.options.physicsExistent then
											physics.addBody(tile, tileProps.physics.bodyType or "static", tileProps.physics)
										end

										layer:insert(tile)
										layer.tile[x][y]=tile
									end
								end -- if id~=0
							end -- if y>0 and
						end -- for y=
					end -- if x>0 and
				end -- for x
			end -- layer.draw

			
			--------------------------------------------------------------------------
			-- layer.erase()
			--------------------------------------------------------------------------
			function layer.erase(x1, x2, y1, y2)
				local x1=x1 or 0
				local x2=x2 or x1
				local y1=y1 or 0
				local y2=y2 or y1
				
				if x1>x2 then x1, x2=x2, x1 end
				if y1>y2 then y1, y2=y2, y1 end

				for x=x1, x2 do
					if x>0 and x<=data.mapWidth then
						if not layer.tile[x] then layer.tile[x]={} end
						if not layer._locked[x] then layer._locked[x]={} end
						for y=y1, y2 do
							if y>0 and y<=data.mapHeight then
								if layer.tile[x][y] and not layer._locked[x][y] then
									remove(layer.tile[x][y])
									layer.tile[x][y]=nil
								end
							end -- if y>0 and
						end -- for y=
					end -- if x>0 and
				end -- for x=
			end -- layer.erase
				
		elseif mapData.layers[i].type=="objectgroup" and not (mapData.layers[i].properties or {})["!!!inactive!!!"] then
			props=getObjectLayerProperties(mapData.layers[i].properties or {})
			tprint("Type: Object Group")
			tprint("Name: \""..mapData.layers[i].name.."\"")
			
			layer=newGroup()
			for k, v in pairs(props.layer) do layer[k]=v end
			layer._name=mapData.layers[i].name
			layer.object={}
			
			tprint("Creating Objects"); tabLevel=tabLevel+1
			
			--------------------------------------------------------------------------
			-- Create Objects
			--------------------------------------------------------------------------
			for o=1, #mapData.layers[i].objects do
				local object=mapData.layers[i].objects[o]
				tprint("Object "..o); tabLevel=tabLevel+1
				
				local obj

				local objProps=getObjProperties(object.properties)
				objProps.options.physicsExistent=fnn(objProps.options.physicsExistent, props.options.physicsExistent)
				for k, v in pairs(physicsData) do objProps.physics[k]=fnn(objProps.physics[k], props.physics[k]) end

				if object.ellipse then -- Ellipse shape
					tprint("Type: "..(object.width==object.height and "Circle" or "Ellipse"))
					tprint("Name: "..(object.name~="" and "\""..object.name.."\"" or "(none)"))
					tprint("Dimensions: "..object.width.." by "..object.height.." px")
					tprint("X, Y: ("..object.x..", "..object.y..")")
					
					-- Zoomed dimensions
					local zx=object.x*data.contentZoomX
					local zy=object.y*data.contentZoomY
					local zw=object.width*data.contentZoomX
					local zh=object.height*data.contentZoomY
					
					if zw>zh then
						obj=newCircle(layer, zx, zy, zw*0.5); obj.yScale=(zh/zw)
					else
						obj=newCircle(layer, zx, zy, zh*0.5); obj.xScale=(zw/zh)
					end
						
					obj.x, obj.y=zx+(zw*0.5), zy+(zh*0.5)	
					
					if objProps.options.physicsExistent then
						if Ceramic.useEllipseShape then
							objProps.physics.shape=multiply(ellipseShape, zw/ellipseSize, zh/ellipseSize)
						else
							objProps.physics.radius=((zh+zw)*0.5)*0.5
						end
						
						addBody(obj, objProps.physics.bodyType or "static", objProps.physics)
					end
					
				elseif object.polygon or object.polyline then -- Poly-something-or-other
					local point
					if object.polygon then point=object.polygon else point=object.polyline end
					
					tprint("Type: "..(object.polygon~=nil and "Polygon" or "Polyline"))
					tprint("Name: "..(object.name~="" and "\""..object.name.."\"" or "(none)"))
					tprint("X, Y: ("..object.x..", "..object.y..")")
					tprint("Point Count: "..#point)
					
					obj=newLine(point[1].x, point[1].y, point[2].x, point[2].y)
					
					for p=3, #point do obj:append(point[p].x, point[p].y) end

					if object.polygon then obj:append(point[1].x, point[1].y) end
					
					obj.x, obj.y=object.x, object.y
					
					if objProps.options.physicsExistent then
						objProps.physics.shape={}
						
						for p=1, math_min(#point, 8) do
							objProps.physics.shape[#objProps.physics.shape+1]=point[p].x
							objProps.physics.shape[#objProps.physics.shape+1]=point[p].y
						end
						
						if Ceramic.autoSortShapePoints then
							tprint("Checking for Anti-Clockwise Shape")
							if not isPolyClockwise(objProps.physics.shape) then
								objProps.physics.shape=reverse(objProps.physics.shape)
								tprint("Shape was Reversed")
							else
								tprint("Shape is Already Clockwise")
							end
						end
						
						addBody(obj, objProps.physics.bodyType or "static", objProps.physics)
					end

				elseif object.gid then
					tprint("Type: Tile")
					tprint("Name: "..(object.name~="" and "\""..object.name.."\"" or "(none)"))
					tprint("GID: "..object.gid)
					tprint("X, Y: ("..object.x..", "..object.y..")")
					local reference=index[object.gid]
					
					obj=newSprite(sheets[reference[1]], frames[reference[1]])
					obj:setFrame(reference[2])
					obj.x, obj.y=object.x+(data.tileWidth*0.5), object.y-(data.tileHeight*0.5)
									
					if objProps.options.physicsExistent then
						addBody(obj, objProps.physics.bodyType or "static", objProps.physics)
					end
				else -- Rectangle
					tprint("Type: "..(object.width==object.height and "Square" or "Rectangle"))
					tprint("Name: "..(object.name~="" and "\""..object.name.."\"" or "(none)"))
					tprint("Dimensions: "..object.width.." by "..object.height.." px")
					tprint("X, Y: ("..object.x..", "..object.y..")")
					
					obj=newRect(object.x, object.y, object.width, object.height)
					
					if objProps.options.physicsExistent then
						addBody(obj, objProps.physics.bodyType or "static", objProps.physics)
					end
				end

				for k, v in pairs(props.objects) do obj[k]=fnn(objProps.object[k], props.objects[k]) end
				for k, v in pairs(objProps.object) do obj[k]=objProps.object[k] end				

				obj._name=(mapData.layers[i].objects[o].name~="" and mapData.layers[i].objects[o].name or mapData.layers[i].objects[o].type..o)
				obj._type=mapData.layers[i].objects[o].type
				if obj._type=="" then
					if props.objects._type then
						obj._type=props.objects._type
					end
				end

				obj.isVisible=mapData.layers[i].objects[o].visible
				
				if Ceramic.buildForTesting then
					if object.polygon or object.polyline then
						obj.width=Ceramic.drawPrefs.lineWidth
						obj:setColor(Ceramic.drawPrefs.lineColor[1], Ceramic.drawPrefs.lineColor[2], Ceramic.drawPrefs.lineColor[3], Ceramic.drawPrefs.lineColor[4])
					else
						obj:setFillColor(Ceramic.drawPrefs.color[1], Ceramic.drawPrefs.color[2], Ceramic.drawPrefs.color[3], Ceramic.drawPrefs.color[4])
						obj:setStrokeColor(Ceramic.drawPrefs.lineColor[1], Ceramic.drawPrefs.lineColor[2], Ceramic.drawPrefs.lineColor[3], Ceramic.drawPrefs.lineColor[4])
						obj.strokeWidth=Ceramic.drawPrefs.lineWidth
					end
				else
					if not object.gid then
						obj.isVisible=false
					end
				end

				layer:insert(obj)
				layer.object[obj._name]=obj
				
				tabLevel=tabLevel-1
			end
			tabLevel=tabLevel-1

			function layer.render() end

		elseif mapData.layers[i].type=="imagelayer" and not (mapData.layers[i].properties or {})["!!!inactive!!!"] then
			tprint("Type: Image Layer")
			tprint("Name: \""..mapData.layers[i].name.."\"")
			tprint("Image: \""..mapData.layers[i].image:match("[%w%s_/]+%.%w+$").."\"")
			props=getTileLayerProperties(mapData.layers[i].properties or {})
			
			layer=newImage(mapData.layers[i].image:match("[%w%s_/]+%.%w+$"))
			layer._name=mapData.layers[i].name
			layer.x, layer.y=mapData.layers[i].x+(layer.width*0.5), mapData.layers[i].y+(layer.height*0.5)		
			function layer.render() end
		end -- mapData.layers[i].type==
		
		if not (mapData.layers[i].properties or {})["!!!inactive!!!"] then
			for k, v in pairs(props.layer) do layer[k]=v end
			
			layer.isVisible=mapData.layers[i].visible
			layer.alpha=mapData.layers[i].opacity
			tprint("Visible: "..tostring(layer.isVisible))
			tprint("Opacity: "..tostring(layer.alpha))

			layer.trackingEnabled=(props.layer.trackingEnabled==nil and true) or props.layer.trackingEnabled
			layer.xParallax=(props.layer.xParallax==nil and 1) or props.layer.xParallax
			layer.yParallax=(props.layer.yParallax==nil and 1) or props.layer.yParallax
			layer._type=mapData.layers[i].type
			table.insert(map.layer, layer)
			map.layer[layer._name]=layer
			tabLevel=tabLevel-1
			map:insert(layer)
		end
	end -- for i=1, #mapData.layers
	
	return map
end


--------------------------------------------------------------------------------
-- Ceramic.buildMap()
--
-- The public map loading function.
--------------------------------------------------------------------------------
function Ceramic.buildMap(mapFile, useBasic)
	local map=generateMap(mapFile, useBasic)

	map.viewX, map.viewY=0.1, 0.1

	local visibleX, visibleY
	local view

	if not useBasic then
		view={
			offsetX=0,
			offsetY=0,
			bounds={
				0, map("mapWidth")*map("tileWidth"),
				0, map("mapHeight")*map("tileHeight")
			},
			focus={}
		}

		visibleX=math.ceil(display.contentWidth/map("tileWidth")*map.xScale)
		visibleY=math.ceil(display.contentHeight/map("tileHeight")*map.yScale)

		function map.resetVisible()
			visibleX=math.ceil(display.contentWidth/map("tileWidth")*map.xScale)
			visibleY=math.ceil(display.contentWidth/map("tileHeight")*map.yScale)
			for i=1, map("layerCount") do
				if map.layer[i] and map.layer[i]._type=="tilelayer" then map.layer[i].resetVisible() end
			end
		end

		------------------------------------------------------------------------------
		--[[
		view.updateCamera()

		Updates the view position.
		--]]
		------------------------------------------------------------------------------
		function view.updateCamera()
			if view.focus and view.focus.x and view.focus.y then
				if view.focus["toFront"] then view.focus:toFront() end
				local targetX, targetY

				if view.focus.x<=view.bounds[2] and view.focus.x>=view.bounds[1] then
					targetX=-view.focus.x
				elseif view.focus.x>view.bounds[2] then
					targetX=-view.bounds[2]
				elseif view.focus.x<view.bounds[1] then
					targetX=-view.bounds[1]
				end

				if view.focus.y<=view.bounds[4] and view.focus.y>=view.bounds[3] then
					targetY=-view.focus.y
				elseif view.focus.y>view.bounds[4] then
					targetY=-view.bounds[4]
				elseif view.focus.y<view.bounds[3] then
					targetY=-view.bounds[3]
				end

				targetX=display.contentCenterX+targetX
				targetY=display.contentCenterY+targetY

				map.viewX=targetX
				map.viewY=targetY
				map.render()
			end
		end

		------------------------------------------------------------------------------
		--[[
		map.setCameraFocus()

		Sets the view focus.
		--]]
		------------------------------------------------------------------------------
		function map.setCameraFocus(f)
			if f and type(f)=="table" and f.x and f.y then
				view.focus=f
			end
		end

		------------------------------------------------------------------------------
		--[[
		map.updateCamera()

		Updates the view position. It's in a separate function from view.updateCamera
		because if ever something extra needed to be done you could do it right here
		instead of inside the view function, which just repositions the camera.
		--]]
		------------------------------------------------------------------------------
		function map.updateCamera()
			view.updateCamera()
		end

		------------------------------------------------------------------------------
		--[[
		map.setCameraBounds()

		Sets the clamping bounds of the view.
		--]]
		------------------------------------------------------------------------------
		function map.setCameraBounds(x1, x2, y1, y2)
			local x1=fnn(x1, 0)
			local x2=fnn(x2, map("mapWidth")*map("tileWidth"))
			local y1=fnn(y1, 0)
			local y2=fnn(y2, map("mapHeight")*map("tileHeight"))

			if x1==false then x1=-math.huge end
			if x2==false then x2=math.huge end
			if y1==false then y1=-math.huge end
			if y2==false then y2=math.huge end

			view.bounds[1]=x1
			view.bounds[2]=x2
			view.bounds[3]=y1
			view.bounds[4]=y2
		end


		------------------------------------------------------------------------------
		--[[
		map.render()

		Draws the map at either the current viewX and viewY of the map or a new viewX
		and viewY location specified by the user.
		--]]
		------------------------------------------------------------------------------
		function map.render(x, y)
			if x and y then map.viewX, map.viewY=x, y end

			local X, Y=map.viewX+view.offsetX, map.viewY+view.offsetY

			for i=1, map("layerCount") do
				if map.layer[i] and map.layer[i].trackingEnabled then
					map.layer[i].x=X*map.layer[i].xParallax
					map.layer[i].y=Y*map.layer[i].yParallax
					map.layer[i].render(map.layer[i].x, map.layer[i].y)
				end
			end
		end
		
		------------------------------------------------------------------------------
		--[[
		map.setLock()

		Sets the lock state of a chunk of tiles. Optional 5th argument specifies which
		layer to set; if missing, all tile layers will be set. If 4th argument is missing,
		lock state defaults to true.
		--]]
		------------------------------------------------------------------------------
		function map.setLock(x1, x2, y1, y2, lock)
			if x1>x2 then x1, x2=x2, x1 end
			if y1>y2 then y1, y2=y2, y1 end

			for i=1, map("layerCount") do
				if map.layer[i] and map.layer[i]._type=="tilelayer" then
					map.layer[i].setLock(x1, x2, y1, y2, lock)
				end
			end
		end

	end -- if not useBasic

	------------------------------------------------------------------------------
	--[[
	map.draw()

	Draws a chunk of tiles. Optional 4th argument specifies which layer to draw;
	if missing, all tile layers will be drawn.
	--]]
	------------------------------------------------------------------------------
	function map.draw(x1, x2, y1, y2)
		for i=1, map("layerCount") do
			if map.layer[i] and map.layer[i]._type=="tilelayer" then
				map.layer[i].draw(x1, x2, y1, y2)
			end
		end
	end	
	

	------------------------------------------------------------------------------
	--[[
	map.erase()

	Erases a chunk of tiles. Optional 4th argument specifies which layer to erase 
	from; if missing, all tile layers will be erased from.
	--]]
	------------------------------------------------------------------------------
	function map.erase(x1, x2, y1, y2)
		if x1>x2 then x1, x2=x2, x1 end
		if y1>y2 then y1, y2=y2, y1 end

		for i=1, map("layerCount") do
			if map.layer[i] and map.layer[i]._type=="tilelayer" then
				map.layer[i].erase(x1, x2, y1, y2)
			end
		end
	end
	
	if not useBasic then
		map.draw(1, visibleX, 1, visibleY)
		map.render()
	else
		map.draw(1, map("mapWidth"), 1, map("mapHeight"))
	end

	return map
end

return Ceramic