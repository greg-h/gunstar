require 'middleclass'
--require 'PhysicalSceneController'

PhysicalObject = class('PhysicalObject')

function PhysicalObject:initialize(x, y, mass, rotationalInertia)
    self.initialX = x
    self.initialY = y
    self.width = 0
    self.height = 0
    self.initialMass = mass
    self.initialRotationalInertia = rotationalInertia
    self.drawables = {}
    self.drawingScale = 1
    self.shapes = {}
    self.body = nil
    self.name = nil
    self.setBodyFromImage = false
end

function PhysicalObject:setSize(w, h)
    self.width = w
    self.height = h
    if self.body then
        shape = love.physics.newRectangleShape(self.body, 0, 0, self.width, self.height, 0)
        collisionData = {}
        collisionData['shape'] = shape
        collisionData['object'] = self
        shape:setData(collisionData)
    end
    table.insert(self.shapes, shape)
end

function PhysicalObject:setImage(image)
    self.drawables = {}
    self.width = image:getWidth()
    self.height = image:getHeight()
    table.insert(self.drawables, image)
    self.setBodyFromImage = true
end

function PhysicalObject:setPlaceholderRectangle(r, g, b, a)
    self.drawables = {}
    
    renderRectangle = function (x, y, angle, drawingScaleX, drawingScaleY, offsetX, offsetY) 
        love.graphics.setColor(r, g, b, a)
        w = self.width
        h = self.height
        love.graphics.rectangle("fill", x-(w/2), y-(h/2), w, h)
    end
    
    table.insert(self.drawables, renderRectangle)
end

function PhysicalObject:addedToScene(scene)
    self.body = love.physics.newBody(scene.world, self.initialX, self.initialY, self.initialMass, self.initialRotationalInertia)
    if self.width and self.height then
        shape = love.physics.newRectangleShape(self.body, 0, 0, self.width, self.height, 0)
        collisionData = {}
        collisionData['shape'] = shape
        collisionData['object'] = self
        shape:setData(collisionData)
    end
    table.insert(self.shapes, shape)
end

function PhysicalObject:removedFromScene(scene)
    for i,v in ipairs(self.shapes) do
        v:destroy()
    end
    self.shapes = nil
    
    self.body:destroy()
    self.body = nil
end

function PhysicalObject:update(dt)
end

function PhysicalObject:draw(cameraX, cameraY, cameraScale)
    x = self.body:getX()
    y = self.body:getY()
    angle = self.body:getAngle()
    for i,v in ipairs(self.drawables) do
        if type(v) == "function" then
            v(x, y, angle, self.drawingScale, self.drawingScale, self.width/2, self.height/2)
        else
            love.graphics.draw(v, x, y, angle, self.drawingScale, self.drawingScale, self.width/2, self.height/2)
        end
    end
end