require 'SceneController'
require 'PhysicalObject'
-- TODO: fix camera and drawing coordinates

PhysicalSceneController = SceneController:subclass('PhysicalSceneController')

function PhysicalSceneController:start()
end

function PhysicalSceneController:log(...)
    s = string.format(unpack(arg))
    table.insert(self.debugTextLines, s)
    self.debugConsoleLines = self.debugConsoleLines + 1
    
    if self.debugConsoleLines > self.debugConsoleLinesMax then
        table.remove(self.debugTextLines, 1)
        self.debugConsoleLines = self.debugConsoleLines - 1
    end
end

function PhysicalSceneController:update(dt)    
    SceneController.update(self, dt)
    
    if self.mouseJoint then
        self.mouseJoint:setTarget(self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
    
    for key, object in pairs(self.objects) do
        object:update(dt)
        x = object.body:getX()
        y = object.body:getY()
        if x < -self.sceneBorder or y < -self.sceneBorder or x > (self.sceneWidth + self.sceneBorder) or y > (self.sceneHeight + self.sceneBorder) then
            object:didLeaveWorldBoundaries(self)
        end
        if object.shouldBeRemoved then
            self:removeObject(key)
        end
    end
    
    self.world:update(dt)
end

function PhysicalSceneController:getWorldPositionAtPosition(screenX, screenY)
    worldX = (screenX - (self.screenWidth/2))/self.cameraScale + self.cameraX
    worldY = -(screenY - (self.screenHeight/2))/self.cameraScale + self.cameraY
    return worldX, worldY
end

function PhysicalSceneController:draw()
    love.graphics.push()
    love.graphics.translate(self.screenWidth/2, self.screenHeight/2)
    love.graphics.scale(self.cameraScale, -self.cameraScale)
    love.graphics.translate(-self.cameraX, -self.cameraY)
    
    for k,v in pairs(self.objects) do
        v:draw()
    end
    love.graphics.pop()
    
    if self.showFPS then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(string.format("%2d fps", love.timer.getFPS()), self.screenWidth-64, 12)
    end
    
    if self.showDebugConsole then
        debugText = ""
        for i, line in ipairs(self.debugTextLines) do
            debugText = string.format("%s%s\n", debugText, line) 
        end
        
        debugText = debugText .. self.debugConsolePrompt .. self.debugConsoleScriptBuffer
        
        love.graphics.setColor(128, 128, 128, 128)
        love.graphics.rectangle("fill", 0, 0, self.sceneWidth, self.debugConsoleLinesMax * 15)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(debugText, 12, 5)
    end
end

function PhysicalSceneController:addObjectWithKey(object, key)
    assert(object) 
    assert(key)
    object:addedToScene(self)
    object.name = key
    self.objects[key] = object
    self.objectCount = self.objectCount +1
end

function PhysicalSceneController:getObject(key)
    return self.objects[key]
end

function PhysicalSceneController:removeObject(key)
    object = self.objects[key]
    if instanceOf(PhysicalObject, object) then
        object:removedFromScene(self)
        self.objectCount = self.objectCount -1
    end
        
    self.objects[key] = nil
end

function PhysicalSceneController:removeLastMouseObject()
    if self.lastMouseObject then
        self:removeObject(self.lastMouseObject.name)
    end
end

function PhysicalSceneController:mousepressed(x, y, button)
    if button == 'l' then
        wx, wy = self:getWorldPositionAtPosition(x, y)
        self:log("Clicked screen pos: (%d, %d), world pos: (%d, %d)", x, y, wx, wy)
    end
    if self.mouseInteract and button == 'l' then
        --find object at mouse position
        x, y = self:getWorldPositionAtPosition(x, y)
        self.lastMouseX = x
        self.lastMouseY = y
        self.mouseBody = love.physics.newBody(self.world, x, y, 0, 0)
        self.mouseShape = love.physics.newCircleShape(0, 0, 1)
        self.mouseFixture = love.physics.newFixture(self.mouseBody, self.mouseShape)
        self.mouseFixture:setSensor(true)
    end
end

function PhysicalSceneController:mousereleased(x, y, button)
    if self.mouseInteract and button == 'l' then
        if self.mouseJoint then
            self.mouseJoint:destroy()
            self.mouseJoint = nil
        end
        self.mouseFixture:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
        self.mouseShape = nil
        self.mouseBody = nil        
        self.mouseObject = nil
        self.mouseFixture = nil
    end
end

function PhysicalSceneController:runDebugScript(scriptText)
    self:log(self.debugConsolePrompt .. scriptText)
        
    local func, err
    func, err = loadstring(string.format("return function (self) %s end", scriptText))
    if not func then
        func, err = loadstring(string.format("return function (self) return %s end", scriptText))
        if not func then
            self:log("Error loading: %s", tostring(err))
            return
        end
    end
    
    output = func()(self)
    if output then
        self:log(tostring(output))
    end
end

function PhysicalSceneController:keypressed(key, unicode)
    if key == "`" and self.allowDebugConsole then
        self.debugConsoleScriptBuffer = ""
        self.showDebugConsole = not self.showDebugConsole
        return
    end
    
    if self.showDebugConsole then
        if key == 'return' then
            self:runDebugScript(self.debugConsoleScriptBuffer)
            self.debugConsoleScriptBuffer = ""
        elseif key == "backspace" then
            self.debugConsoleScriptBuffer = self.debugConsoleScriptBuffer:sub(1, self.debugConsoleScriptBuffer:len()-1)
        elseif unicode > 31 and unicode < 127 then
            self.debugConsoleScriptBuffer = self.debugConsoleScriptBuffer .. string.char(unicode)
        end
    end
end

function PhysicalSceneController:keyreleased(key, unicode)
end

function PhysicalSceneController:setCamera(x, y, scale)
    self.cameraX = x
    self.cameraY = y
    self.cameraScale = scale
end

function PhysicalSceneController:grabObjectWithMouse(object)
    self:log("Grabbed Obj: %s", object.name)
    self.mouseJoint = love.physics.newMouseJoint(object.body, self:getWorldPositionAtPosition(love.mouse.getPosition()))
end

function PhysicalSceneController:didSelectObjectWithMouse(object)
    self:grabObjectWithMouse(object)
end
    

function PhysicalSceneController:beginContact()
    return function (a, b, coll)
        if not self.mouseObject then
            if a == self.mouseShape then
                self.mouseObject = b['object']
                self.lastMouseObject = b['object']
                self:didSelectObjectWithMouse(b['object'])
            elseif b == self.mouseShape then
                self.mouseObject = a['object']
                self.lastMouseObject = a['object']
                self:didSelectObjectWithMouse(a['object'])
            end
        end
    end
end

function PhysicalSceneController:endContact()
    return function (a, b, coll)
    end
end

function PhysicalSceneController:preContactSolve()
    return function (a, b, coll)
    end
end


function PhysicalSceneController:postContactSolve()
    return function (a, b, coll)
    end
end



function PhysicalSceneController:stop()
end

function PhysicalSceneController:lastMousePos()
    return self.lastMouseX, self.lastMouseY
end

function PhysicalSceneController:initialize(sceneWidth, sceneHeight, sceneBorder)
    SceneController.initialize(self)
    self.sceneHeight = sceneHeight or 600
    self.sceneWidth = sceneWidth or 800
    self.sceneBorder = sceneBorder or 100
    self.world = love.physics.newWorld(-self.sceneBorder, -self.sceneBorder, self.sceneWidth+self.sceneBorder, self.sceneHeight+self.sceneBorder)
    self.objects = {}
    self.objectCount = 0
    self.cameraX = self.sceneWidth/2
    self.cameraY = self.sceneHeight/2
    self.cameraScale = 1
    self.cameraRotation = 0
    self.mouseInteract = false
    self.mouseBody = nil
    self.lastMouseX = 0
    self.lastMouseY = 0
    self.lastMouseObject = nil
    self.mouseObject = nil
    self.mouseJoint = nil
    self.mouseFixture = nil
    self.debugTextLines = {}
    self.showFPS = false
    self.showDebugConsole = false
    self.allowDebugConsole = false
    self.debugConsoleLines = 0
    self.debugConsoleLinesMax = 30
    self.debugConsolePrompt = "> "
    self.debugConsoleScriptBuffer = ""
    self.world:setCallbacks(self:beginContact(), self:endContact(), self:preContactSolve(), self:postContactSolve())
end