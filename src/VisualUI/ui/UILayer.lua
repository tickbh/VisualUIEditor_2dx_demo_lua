local UILayer=class("UILayer", function(data, parent)
    return cc.Node:create()
end)
cc.exports.UILayer=UILayer

function UILayer:ctor(data, parent)
    CocosGenBaseNodeByData(GetCurJsonData(data), self, true, self)
end

function UILayer:eventListener(event)
    dump(event)
end

function UILayer:button(event)
    print("button callback")
    dump(event)
end
