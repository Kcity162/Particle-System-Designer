require 'simple-slider'
require 'colorPalette'
require 'textureButton'

--GUI Params
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080
PADDING = 20
PADDING2 = 5
SLIDER_LENGTH = 150
SLIDER_X = SLIDER_LENGTH/2 + PADDING
SLIDER_SPACING = 20
TEXTURE_BUTTON_WIDTH = 50
COLOR_PALETTE_WIDTH = 160
PALETTE_IMAGE_PATH = 'palette_160.png'

--System Params
MAX_PARTICLES = 20000
TEXTURE_DIRECTORY = 'textures/'
TEXTURE_IMAGE_FORMAT = '.png'
SAVE_DIRECTORY = '/Users/kevin.torrington/Documents/code/Dreambound/assets/effects/'

--Other Global Params
BLACK = {0,0,0,1}
WHITE = {1,1,1,1}



function love.load()
    --Setup the window
    love.window.setTitle('Particle Effect Generator')
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=false, vsync=true, minwidth=400, minheight=300})

    --Setup effect sliders
    sliderStyle = {
        ['width'] = SLIDER_SPACING - 5,
        ['orientation'] = 'horizontal',
        ['track'] = 'line',
        ['knob'] = 'rectangle'
    }
    sliders = { --This table contains effect sliders and slider subgroup labels
        [1] = 'Spawn Parameters:',
        [2] = newSlider(0, 0, SLIDER_LENGTH, 1000, 0, 5000, function (v) pSystem:setEmissionRate(v) end, sliderStyle, 'Emission Rate'),
        [3] = newSlider(0, 0, SLIDER_LENGTH, 2, 0.1, 5, function (v) pSystem:setParticleLifetime(v*.5, v) end, sliderStyle, 'Lifetime'),
        [4] = newSlider(0, 0, SLIDER_LENGTH, 10, 0, 50, function (v) pSystem:setEmissionArea('normal', v, v) end, sliderStyle, 'Emission Area'),
        [5] = 'Velocity Parameters:',
        [6] = newSlider(0, 0, SLIDER_LENGTH, 250, 0, 1000, function (v) pSystem:setSpeed(v*.5, v) end, sliderStyle, 'Speed'),
        [7] = newSlider(0, 0, SLIDER_LENGTH, 20, 0, 1000, function (v) pSystem:setRadialAcceleration(v*.5, v) end, sliderStyle, 'Radial Acceleration Max'),
        [8] = newSlider(0, 0, SLIDER_LENGTH, 0, 0, 10, function (v) pSystem:setLinearDamping(v*.5, v) end, sliderStyle, 'Linear Damping'),
        [9] = 'Direction Parameters:',
        [10] = newSlider(0, 0, SLIDER_LENGTH, .73, 0, 6.28, function (v) pSystem:setDirection(-v) end, sliderStyle, 'Direction (Radians)'),
        [11] = newSlider(0, 0, SLIDER_LENGTH, 0, 0, 6.28, function (v) pSystem:setSpread(v) end, sliderStyle, 'Spread (Rads)'),
        [12] = 'Size Parameters:',
        [13] = newSlider(0, 0, SLIDER_LENGTH, 1, 0, 5, function (v) startSize = v end, sliderStyle, 'Start Size'),
        [14] = newSlider(0, 0, SLIDER_LENGTH, 3, 0, 5, function (v) midSize = v end, sliderStyle, 'Mid Size'),
        [15] = newSlider(0, 0, SLIDER_LENGTH, .1, 0, 5, function (v) endSize = v end, sliderStyle, 'End Size'),
        [16] = newSlider(0, 0, SLIDER_LENGTH, 0, 0, 1, function (v) pSystem:setSizeVariation(v) end, sliderStyle, 'Size Variation'),
        [17] = 'Rotation Parameters:',
        [18] = newSlider(0, 0, SLIDER_LENGTH, 1, 0, 20, function (v) pSystem:setSpin(v*.5, v) end, sliderStyle, 'Spin (Rads/sec)'),
        [19] = newSlider(0, 0, SLIDER_LENGTH, 0, -500, 500, function (v) pSystem:setTangentialAcceleration(v*.5, v) end, sliderStyle, 'Tangential Acceleration')
    }
    setSliderXY()

    --Setup the particle system and texture buttons
    texture = love.graphics.newImage('textures/cloud.png')
    pSystem = love.graphics.newParticleSystem(texture, MAX_PARTICLES)
    textureButtons = {}
    populateTextureButtons()
    setTextureXY()

    --Setup color palettes
    colorPalettes = {}
    populateColorPalettes()

    --Initialize globals
    r1,g1,b1,a1,r2,g2,b2,a2,r3,g3,b3,a3 = 1,1,1,1,1,1,1,1,1,1,1,1
    mouseDown = false
    mouseX = 0
    mouseY = 0
    startSize = 1
    midSize = 1
    endSize = 1
    thirdColor = true
    currentTextureName = 'cloud' -- Track current texture
    saveMessage = ''
    saveMessageTimer = 0
