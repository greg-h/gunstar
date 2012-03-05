require 'PhysicalSceneController'

HelloWorldSceneController = PhysicalSceneController:subclass('HelloWorldSceneController')


function HelloWorldSceneController:initialize()
    PhysicalSceneController.initialize(self)
    self.trollfaceImage = love.graphics.newImage("trollface.png")

    self.unnamedObjectIndex = 0
    self.mouseInteract = true
    self.showFPS = true
    
    self.world:setGravity(0, -500)
        
    --obj2 = PhysicalObject:new(30, 30, 0, 0)
    --obj2:setImage(self.trollfaceImage)
    --obj2:setSize(self.trollfaceImage:getHeight()*.75, self.trollfaceImage:getWidth()*.75)
    --self:addObjectWithKey(obj2, "stationary trollface")
    
    floor = PhysicalObject:new(400, 300, 0, 0)
    floor:setSize(5, 5)
    floor:setPlaceholderRectangle(255, 255, 255, 255)
    self:addObjectWithKey(floor, "center")
end

function HelloWorldSceneController:keypressed(key, unicode)
    PhysicalSceneController.keypressed(self, x, y, button)

    if key == 'a' then
        self.cameraScale = self.cameraScale * 1.111
    elseif key == 'z' then
        self.cameraScale = self.cameraScale * 0.9
    elseif key == 'left' then
        self.cameraX = self.cameraX - 10
    elseif key == 'right' then
        self.cameraX = self.cameraX + 10
    elseif key == 'up' then
        self.cameraY = self.cameraY + 10
    elseif key == 'down' then
        self.cameraY = self.cameraY - 10
    elseif key == 'r' then
        obj = PhysicalObject:new(math.random(-10, 10)+400, 500, 1, 1)
        obj:setImage(self.trollfaceImage)
        obj:setSize(self.trollfaceImage:getHeight()*.75, self.trollfaceImage:getWidth()*.75)
        self:addObjectWithKey(obj, string.format("trollface%d", self.unnamedObjectIndex))
        self.unnamedObjectIndex = self.unnamedObjectIndex + 1
    end
end

function HelloWorldSceneController:mousepressed(x, y, button)
    PhysicalSceneController.mousepressed(self, x, y, button)
    --[[
    if button == 'l' then
        x, y = self:getWorldPositionAtPosition(love.mouse.getPosition())
        obj = PhysicalObject:new(x, y, 1, 1)
        obj:setImage(self.trollfaceImage)
        obj:setSize(self.trollfaceImage:getHeight()*.75, self.trollfaceImage:getWidth()*.75)
        self:addObjectWithKey(obj, string.format("trollface%d", self.unnamedObjectIndex))
        self.unnamedObjectIndex = self.unnamedObjectIndex + 1
    end
    ]]
end