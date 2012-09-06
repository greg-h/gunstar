require 'middleclass'

sceneControllers = {}
sceneControllersCount = 0

function pushSceneController(c)
    if sceneControllersCount < 0 then
        sceneControllers[sceneControllersCount]:stop()
    end
    table.insert(sceneControllers, c)
    sceneControllersCount = sceneControllersCount + 1
    c:pushed()
    c:start()
end

function popSceneController()
    sceneControllers[sceneControllersCount]:stop()
    sceneControllers[sceneControllersCount]:popped()
    table.remove(sceneControllers)
    sceneControllersCount = sceneControllersCount - 1
    sceneControllers[sceneControllersCount]:start()
end

SceneController = class('SceneController')

function SceneController:initialize()
end

function SceneController:pushed()
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

function SceneController:popped()
end