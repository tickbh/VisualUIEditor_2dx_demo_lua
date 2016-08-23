
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
CC_DISABLE_GLOBAL = false

-- cjson = require "cjson"
require "config"
require "cocos.init"
require "VisualUI.init"

local function main()
    local scene = display.newScene("MAIN_SCENE_CLASS")
    local node = UILayer:create("ui/test.ui")
    scene:addChild(node)

    -- display.newSprite("HelloWorld.png")
    --     :move(display.center)
    --     :addTo(scene)
    display.runScene(scene)
    -- require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
