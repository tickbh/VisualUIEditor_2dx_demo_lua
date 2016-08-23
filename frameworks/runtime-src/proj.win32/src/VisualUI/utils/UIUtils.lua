
local PathTemple = {}

function CheckPathRepeat(node, path)
    local parent = node
    while parent do
        if path == parent._path or path == parent._sceneSubPath then
            return true
        end
        parent = parent:getParent()
    end
    return false
end

function RegisterPathTemple(path, layer)
    PathTemple[path] = layer
end

function GetPathTemple(path)
    return PathTemple[path]
end

function GetCurJsonData(info)
    dump(info)
    if type(info) == "string" then
        local jsonData = GetJsonDataFromUI(info)
        if not jsonData then
            return nil
        end
        return jsonData
    elseif type(info) == "table" then
        return info
    end
    return nil
end

function CovertToColor(value)
    if not value or not value[0] or not value[3] then
        return nil
    end
    return cc.c4b(value[0], value[1], value[2], value[3])
end

function CocosGenBaseNodeByData(data, parent, isSetParent)
    dump(data)
    if not data then
        return
    end


    local node = nil
    if isSetParent then
        node = parent
    elseif data.path then
        if CheckPathRepeat(parent, data.path) then
            return nil
        end
        local temple = GetPathTemple(data.path)
        if not temple then
            temple = UILayer
        end
        node = temple:create(data.path, parent)
    elseif data.type == "Sprite" then
        node = cc.Sprite:create()
    elseif data.type == "Scale9" then
        node = ccui.Scale9Sprite:create()
    elseif data.type == "LabelTTF" then
        node = cc.LabelTTF:create()
        node:setString("aaaaaaaaaaaaaaaaaad")
        node:setPosition(cc.p(200, 300))
    elseif data.type == "Input" then
        node = ccui.EditBox:create(cc.size(100, 20),  ccui.Scale9Sprite:create())
    elseif data.type == "Slider" then
        node = ccui.Slider:create()
    elseif data.type == "CheckBox" then
        node = ccui.CheckBox:create()
    else
        node = cc.Node:create()
    end

    local _ = data.id and node:setName(data.id)
    if data.width or data.height then
        local setFn = node.setPreferredSize or node.setContentSize
        local width = tonumber(data.width) or node.getContentSize().width
        local height = tonumber(data.height) or node.getContentSize().height
        setFn(node, width, height)
    end

    local _ = data.x and node:setPositionX(tonumber(data.x))
    local _ = data.y and node:setPositionY(tonumber(data.y))

    local _ = data.left and node:setPositionX(tonumber(data.left))
    local _ = data.right and parent and node:setPositionX(parent.getContentSize().width - tonumber(data.right))

    local _ = data.bottom and node:setPositionY(tonumber(data.bottom))
    local _ = data.top and parent and node:setPositionY(parent.getContentSize().height - tonumber(data.top))

    if data.anchorX or data.anchorY then
        local anchorX = tonumber(data.anchorX) or node.getAnchorPoint().x
        local anchorY = tonumber(data.anchorY) or node.getAnchorPoint().y
        node:setAnchorPoint(anchorX, anchorY)
    end

    local _ = data.scaleX and node:setScaleX(tonumber(data.scaleX))
    local _ = data.scaleY and node:setScaleY(tonumber(data.scaleY))


    local _ = data.opacity and node:setOpacity(tonumber(data.opacity))
    local _ = data.rotation and node:setRotation(tonumber(data.rotation))

    local _ = data.visible and node:setVisible(data.visible)

    local color = CovertToColor(data.color)
    if color then
        node:setColor(color)
    end

    if data.type == "LabelTTF" then
        local _ = data.string and node:setString(data.string)
        local _ = data.textAlign and node:setHorizontalAlignment(data.textAlign)
        local _ = data.verticalAlign and node:setVerticalAlignment(data.verticalAlign)
        local _ = data.fontSize and node:setFontSize(data.fontSize)
        local _ = data.fontName and node:setFontName(data.fontName)
        local _ = data.string and node:setString(data.string)
        color = CovertToColor(data.fillStyle)
        local _ = color and node:setFontFillColor(color, true)
        -- color = CovertToColor(data.strokeStyle)
        -- local _ = color and node:setFontFillColor(color, true)

    elseif data.type == "Input" then

        local _ = data.string and node:setText(data.string)
        local _ = data.fontSize and node:setFontSize(data.fontSize)
        local _ = data.fontName and node:setFontName(data.fontName)
        color = CovertToColor(data.fontColor)
        local _ = color and node:setFontColor(color, true)
        local _ = data.maxLength and node:setMaxLength(data.maxLength)
        local _ = data.placeHolder and node:setPlaceHolder(data.placeHolder)
        local _ = data.placeHolderFontSize and node:setPlaceholderFontSize(data.placeHolderFontSize)
        local _ = data.placeHolderFontName and node:setPlaceholderFontName(data.placeHolderFontName)
        local _ = data.inputFlag and node:setInputFlag(data.inputFlag)
        local _ = data.inputMode and node:setInputMode(data.inputMode)
        local _ = data.returnType and node:setReturnType(data.returnType)
        
        -- local _ = data.inputMode and node:setInputMode(data.inputMode)
        -- local _ = data.inputMode and node:setInputMode(data.inputMode)
        -- local _ = data.inputMode and node:setInputMode(data.inputMode)
    end

