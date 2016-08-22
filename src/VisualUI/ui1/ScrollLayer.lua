local ScrollLayer=class("ScrollLayer", function()
    return cc.Node:create()
end)
cc.exports.ScrollLayer=ScrollLayer

function ScrollLayer:ctor(size,dir)
 
    local scroll=cc.ScrollView:create()
    self.viewSize=size
    scroll:setViewSize(size) 
      
    self.itemScale=1
    self.padding=0
    self.paddingX = nil
    self.paddingY = nil
    
    local container=cc.Node:create() 
    scroll:setContainer(container)
    self.items={}
    self.container=container
    self.scroll=scroll
    self:addChild(scroll)
    scroll:setAnchorPoint(cc.p(0,0))
    self:setContentSize(size) 
 
    self:setDir(dir)
    self.offsetX=0 
    self.offsetY=0
    self.eachLineNum=1
end


function ScrollLayer:getViewRect()
    local _viewSize=self.viewSize
    local screenPos = self:convertToWorldSpace(cc.p(0,0))

    local scaleX = self:getScaleX()
    local scaleY = self:getScaleY()
    local parent=self:getParent()
    while(parent~=nil)do

        scaleX  = scaleX*parent:getScaleX()
        scaleY  = scaleY* parent:getScaleY()
        parent=parent:getParent()
    end

    if(scaleX<0) then
        screenPos.x  = _viewSize.width*scaleX
        scaleX =scaleX -scaleX;
    end

    if(scaleY<0) then
        screenPos.y =screenPos.y + _viewSize.height*scaleY
        scaleY = scaleY-scaleY
    end
    return cc.rect(screenPos.x , screenPos.y , _viewSize.width*scaleX, _viewSize.height*scaleY)
        -- return cc.rect(screenPos.x- _viewSize.width*scaleX/2 , screenPos.y -_viewSize.height*scaleY/2 , _viewSize.width*scaleX, _viewSize.height*scaleY)
end

function ScrollLayer:resize(viewSize)
    self.scroll:setViewSize(viewSize) 
    self:setContentSize(viewSize)
    self.viewSize=viewSize
end


function ScrollLayer:setDir(dir)
    self.dir=dir
    self.scroll:setDirection(dir )
end
 
function ScrollLayer:clear()
    for key, var in pairs(self.items) do
        var:removeFromParent()
    end 
    self.items={} 
    self.container:setPosition(cc.p(0,0));
end
 

function ScrollLayer:addItem(node,index)
    if index == nil then
        table.insert(self.items,node)
    else
        table.insert(self.items,index+1,node)
    end
    node:setScale(self.itemScale) 
    self.container:addChild(node)
end

function ScrollLayer:insertItem(node,index)
    self:addItem(node,index);
end
 

function ScrollLayer:getItem(index)
    if index >= 0 and index < table.getn(self.items) then
        return self.items[index+1];
    end
    return nil;
end
  

function ScrollLayer:onTouchBegan(touch,event) 
    local ret= self.scroll:onTouchBegan(touch,event)
    if(ret==false)then 
        return false
    end 
    return true
end

function ScrollLayer:onTouchMoved(touch,event) 
    self.scroll:onTouchMoved(touch,event) 
end

function ScrollLayer:onTouchEnded(touch,event)
    self.scroll:onTouchEnded(touch,event) 
end

function ScrollLayer:layout(moveToUp) 
    local totalHeight=0
    local totalWidth=0
  
    if(self.dir==cc.SCROLLVIEW_DIRECTION_HORIZONTAL)then
        
       
    else
        local colNum=self.eachLineNum  
        local totalWidth=0
        local totalHeight=0
        for key,node in pairs(self.items) do
            local size=node:getContentSize()
            if (key-1) % colNum == 0 then
                totalHeight = totalHeight + size.height*node:getScale()
            end
            if(size.width*node:getScale()>totalWidth)then
                totalWidth=size.width*node:getScale()
            end
        end  
        self.container:setContentSize(cc.size( totalWidth,totalHeight));
        local itemPosY = totalHeight  
        local idx=0
        local itemPosX=0
        for key,node in pairs(self.items) do
            node:setPositionX(itemPosX )
            node:setPositionY(itemPosY)
            local size=node:getContentSize()
            if key % colNum == 0 then
                itemPosY = itemPosY - size.height*node:getScale()  
                itemPosX=0
            else
                itemPosX=itemPosX+ size.width*node:getScale()  
            end 
            idx=idx+1
        end
    end

end  

function ScrollLayer:sortItems(sortFunc)
    if #self.items == 0 then
        return
    end

    table.sort(self.items, sortFunc)
end


return ScrollLayer