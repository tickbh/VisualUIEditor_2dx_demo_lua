local UILayer=class("UILayer", function()
    return cc.Node:create()
end)
cc.exports.UILayer=UILayer
cc.exports.temp=""


function UILayer:onEnter()
    EventManager:regster(self)

    if(self.inited==true)then
        return
    end
    self.UiItems={}
    self.inited=true
    local filePath=cc.FileUtils:getInstance():fullPathForFilename("ui/"..self.name..".ui")
    local content = cc.FileUtils:getInstance():getStringFromFile(filePath);
    local jsonData = cjson.decode(content)
    self:initDisplayPro(jsonData,self)
    self:onInited()
end


function UILayer:onInited()

end



function UILayer:changeTexture(name,path)
    local btn=self:getUI(name)
    if(btn)then
        if btn.setTexture then
            btn:setTexture(path)
        elseif btn.updateWithSprite then
            local sprite = cc.Sprite:create(path);
            local originSize = btn:getContentSize();
            local rect = cc.rect(0,0,0,0);
            btn:updateWithSprite(sprite,rect,false,btn.centerRect);
            btn:setPreferredSize(originSize);
        end
    end
end

function UILayer:onExit()
    EventManager:unregster(self)
end

function UILayer:initChildren(jsonData,node)
    if(jsonData.children==nil)then
        return
    end

    for key, childData in pairs(jsonData.children) do
        local display=self:createDisplay(childData,node)
        if(display)then
            node:addChild(display)
            self:initDisplayPro(childData,display)
            self:initDisplayPos(childData,display)
        end
    end
end

function UILayer:initDisplayPos(jsonData,display)
    local pos=self:getJsonPosition(jsonData,display:getParent())
    if(display:getParent().__type )then
        pos.y=pos.y+display:getParent():getContentSize().height
    end
    display:setPosition(pos)
end

function UILayer:initDisplayPro(jsonData,display)
    local size=self:getJsonSize(jsonData,display:getParent())
    if(size)then
        display:setContentSize(size)
    end
    self:initChildren(jsonData,display)

    local scaleX,scaleY=self:getJsonScale(jsonData)
    display:setScaleX(scaleX)
    display:setScaleY(scaleY)

    if(jsonData.touchEnable==1)then
        self:addTouchNode(display,jsonData.id,jsonData.touchEffect)
    end

    if(jsonData.alpha )then
        display:setOpacity(jsonData.alpha*255/100)
    end
    display.id=jsonData.id


    if(jsonData.anchor)then
        assert(loadstring("temp= "..jsonData.anchor))()
        display:setAnchorPoint(cc.p(tonumber(temp[1]),tonumber(temp[2])))

    end
end


function UILayer:createDisplay(jsonData,parent)
    local display=nil
    if(jsonData.type=="node")then
        display=cc.Node:create()
        display:setAnchorPoint(cc.p(0,1))
    elseif(jsonData.type=="flash")then
        loadFlaXml(jsonData.path)
        display=FlashAni.new()
        display:playAction(jsonData.symbol)
    elseif(jsonData.type=="sprite")then
        display=cc.Sprite:create("images/"..jsonData.image)
        display:setAnchorPoint(cc.p(0,1))
    elseif(jsonData.type=="label")then
        display=self:createLabel(jsonData)

    elseif(jsonData.type=="sprite9")then
        display=self:createScale9Sprite(jsonData)
        display:setAnchorPoint(cc.p(0,1))

    elseif(jsonData.type=="progress")then
        display=self:createProgress(jsonData)
        display:setAnchorPoint(cc.p(0,1))
    elseif(jsonData.type=="rtfLabel")then
        display=self:createRTFLayer(jsonData,parent)

    elseif(jsonData.type=="scroll")then
        display=self:createScrollLayer(jsonData,parent)
        display:setAnchorPoint(cc.p(0,1))

    end
    if(display)then
        display.__type=jsonData.type
    end

    if(jsonData.id)then
        self.UiItems[jsonData.id]=display
    end
    return display