end


function love.resize()
    WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
    setSliderXY()
    setTextureXY()
    populateColorPalettes()
end


function love.update(dt)
    --Update global mouse status variables
    mouseDown = love.mouse.isDown(1)
    mouseX, mouseY = love.mouse.getPosition()

    --Update sliders
    for i, slider in pairs(sliders) do
        if type(slider) ~= 'string' then 
            slider:update()
        end
    end

    --Update texture buttons
    for i, textureButton in pairs(textureButtons) do
        textureButton:update()
    end
    
    --Update color palettes
    r1,g1,b1,a1 = colorPalettes [1]:update()
    r2,g2,b2,a2 = colorPalettes [2]:update()
    r3,g3,b3,a3 = colorPalettes [3]:update()
    
    --Update pSystem
    if thirdColor then 
        pSystem:setColors(r1,g1,b1,a1,r2,g2,b2,a2,r3,g3,b3,a3)
    else
        pSystem:setColors(r1,g1,b1,a1,r2,g2,b2,a2)
    end
    pSystem:setSizes(startSize, midSize, endSize)
    pSystem:update(dt)
    
    --Update save message timer
    if saveMessageTimer > 0 then
        saveMessageTimer = saveMessageTimer - dt
        if saveMessageTimer <= 0 then
            saveMessage = ''
        end
    end
end

