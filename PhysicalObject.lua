require 'middleclass'

PhysicalObject = class('PhysicalObject')

function PhysicalObject:initialize(x, y, bodyType)
    self.initialX = x
    self.initialY = y
    self.bodyType = bodyType
    self.width = 0
    self.height = 0
    self.drawables = {}
    self.drawingScale = 1
    self.shapes = {}
    self.fixtures = {}
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
        local shape = love.physics.newRectangleShape(0, 0, self.width, self.height, 0)
        self:addShapeWithDensity(shape, 1)
    end
end

function PhysicalObject:setImage(image)
    self.drawables = {}
    self.width = image:getWidth()
    self.height = image:getHeight()
    table.insert(self.drawables, image)
end

function PhysicalObject:setPlaceholderRectangle(r, g, b, a)    
    local renderRectangle = function (x, y, angle, drawingScaleX, drawingScaleY, offsetX, offsetY) 
        love.graphics.push()
        love.graphics.setColor(r, g, b, a)
        local w = self.width
        local h = self.height
        love.graphics.translate(x,y)
        love.graphics.rotate(angle)
        love.graphics.rectangle("fill", -(w/2), -(h/2), w, h)
        love.graphics.pop()
    end
    
    table.insert(self.drawables, renderRectangle)
end

function PhysicalObject:addedToScene(scene)
    --self.body = love.physics.newBody(scene.world, self.initialX, self.initialY, self.initialMass, self.initialRotationalInertia)
    self.body = love.physics.newBody(scene.world, self.initialX, self.initialY, self.bodyType)
    if self.setShapeFromSize then
        self:addShapeForSize()
    end
end

function PhysicalObject:addShapeForSize()
    if self.width and self.height then
        local shape = love.physics.newRectangleShape(0, 0, self.width, self.height)
        self:addShape(shape)
    end
end

function PhysicalObject:addShapeWithFixture(shape, fixture)
    assert(shape)
    assert(fixture)
    
    local collisionData = setmetatable({}, {__mode="kv"})
    collisionData['object'] = self
    collisionData['shape'] = shape
    collisionData['fixture'] = fixture
    
    fixture:setUserData(collisionData)

    table.insert(self.fixtures, fixture)
    table.insert(self.shapes, shape)
end

function PhysicalObject:addShapeWithDensity(shape, density)
    assert(shape)
    assert(density)
    local fixture = love.physics.newFixture(self.body, shape, density)
    self:addShapeWithFixture(shape, fixture)
end

function PhysicalObject:addShape(shape)
    assert(shape)
    local fixture = love.physics.newFixture(self.body, shape)
    self:addShapeWithFixture(shape, fixture)
end

function PhysicalObject:removedFromScene(scene)
    self.body:destroy()
    self.shapes = nil
    self.body = nil
    self.fixtures = nil
    self.drawables = nil
end

function PhysicalObject:didLeaveWorldBoundaries(scene)
    self.shouldBeRemoved = true
end

function PhysicalObject:deferredRemoval()
    self.shouldBeRemoved = true
end 

function PhysicalObject:update(dt)
end

-- TODO fix drawing coordinates for image vs. drawable when scaled.
function PhysicalObject:draw()
    local x = self.body:getX()
    local y = self.body:getY()
    local angle = self.body:getAngle()
    love.graphics.setColor(unpack(self.tint))
    for i,v in ipairs(self.drawables) do
        if type(v) == "function" then
            v(x, y, angle, self.drawingScale, self.drawingScale, 0, 0)
        else
            love.graphics.draw(v, x, y, angle, self.drawingScale, -self.drawingScale, (self.width/2)/self.drawingScale, (self.height/2)/self.drawingScale)
        end
    end
end