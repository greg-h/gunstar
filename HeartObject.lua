require 'PhysicalObject'

HeartObject = PhysicalObject:subclass('HeartObject')

function HeartObject:initialize(x, y)
    PhysicalObject.initialize(self, x, y, "dynamic")

    self.heartImage = love.graphics.newImage("heart.png")
    self:setImage(self.heartImage)

    self.setShapeFromSize = false
    
    self.health = 100
end

function HeartObject:addedToScene(scene)
    PhysicalObject.addedToScene(self, scene)
    
    x0 = -self.width/2
    y0 = self.height/2
    
    self.drawingScale = 1
    circle = love.physics.newCircleShape(0, 0, (4.0/10)*(self.height/2))
    self:addShapeWithDensity(circle, 200)
    self.tint = {255,64,64,255}
    
    self.body:resetMassData()
    self.body:setAngularDamping(5)

end

function HeartObject:collidedWithUmbrella()
    if self.health <= 0 then
        self.shouldBeRemoved = true
        return
    end
    
    self.health = self.health - 20
    coef = (100.0 - self.health)/100.0
    self.tint = {255, 64 + coef*192, 64 + coef*192, 255}
    
    if self.health <= 0 then
        self.shouldBeRemoved = true
    end    
end