end


function UILayer:setPercent(id,num)
    local ui= self.UiItems[id]
    if(ui and ui.setPercentage)then
        ui:setPercentage(num*100)
    end
end

function UILayer:setString(id,words)
    local ui= self.UiItems[id]
    if(ui)then

        if(ui.clear)then
            ui:clear();
            ui:setString(words);
            ui:layout();
        elseif(ui.setString)then
            ui:setString(words)
        elseif(ui.setText)then
            ui:setText(words)
        end
    end
end

function UILayer:getUI(id)
    return self.UiItems[id]
end


function UILayer:createProgress(jsonData)
    local display=cc.ProgressTimer:create(cc.Sprite:create("images/"..jsonData.image))
    assert(loadstring("temp= "..jsonData.middlePoint))()
    display:setMidpoint(cc.p(temp[1],temp[2]))
    assert(loadstring("temp= "..jsonData.changeRate))()
    display:setBarChangeRate(cc.p(temp[1],temp[2]))
    display:setType(jsonData.progressType)
    display:setPercentage( 70)
    return display
end


function UILayer:createScale9Sprite(jsonData)


    assert(loadstring("temp= "..jsonData.rect))()
    local left = tonumber(temp[1]);
    local right =  tonumber(temp[2]);
    local up = tonumber(temp[3]);
    local down = tonumber(temp[4]);
    local texture = cc.Director:getInstance():getTextureCache():addImage("images/"..jsonData.image)
    local centerW = texture:getContentSize().width - left - right;
    local centerH = texture:getContentSize().height - up - down;
    local centerRect = cc.rect(left,up,centerW,centerH);

    local display = ccui.Scale9Sprite:create(centerRect,"images/"..jsonData.image)
    display:setContentSize(display:getContentSize())
    display.centerRect=centerRect
    return display
end


function UILayer:createRTFLayer(jsonData,parent)

    local display= RTFLayer.new(self:getPercentValue(jsonData.width,parent:getContentSize().width))

    local fontSize=20
    if jsonData.fontSize~=nil then
        fontSize=jsonData.fontSize
    end

    if(jsonData.color==nil)then
        jsonData.color="{255,255,255,255}"
    end
    assert(loadstring("temp= "..jsonData.color))()
    display:setDefaultConfig(gFont,fontSize,cc.c3b(temp[1],temp[2],temp[3]));
    return display
end

function UILayer:createScrollLayer(jsonData,parent)
    local width=self:getPercentValue(jsonData.width,parent:getContentSize().width)
    local height=self:getPercentValue(jsonData.height,parent:getContentSize().height)
    local display=ScrollLayer.new(cc.size(width,height),jsonData.dir)

    return display
end


function UILayer:createLabel(jsonData)

    local display=nil;
    local fontSize=20
    if jsonData.fontSize~=nil then
        fontSize=jsonData.fontSize
    end

    local words=jsonData.words
    display = cc.Label:create()
    display:setSystemFontSize(fontSize)
    display:setSystemFontName(gFont)



    if(jsonData.color==nil)then
        jsonData.color="{255,255,255,255}"
    end
    if(jsonData.dimensions~=nil)then
        assert(loadstring("  temp= "..jsonData.dimensions))()
        display:setDimensions( temp[1],temp[2])
    end


    assert(loadstring("temp= "..jsonData.color))()

    display.color = cc.c3b(temp[1],temp[2],temp[3]);
    display:setColor(cc.c3b(temp[1],temp[2],temp[3]));
    display:setOpacity(temp[4]);

    if(jsonData.align==1)then
        display:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    elseif(jsonData.align==2)then
        display:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    elseif(jsonData.align==3)then
        display:setHorizontalAlignment(cc.TEXT_ALIGNMENT_RIGHT)
    end
    display:setString(words);

    if(jsonData.outlineColor ) then
        local outlineColor = {255,255,255,255};
        local outlineOffset = 0.2;

        assert(loadstring("  temp= "..jsonData.outlineColor))();
        outlineColor = cc.c4b(temp[1],temp[2],temp[3],temp[4]);
        if(jsonData.outlineOffset)then
            outlineOffset = jsonData.outlineOffset;
        end
        display:enableOutline(outlineColor,fontSize*outlineOffset);
    end



    return display
