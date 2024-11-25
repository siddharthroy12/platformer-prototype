local scenemanager = {
    currentScene = nil
}

function scenemanager:changeScene(scene)
    scene.init()
    self.currentScene = scene
end

return scenemanager