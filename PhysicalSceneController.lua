require 'SceneController'
require 'PhysicalObject'

PhysicalSceneController = SceneController:subclass('PhysicalSceneController')

function PhysicalSceneController:start()
end

function PhysicalSceneController:update(dt)    
    if self.mouseJoint then
        self.mouseJoint:setTarget(self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
    
    for i,v in ipairs(self.objects) do
        v:update(dt)
    end
    
    self.world:update(dt)
end

function PhysicalSceneController:getWorldPositionAtPosition(x, y)
    return (x-self.sceneHeight)/self.cameraScale, (y-self.sceneWidth)/self.cameraScale
end

function PhysicalSceneController:draw()
    
    love.graphics.push()
    love.graphics.translate(self.sceneHeight, self.sceneWidth)
    love.graphics.scale(self.cameraScale, self.cameraScale)
    love.graphics.translate(-self.cameraX, -self.cameraY)

    for k,v in pairs(self.objects) do
        v:draw(self.cameraX, self.cameraY, self.cameraScale)
    end
    love.graphics.pop()
    
    if self.debugText then
        love.graphics.print(self.debugText, 12, 12)
    end
    
    if self.showFPS then
        love.graphics.print(string.format("%2d fps", love.timer.getFPS()), self.sceneWidth-64, 12)
    end
    
end

function PhysicalSceneController:addObjectWithKey(object, key)
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
    if not object == nil then
        object:removedFromScene(self)
        self.objectCount = self.objectCount -1
    end
    
    for i,shape in ipairs(object.shapes) do
        shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    end 
    
    self.objects[key] = nil
end

function PhysicalSceneController:mousepressed(x, y, button)
    if self.mouseInteract and button == 'l' then
        --find object at mouse position
        x, y = self:getWorldPositionAtPosition(love.mouse.getPosition())
        self.mouseBody = love.physics.newBody(self.world, x, y, 0, 0)
        self.mouseShape = love.physics.newCircleShape(self.mouseBody, 0, 0, 1)
        self.mouseShape:setSensor(true)
        self.mouseShape:setData(self.mouseShape)
    end
end

function PhysicalSceneController:mousereleased(x, y, button)
    if self.mouseInteract and button == 'l' then
        if self.mouseJoint then
            self.mouseJoint:destroy()
            self.mouseJoint = nil
        end
        self.mouseShape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
        self.mouseShape = nil
        self.mouseBody = nil        
        self.mouseObject = nil
    end
end

function PhysicalSceneController:keypressed(key, unicode)
end

function PhysicalSceneController:keyreleased(key, unicode)
end

function PhysicalSceneController:setCamera(x, y, scale)
    self.cameraX = x
    self.cameraY = y
    self.cameraScale = scale
end

function PhysicalSceneController:didCollide()
    return function (a, b, coll)
        if not self.mouseObject then
            if a == self.mouseShape then
                self.mouseObject = b['object']
                self.debugText = string.format("Obj: %s", self.mouseObject.name)
                self.mouseJoint = love.physics.newMouseJoint(b['object'].body, self:getWorldPositionAtPosition(love.mouse.getPosition()))
            elseif b == self.mouseShape then
                self.mouseObject = a['object']
                self.debugText = string.format("Obj: %s", self.mouseObject.name)
                self.mouseJoint = love.physics.newMouseJoint(a['object'].body, self:getWorldPositionAtPosition(love.mouse.getPosition()))
            end
        end
    end
end

function PhysicalSceneController:didUncollide()
    return function (a, b, coll)
    end
end

function PhysicalSceneController:isTouching()
    return function (a, b, coll) 
    end
end

function PhysicalSceneController:stop()
end

function PhysicalSceneController:initialize()
    self.sceneHeight = 300
    self.sceneWidth = 400
    self.world = love.physics.newWorld(-self.sceneHeight, -self.sceneHeight, self.sceneWidth, self.sceneWidth, 0, 1, true)
    self.objects = {}
    self.objectCount = 0
    self.cameraX = 0
    self.cameraY = 0
    self.cameraScale = 1
    self.mouseInteract = false
    self.mouseBody = nil
    self.mouseObject = nil
    self.mouseJoint = nil
    self.debugText = nil
    self.showFPS = false
    self.world:setCallbacks(self:didCollide(), self:isTouching(), self:didUncollide(), nil)
end