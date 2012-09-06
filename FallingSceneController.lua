require 'PhysicalSceneController'
require 'UmbrellaObject'
require 'HeartObject'

FallingSceneController = PhysicalSceneController:subclass('FallingSceneController')

function FallingSceneController:initialize()
    PhysicalSceneController.initialize(self)
    
    self.unnamedObjectIndex = 0

    self.mouseInteract = true
    self.showFPS = true
    self.allowDebugConsole = true
    
    self.umbrellaJoint = nil
    
    self.world:setGravity(0, -600)
    self.cameraScale = 1
    
    self.lastHeart = love.timer.getTime()
    
    -- create floor
    floor = PhysicalObject:new(400, 0, "static")
    floor:setSize(1000, 10)
    floor:setPlaceholderRectangle(100, 200, 100, 255)
    self:addObjectWithKey(floor, "floor")
    
    -- create umbrella
    self:createUmbrella()
end

function FallingSceneController:createUmbrella()
    self.umbrellaObject = UmbrellaObject:new(400, 600)
    self:addObjectWithKey(self.umbrellaObject, "umbrella")
end

function FallingSceneController:createHeart()
    obj = HeartObject:new(math.random(10, 790), 600)
    self:addObjectWithKey(obj, string.format("heart%d", self.unnamedObjectIndex))
    self.unnamedObjectIndex = self.unnamedObjectIndex + 1
end

function FallingSceneController:mousepressed(x, y, button)
    PhysicalSceneController.mousepressed(self, x, y, button)
    
    if button == 'l' and self.umbrellaJoint then
        self.umbrellaJoint:destroy()
        self.umbrellaJoint = nil 
    elseif button == 'l' and not self.umbrellaJoint then
        self:log("Grabbed umbrella")
        self.umbrellaJoint = love.physics.newMouseJoint(self.umbrellaObject.body, self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
end

function FallingSceneController:mousereleased(x, y, button)
    PhysicalSceneController.mousereleased(self, x, y, button)
    
    
end

function FallingSceneController:update(dt)
    PhysicalSceneController.update(self, dt)
    
    currentTime = love.timer.getTime()
    if currentTime - self.lastHeart  > 0.33 then
        self:createHeart()
        self.lastHeart = currentTime
    end
    
    if not self.umbrellaObject then
        self:createUmbrella()
    end

    if self.umbrellaJoint then
        self.umbrellaJoint:setTarget(self:getWorldPositionAtPosition(love.mouse.getPosition()))
    end
end

function FallingSceneController:didSelectObjectWithMouse(object)
    -- do nothing
end

function FallingSceneController:beginContact()
    -- TODO: must confrom mouseobject to the scene/object collision objects
    --superCollision = PhysicalSceneController.didCollide(self)
    return function (a, b, coll)
        --superCollision(a, b, coll)
        
        heart = nil
        umbrella = nil
        floor = nil
        
        for k, objectData in pairs({a:getUserData(), b:getUserData()}) do
            object = objectData['object']
            if instanceOf(HeartObject, object) then
                heart = object
            elseif instanceOf(UmbrellaObject, object) then
                umbrella = object
            elseif object.name == "floor" then
                floor = object
            end
        end
        
        if heart and umbrella then
            self:log("%s collided with umbrella, h = %d", heart.name, heart.health)
            heart:collidedWithUmbrella()
        elseif heart and floor then
            self:log("%s collided with floor", heart.name)
            heart:collidedWithFloor()
        end
    end
end

function FallingSceneController:keypressed(key, unicode)
    PhysicalSceneController.keypressed(self, key, unicode)
    if not self.showDebugConsole then
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
            self:createHeart()
        end
    end
end