end

function UILayer:getJsonSize(jsonData,parent)
    if(jsonData.width==nil or jsonData.height==nil)then
        return nil
    end
    local parentSize=parent:getContentSize()

    local width=self:getPercentValue(jsonData.width,parentSize.width)
    local height=self:getPercentValue(jsonData.height,parentSize.height)
    return cc.size(width,height)
end

function UILayer:getPercentValue(value,num)

    if( string.sub(value,-1)=="%")then
        local per= string.sub(value,1,-2)/100
        return per*num
    else
        return value
    end

end


function UILayer:getJsonScale(jsonData,parent)

    local scaleX=1
    local scaleY=1

    if( jsonData.scaleX)then
        scaleX=jsonData.scaleX
    end

    if( jsonData.scaleY)then
        scaleY=jsonData.scaleY
    end

    if( jsonData.scale)then
        scaleX=jsonData.scale
        scaleY=jsonData.scale
    end

    return scaleX,scaleY
end

function UILayer:getJsonPosition(jsonData,parent)
    local x=0
    local y=0

    local parentSize=parent:getContentSize()
    if(jsonData.left)then
        x=self:getPercentValue(jsonData.left,parentSize.width)
    elseif(jsonData.right)then
        x=parentSize.width- self:getPercentValue(jsonData.right,parentSize.width)
    elseif(jsonData.center)then
        x=parentSize.width/2+self:getPercentValue(jsonData.center,parentSize.width)
    elseif(jsonData.x)then
        x=self:getPercentValue(jsonData.x,parentSize.center)
    end

    if(jsonData.top)then
        y=self:getPercentValue(jsonData.top,parentSize.height)
    elseif(jsonData.bottom)then
        y=parentSize.height-self:getPercentValue(jsonData.bottom,parentSize.height)
    elseif(jsonData.horizontal)then
        y=parentSize.height/2+self:getPercentValue(jsonData.horizontal,parentSize.height)
    elseif(jsonData.y)then
        y=self:getPercentValue(jsonData.y,parentSize.height)
    end
    return cc.p(x, -y)
end


function UILayer:init(name)

    self.name=name
    local function onNodeEvent(event)
        if event == "enter" then
            self:onEnter();
        elseif event == "exit" then
            self:onExit();
        end
    end
    self:registerScriptHandler(onNodeEvent);
end

function UILayer.modifyNodeAnchorPoint(node,anchorPoint)
    if(node:getAnchorPoint().x == anchorPoint.x and node:getAnchorPoint().y == anchorPoint.y)then
        return;
    end
    local size = node:getContentSize();
    local old_anchorPoint = node:getAnchorPoint();
    local old_pos = cc.p(node:getPosition());
    local scale = node:getScale();
    local pos = cc.p(old_pos.x - size.width * old_anchorPoint.x * scale
        ,old_pos.y - size.height * old_anchorPoint.y * scale);
    pos = cc.p(pos.x + size.width * anchorPoint.x * scale,pos.y + size.height * anchorPoint.y * scale);
    node:setPosition(pos);
    node:setAnchorPoint(anchorPoint);
end

function UILayer.setTouchBeganEffect(target,type)
    if( (target.touchEffect)=="scale")then
        UILayer.modifyNodeAnchorPoint(target,cc.p(0.5,0.5));
        target.preScaleX=target:getScaleX()
        target.preScaleY=target:getScaleY()
        target:setScaleX(target.preScaleX*0.9)
        target:setScaleY(target.preScaleY*0.9)
    else


    end
end