function love.draw()
    --Draw particle system
    love.graphics.clear()
    love.graphics.setColor(WHITE)
    love.graphics.draw(pSystem, WINDOW_WIDTH/2, WINDOW_HEIGHT*2/3)

    --Draw all sliders and Labels
    love.graphics.setLineWidth(4)
    love.graphics.setColor(.25,.75,.75,1)
    for i, slider in pairs(sliders) do
        if type(slider) == 'string' then 
            love.graphics.printf(slider, PADDING, SLIDER_SPACING*i - 6, WINDOW_WIDTH, 'left')
        else
            slider:draw()
        end
    end

    --Draw color palettes
    for i, colorPalette in pairs(colorPalettes) do
        if i == 3 then 
            if thirdColor then 
                colorPalette:draw()
            end
        else 
            colorPalette:draw()
        end
    end

    --Draw texture buttons
    for i, textureButton in pairs(textureButtons) do
        textureButton:draw()
    end
    love.graphics.printf("Available Textures:", 0, textureLabelY - 30, WINDOW_WIDTH, 'center')

    infoPrint()
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    elseif key == 's' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
        saveParticleSystem()
    elseif key == 'o' and (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl')) then
        loadParticleSystem()
    end
end

--   *********** HELPER FUNCTIONS BELOW ***********

function infoPrint() --Print helpful info to screen top/center
    love.graphics.printf('Particle Count: '..string.format('%.2f',pSystem:getCount()), 0, 10, WINDOW_WIDTH, 'center')
    love.graphics.printf('Frames Per Second: '..string.format('%.2f', love.timer.getFPS()), 0, 30, WINDOW_WIDTH, 'center')
    if saveMessage ~= '' then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.printf(saveMessage, 0, 50, WINDOW_WIDTH, 'center')
        love.graphics.setColor(WHITE)
    end
    love.graphics.setColor(.5, .5, .5, 1)
    love.graphics.printf('Ctrl+S to Save | Ctrl+O to Load', 0, WINDOW_HEIGHT - 20, WINDOW_WIDTH, 'center')
    love.graphics.setColor(WHITE)
end

function setSliderXY()
    for i, slider in pairs(sliders) do
        if type(slider) ~= 'string' then
            slider:setXY(SLIDER_X, SLIDER_SPACING*i)
        end
    end
end

function populateTextureButtons() --Look for texutre files of specified type in the specified directory.
                                    --Add a textureButton to the table for each.
    local textureFiles = love.filesystem.getDirectoryItems( TEXTURE_DIRECTORY)
    for i, file in pairs(textureFiles) do
        if file:sub(-4,-1) == TEXTURE_IMAGE_FORMAT then 
            table.insert(textureButtons, newTextureButton(file)) 
        end
    end
end

function setTextureXY()
    local maxWidth = WINDOW_WIDTH - PADDING*4 - COLOR_PALETTE_WIDTH*2
    local totalWidth = #textureButtons * TEXTURE_BUTTON_WIDTH + (#textureButtons-1) * PADDING2
    local rowWidth
    if totalWidth > maxWidth then 
        rowWidth = maxWidth - maxWidth%(TEXTURE_BUTTON_WIDTH + PADDING2)
    else
        rowWidth = totalWidth
    end
    local rowStartX = WINDOW_WIDTH/2 - rowWidth/2
    local buttonY = WINDOW_HEIGHT - PADDING2 - TEXTURE_BUTTON_WIDTH
    local buttonX = rowStartX
    for i, textureButton in pairs(textureButtons) do
        textureButton:setXY(buttonX, buttonY)
        buttonX = buttonX + TEXTURE_BUTTON_WIDTH + PADDING2
        if buttonX + TEXTURE_BUTTON_WIDTH > rowStartX+rowWidth then 
            buttonX = rowStartX
            buttonY = buttonY - TEXTURE_BUTTON_WIDTH - PADDING2
        end
    end
    textureLabelY = buttonY
end

function populateColorPalettes()
    local cPY = WINDOW_HEIGHT - COLOR_PALETTE_WIDTH - PADDING
    local cP1X = PADDING
    local cP2X = WINDOW_WIDTH - COLOR_PALETTE_WIDTH - PADDING
    colorPalettes [1] = newColorPalette(PALETTE_IMAGE_PATH, cP1X, cPY, 'First Color')
    colorPalettes [2] = newColorPalette(PALETTE_IMAGE_PATH, cP2X, cPY, 'Second Color')
    colorPalettes [3] = newColorPalette(PALETTE_IMAGE_PATH, cP2X, cPY - COLOR_PALETTE_WIDTH -60 , 'Third Color')
end

function saveParticleSystem()
    -- Collect all slider values
    local sliderValues = {}
    for i, slider in pairs(sliders) do
        if type(slider) ~= 'string' then
            sliderValues[slider:getLabel()] = slider:getValue()
        end
    end
    
    -- Create save data table
    local saveData = {
        texture = currentTextureName,
        colors = {
            {r = r1, g = g1, b = b1, a = a1},
            {r = r2, g = g2, b = b2, a = a2},
            {r = r3, g = g3, b = b3, a = a3}
        },
        thirdColor = thirdColor,
        sizes = {
            start = startSize,
            mid = midSize,
            endSize = endSize
        },
        sliders = sliderValues
    }
    
    -- Convert to Lua code string
    local saveString = 'return {\n'
    saveString = saveString .. '    texture = "' .. saveData.texture .. '",\n'
    saveString = saveString .. '    thirdColor = ' .. tostring(saveData.thirdColor) .. ',\n'
    saveString = saveString .. '    colors = {\n'
    for i, color in ipairs(saveData.colors) do
        saveString = saveString .. string.format('        {r = %.6f, g = %.6f, b = %.6f, a = %.6f},\n', 
            color.r, color.g, color.b, color.a)
    end
    saveString = saveString .. '    },\n'
    saveString = saveString .. '    sizes = {\n'
    saveString = saveString .. string.format('        start = %.6f,\n', saveData.sizes.start)
    saveString = saveString .. string.format('        mid = %.6f,\n', saveData.sizes.mid)
    saveString = saveString .. string.format('        endSize = %.6f,\n', saveData.sizes.endSize)
    saveString = saveString .. '    },\n'
    saveString = saveString .. '    sliders = {\n'
    for label, value in pairs(saveData.sliders) do
        saveString = saveString .. string.format('        ["%s"] = %.6f,\n', label, value)
    end
    saveString = saveString .. '    }\n'
    saveString = saveString .. '}\n'
    
    -- Write to file using standard Lua io library for absolute paths
    local filePath = SAVE_DIRECTORY .. 'particle_system.lua'
    local file, err = io.open(filePath, 'w')
    if file then
        file:write(saveString)
        file:close()
        saveMessage = 'Particle system saved successfully!'
        saveMessageTimer = 3
    else
        -- Try creating directory if it doesn't exist
        os.execute('mkdir -p "' .. SAVE_DIRECTORY .. '"')
        file, err = io.open(filePath, 'w')
        if file then
            file:write(saveString)
            file:close()
            saveMessage = 'Particle system saved successfully!'
            saveMessageTimer = 3
        else
            saveMessage = 'Error saving: ' .. tostring(err)
            saveMessageTimer = 3
        end
    end
end

function loadParticleSystem()
    -- Check if save file exists using standard Lua io library
    local filePath = SAVE_DIRECTORY .. 'particle_system.lua'
    local file = io.open(filePath, 'r')
    if not file then
        saveMessage = 'No save file found!'
        saveMessageTimer = 3
        return
    end
    file:close()
    
    -- Load the save file
    local success, saveData = pcall(function()
        local chunk = loadfile(filePath)
        if chunk then
            return chunk()
        else
            return nil
        end
    end)
    
    if not success or not saveData then
        saveMessage = 'Error loading save file!'
        saveMessageTimer = 3
        return
    end
    
    -- Load texture
    if saveData.texture then
        local texturePath = TEXTURE_DIRECTORY .. saveData.texture .. TEXTURE_IMAGE_FORMAT
        if love.filesystem.getInfo(texturePath) then
            texture = love.graphics.newImage(texturePath)
            pSystem:setTexture(texture)
            currentTextureName = saveData.texture
        end
    end
    
    -- Load colors
    if saveData.colors then
        if saveData.colors[1] then
            r1, g1, b1, a1 = saveData.colors[1].r, saveData.colors[1].g, saveData.colors[1].b, saveData.colors[1].a
            colorPalettes[1].r, colorPalettes[1].g, colorPalettes[1].b, colorPalettes[1].a = r1, g1, b1, a1
            colorPalettes[1].slider.value = math.max(0, math.min(1, (a1 - colorPalettes[1].slider.min) / (colorPalettes[1].slider.max - colorPalettes[1].slider.min)))
            -- Set circle to center (visual indicator - actual color values are what matter)
            colorPalettes[1].circleX = colorPalettes[1].x + colorPalettes[1].width/2
            colorPalettes[1].circleY = colorPalettes[1].y + colorPalettes[1].width/2
        end
        if saveData.colors[2] then
            r2, g2, b2, a2 = saveData.colors[2].r, saveData.colors[2].g, saveData.colors[2].b, saveData.colors[2].a
            colorPalettes[2].r, colorPalettes[2].g, colorPalettes[2].b, colorPalettes[2].a = r2, g2, b2, a2
            colorPalettes[2].slider.value = math.max(0, math.min(1, (a2 - colorPalettes[2].slider.min) / (colorPalettes[2].slider.max - colorPalettes[2].slider.min)))
            colorPalettes[2].circleX = colorPalettes[2].x + colorPalettes[2].width/2
            colorPalettes[2].circleY = colorPalettes[2].y + colorPalettes[2].width/2
        end
        if saveData.colors[3] then
            r3, g3, b3, a3 = saveData.colors[3].r, saveData.colors[3].g, saveData.colors[3].b, saveData.colors[3].a
            colorPalettes[3].r, colorPalettes[3].g, colorPalettes[3].b, colorPalettes[3].a = r3, g3, b3, a3
            colorPalettes[3].slider.value = math.max(0, math.min(1, (a3 - colorPalettes[3].slider.min) / (colorPalettes[3].slider.max - colorPalettes[3].slider.min)))
            colorPalettes[3].circleX = colorPalettes[3].x + colorPalettes[3].width/2
            colorPalettes[3].circleY = colorPalettes[3].y + colorPalettes[3].width/2
        end
    end
    
    -- Load thirdColor flag
    if saveData.thirdColor ~= nil then
        thirdColor = saveData.thirdColor
    end
    
    -- Load sizes
    if saveData.sizes then
        if saveData.sizes.start then startSize = saveData.sizes.start end
        if saveData.sizes.mid then midSize = saveData.sizes.mid end
        if saveData.sizes.endSize then endSize = saveData.sizes.endSize end
    end
    
    -- Load slider values
    if saveData.sliders then
        for i, slider in pairs(sliders) do
            if type(slider) ~= 'string' then
                local label = slider:getLabel()
                if saveData.sliders[label] then
                    local value = saveData.sliders[label]
                    slider.value = (value - slider.min) / (slider.max - slider.min)
                    slider.value = math.max(0, math.min(1, slider.value))
                    if slider.setter then
                        slider.setter(value)
                    end
                end
            end
        end
    end
    
    saveMessage = 'Particle system loaded successfully!'
    saveMessageTimer = 3
end