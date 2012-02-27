require 'middleclass'

sceneControllers = {}
sceneControllersCount = 0

function pushSceneController(c)
    table.insert(sceneControllers, c)
    sceneControllersCount = sceneControllersCount + 1
    c:start()
end

function popSceneController()
    sceneControllers[sceneControllersCount]:stop()
    table.remove(sceneControllers)
    sceneControllersCount = sceneControllersCount - 1
end

SceneController = class('SceneController')

function SceneController:initialize()
end

function SceneController:start()
end

function SceneController:update(dt)
end

function SceneController:draw()
end

function SceneController:mousepressed(x, y, button)
end

function SceneController:mousereleased(x, y, button)
end

function SceneController:keypressed(key, unicode)
end

function SceneController:keyreleased(key, unicode)
end

function SceneController:stop()
end