--         data.inputFlag && (node.inputFlag = data.inputFlag);
--         data.inputMode && (node.inputMode = data.inputMode);
--         data.returnType && (node.returnType = data.returnType);

--         if(data.spriteBg && getFullPathForName(data.spriteBg)) {
--             let fullpath = getFullPathForName(data.spriteBg);
--             node.initWithBackgroundSprite(new cc.Scale9Sprite(fullpath));
--             node._spriteBg = data.spriteBg;
--         }

--     } else if(data.type == "Sprite") {
--         if(data.spriteFrame && getFullPathForName(data.spriteFrame)) {
--             let fullpath = getFullPathForName(data.spriteFrame);
--             node.init(fullpath);
--             node._spriteFrame = data.spriteFrame;
--         }
--         data.blendSrc && (node.setBlendFunc(parseInt(data.blendSrc), node.getBlendFunc().dst));
--         data.blendDst && (node.getBlendFunc().src, node.setBlendFunc(parseInt(data.blendDst)));
--     } else if(data.type == "Scale9") {
--         let size = node.getContentSize();

--         if(data.spriteFrame && getFullPathForName(data.spriteFrame)) {
--             let fullpath = getFullPathForName(data.spriteFrame);
--             node.initWithFile(fullpath);
--             node._spriteFrame = data.spriteFrame;
--         }

--         if(!cc.sizeEqualToSize(size, cc.size(0, 0))) {
--             node.setPreferredSize(size);
--         }

--         data.insetLeft && (node.insetLeft = data.insetLeft);
--         data.insetTop && (node.insetTop = data.insetTop);
--         data.insetRight && (node.insetRight = data.insetRight);
--         data.insetBottom && (node.insetBottom = data.insetBottom);
--     } else if(data.type == "Slider") {
--         (data["percent"]) && (node.percent = data["percent"]);
--         setNodeSpriteFrame("barBg", data["barBg"], node, node.loadBarTexture);
--         setNodeSpriteFrame("barProgress", data["barProgress"], node, node.loadProgressBarTexture);
--         setNodeSpriteFrame("barNormalBall", data["barNormalBall"], node, node.loadSlidBallTextureNormal);
--         setNodeSpriteFrame("barSelectBall", data["barSelectBall"], node, node.loadSlidBallTexturePressed);
--         setNodeSpriteFrame("barDisableBall", data["barDisableBall"], node, node.loadSlidBallTextureDisabled);
--     } else if(data.type == "Button") {
--         (data["percent"]) && (node.percent = data["percent"]);
--         setNodeSpriteFrame("bgNormal", data["bgNormal"], node, node.loadTextureNormal);
--         setNodeSpriteFrame("bgSelect", data["bgSelect"], node, node.loadTexturePressed);
--         setNodeSpriteFrame("bgDisable", data["bgDisable"], node, node.loadTextureDisabled);
        
--         (data["titleText"]) && (node.setTitleText(data["titleText"]));
--         (data["fontName"]) && (node.setTitleFontName(data["fontName"]));
--         (data["fontSize"]) && (node.setTitleFontSize(data["fontSize"]));
--         (data["fontColor"]) && (node.setTitleColor(covertToColor(data["fontColor"])));
--     } else if(node._className == "CheckBox") {
--         setNodeSpriteFrame("back", data["back"], node, node.loadTextureBackGround);
--         setNodeSpriteFrame("backSelect", data["backSelect"], node, node.loadTextureBackGroundSelected);
--         setNodeSpriteFrame("active", data["active"], node, node.loadTextureFrontCross);
--         setNodeSpriteFrame("backDisable", data["backDisable"], node, node.loadTextureBackGroundDisabled);
--         setNodeSpriteFrame("activeDisable", data["activeDisable"], node, node.loadTextureFrontCrossDisabled);

--         (data["select"]) && (node.setSelected(data["select"]));
--         (data["enable"]) && (node.setTouchEnabled(data["enable"]));
--     } else if(node._className == "Layout") {
--         setNodeSpriteFrame("backGroundImageFileName", data["bkImg"], node, node.setBackGroundImage);
--         (data["bkScaleEnable"]) && (node.setBackGroundImageScale9Enabled(data["bkScaleEnable"]));
        
--         (data["bkColorType"]) && (node.setBackGroundColorType(data["bkColorType"]));
--         (covertToColor(data.bkColor)) && (node.setBackGroundColor(covertToColor(data.bkColor)));
--         if(covertToColor(data.bkStartColor) && covertToColor(data.bkEndColor)) {
--             node.setBackGroundColor(covertToColor(data.bkStartColor), covertToColor(data.bkEndColor));
--         }

--         (data["layoutType"]) && (node.setLayoutType(data["layoutType"]));
--         (data["clippingEnabled"]) && (node.setClippingEnabled(data["clippingEnabled"]));
--         (data["clippingType"]) && (node.setClippingType(data["clippingType"]));


    for _,subdata in ipairs(data.children or {}) do
        local child = CocosGenBaseNodeByData(subdata, node)
        if child then
            node:addChild(child)
        end
    end

    return node
end