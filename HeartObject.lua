require 'PhysicalObject'

HeartObject = PhysicalObject:subclass('HeartObject')

function HeartObject:initialize(x, y)
    PhysicalObject.initialize(self, x, y, 1, 1)

    self.heartImage = love.graphics.newImage("heart.png")
    self:setImage(self.heartImage)

    self.setShapeFromSize = false
end

function HeartObject:addedToScene(scene)
    PhysicalObject.addedToScene(self, scene)
    
    x0 = -self.width/2
    y0 = self.height/2
    
    self.drawingScale = 1
    circle = love.physics.newCircleShape(self.body, 0, 0, (4.0/10)*(self.height/2))
    self:addShape(circle)
    
    self.body:setMassFromShapes()
end