function UILayer.setTouchEndEffect(target,type)
    if(target.touchEffect=="scale")then
        if target.preScaleX then
            target:setScaleX(target.preScaleX)
        end
        if target.preScaleY then
            target:setScaleY(target.preScaleY)
        end

    else
    end
end



function UILayer.checkTargetVisible(target)
    local parent=target
    while(parent)do
        if(parent:isVisible()==false or ( parent.scroll==nil and parent.touchEnable==false))then
            return false
        end
        parent=parent:getParent()
    end

    return true
end
function UILayer._onTouchBegan(touch, event)
    local location = touch:getLocation()
    local target=  event:getCurrentTarget()
    local rect   = target:getBoundingBox()


    if(target.touchLayer.touchEnable==false)then
        return true;
    end

    local parent=target:getParent();


    local isInSide=false
    local nodeLocation= target:getParent():convertToNodeSpace(location)
    isInSide=cc.rectContainsPoint(rect, nodeLocation)


    if isInSide then

        if( UILayer.checkTargetVisible(target) and target.__touchable)then

            local scrollParent=nil
            target._isScollMove=false
            target._hasScrollParent=false

            local parent=target:getParent()
            while(parent~=nil)do
                if(parent.__cname=="ScrollLayer")then
                    local ret= parent:onTouchBegan(touch,event)
                    scrollParent=parent
                    if(ret)then
                        target._isScollMove=false
                        target._hasScrollParent=true
                        target._touchBeginPosX=location.x
                        target._touchBeginPosY=location.y
                    end
                    break
                end
                parent=parent:getParent()
            end

            if(scrollParent)then
                local rect=scrollParent:getViewRect()
                local inSideScroll=cc.rectContainsPoint(rect, location)
                if(inSideScroll==false)then
                    return false
                end
            end

            UILayer.setTouchBeganEffect(target)
            target.touchLayer:onTouchBegan(target,touch, event)
            return true;
        end
    end
    return false
end

function UILayer._onTouchMoved(touch, event)
    local location = touch:getLocation()
    local target=  event:getCurrentTarget()
    target.touchLayer:onTouchMoved(target,touch, event)
    if(target._hasScrollParent)then
        local parent=target:getParent()
        while(parent~=nil)do
            if(parent.__cname=="ScrollLayer")then
                parent:onTouchMoved(touch,event)
                if(cc.pGetDistance(cc.p(target._touchBeginPosX,target._touchBeginPosY),
                    cc.p(location.x,location.y))>30)then
                    target._isScollMove=true
                end
                break
            end
            parent=parent:getParent()
        end

    end
end


function UILayer._onTouchEnded(touch, event)
    local location = touch:getLocation()
    local target=  event:getCurrentTarget()
    local rect   = target:getBoundingBox()

    if(target.touchLayer.touchEnable==false)then
        return ;
    end

    if(target._hasScrollParent)then
        local parent=target:getParent()
        while(parent~=nil)do
            if(parent.__cname=="ScrollLayer")then
                parent:onTouchEnded(touch,event)
                break
            end
            parent=parent:getParent()
        end
    end
    local isInSide=false
    local nodeLocation= target:getParent():convertToNodeSpace(location)
    isInSide=cc.rectContainsPoint(rect, nodeLocation)


    UILayer.setTouchEndEffect(target)

    if(target.__touchend)then
        target.touchLayer:onTouchEnded(target,touch, event)
    elseif(target._isScollMove~=true)then
        if   isInSide then
            target.touchLayer:onTouchEnded(target,touch, event)
        end
    end

end

function UILayer:onTouchMoved(target,touch, event)


end
function UILayer:onTouchBegan(target,touch, event)


end

function UILayer:onTouchEnded(target,touch, event)


end

function UILayer:addTouchNode(node,var,effect)
    if(node==nil) then
        return
    end
    if(effect==nil)then
        effect="scale"
    end
    node.__touchable=true
    node.touchLayer=self
    node.touchEffect=effect
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(UILayer._onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(UILayer._onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(UILayer._onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(UILayer._onTouchEnded,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end