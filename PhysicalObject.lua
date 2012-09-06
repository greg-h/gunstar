require 'middleclass'

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
    self.setShapeFromSize = true
    self.shouldBeRemoved = false
    self.tint = {255, 255, 255, 255}
end

function PhysicalObject:setSize(w, h)
    self.width = w
    self.height = h
    if self.body then
        shape = love.physics.newRectangleShape(self.body, 0, 0, self.width, self.height, 0)
        self:addShape(shape)
    end
end

function PhysicalObject:setImage(image)
    self.drawables = {}
    self.width = image:getWidth()
    self.height = image:getHeight()
    table.insert(self.drawables, image)
end

function PhysicalObject:setPlaceholderRectangle(r, g, b, a)    
    renderRectangle = function (x, y, angle, drawingScaleX, drawingScaleY, offsetX, offsetY) 
        love.graphics.push()
        love.graphics.setColor(r, g, b, a)
        w = self.width
        h = self.height
        love.graphics.translate(x,y)
        love.graphics.rotate(angle)
        love.graphics.rectangle("fill", -(w/2), -(h/2), w, h)
        love.graphics.pop()
    end
    
    table.insert(self.drawables, renderRectangle)
end

function PhysicalObject:addedToScene(scene)
    self.body = love.physics.newBody(scene.world, self.initialX, self.initialY, self.initialMass, self.initialRotationalInertia)
    if self.setShapeFromSize then
        self:addShapeForSize()
    end
end

function PhysicalObject:addShapeForSize()
    if self.width and self.height then
        shape = love.physics.newRectangleShape(self.body, 0, 0, self.width, self.height, 0)
        self:addShape(shape)
    end
end

function PhysicalObject:addShape(shape)
    assert(shape)
    collisionData = {}
    collisionData['shape'] = shape
    collisionData['object'] = self
    shape:setData(collisionData)
    table.insert(self.shapes, shape)
end

function PhysicalObject:removedFromScene(scene)
    for i,shape in ipairs(self.shapes) do
        shape:setMask(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16)
    end
    self.shapes = nil
    self.body = nil
end

function PhysicalObject:didLeaveWorldBoundaries(scene)
    self.shouldBeRemoved = true
end

function PhysicalObject:update(dt)
end

-- TODO fix drawing coordinates for image vs. drawable when scaled.
function PhysicalObject:draw()
    x = self.body:getX()
    y = self.body:getY()
    angle = self.body:getAngle()
    love.graphics.setColor(unpack(self.tint))
    for i,v in ipairs(self.drawables) do
        if type(v) == "function" then
            v(x, y, angle, self.drawingScale, self.drawingScale, 0, 0)
        else
            love.graphics.draw(v, x, y, angle, self.drawingScale, -self.drawingScale, (self.width/2)/self.drawingScale, (self.height/2)/self.drawingScale)
        end
    end
end