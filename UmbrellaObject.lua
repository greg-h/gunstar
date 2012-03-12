require 'PhysicalObject'

UmbrellaObject = PhysicalObject:subclass('UmbrellaObject')

function UmbrellaObject:initialize(x, y)
    PhysicalObject.initialize(self, x, y, 1, 1)

    self.umbrellaImage = love.graphics.newImage("umbrella.png")
    self:setImage(self.umbrellaImage)

    self.setShapeFromSize = false
end

function UmbrellaObject:addedToScene(scene)
    PhysicalObject.addedToScene(self, scene)
    
    x0 = -self.width/2
    y0 = self.height/2
    
    self.stem = love.physics.newRectangleShape(self.body, 0, -15, 4, self.height-30, 0)
    self.stem:setDensity(1)
    self:addShape(self.stem)
    
    self.handle = love.physics.newRectangleShape(self.body, 0, -110, 20, 20, 0)
    self.handle:setDensity(600)
    self:addShape(self.handle)

    self.hood = love.physics.newPolygonShape(self.body, 
        x0 + 5,     y0 - 105,
        x0 + 75,    y0 - 45,
        x0 + 135,   y0 - 35,
        x0 + 195,   y0 - 45,
        x0 + 265,   y0 - 105)
    
    self.hood:setDensity(10)
    self.hood:setRestitution(0.60)
    self:addShape(self.hood)
    
    self.body:setMassFromShapes()
    self.body:setAngularDamping(5)
end