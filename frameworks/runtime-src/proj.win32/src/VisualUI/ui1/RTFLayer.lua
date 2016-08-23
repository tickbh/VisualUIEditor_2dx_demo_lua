local RTFLayer=class("RTFLayer", function()
    return cc.Node:create()
end)
cc.exports.RTFLayer=RTFLayer

 

function RTFLayer:ctor(width)
    
    self.richText = ccui.RichText:create();
    if width == nil then
        width = 0;
    end
    self.width = width;
    self:_initRichText();
    self:setAnchorPoint(cc.p(0,0)); 
    self:setDefaultConfig(gFont,20,cc.c3b(255,255,255));
    self.space = 0;
    self.maxNodeTag = 0;  
end

function RTFLayer:_initRichText()
    self.richText = ccui.RichText:create();
    self.richText:setCascadeOpacityEnabled(true);
    if self.width > 0 then
        --换行
        self.richText:ignoreContentAdaptWithSize(false);
        self.richText:setContentSize(cc.size(self.width, 0));
    else
        self.richText:ignoreContentAdaptWithSize(true);    
    end
    self.richText:setAnchorPoint(cc.p(0,0));
    self:addChild(self.richText);    
end

function RTFLayer:clear()
    -- body
    self.richText:removeFromParent();
    self.maxNodeTag = 0;
    self:_initRichText();
    self:setLineSpace(self.space);
end

function RTFLayer:getMaxNodeTag()
    self.maxNodeTag = self.maxNodeTag + 1;
    return self.maxNodeTag;
end

function RTFLayer:setLineSpace(space)
    self.space = space;
    self.richText:setVerticalSpace(space);
end

function RTFLayer:setDefaultConfig(font,fontsize,color)
    if font == "" or font == nil then
        font = gFont;
    elseif font == "0" then
        font = gCustomFont;    
    end
    self.defaultFont = font;
    self.defaultFontsize = fontsize;
    self.defaultColor = color;
end

function RTFLayer:setData(table_data)
    -- print_lua_table(table_data);
    for i,var in pairs(table_data) do
        local type = var.type;
        if type == "word" then
            self:addWord(var.word,var.font,var.fontsize,var.color,var.opacity,var.tag,var.outline_color,var.outline_offset);
        elseif type == "image" then
            self:addImage(var.imagePath,var.scale,var.opacity,var.color,var.tag);
        elseif type == "node" then
            self:addNode(var.node,var.opacity,var.color,var.tag);
        elseif type == "nextLine" then
            self:addNextLine();    
        end
    end
end

function RTFLayer:setString(str) 
    -- 替换换行符
    if(string.find(str,"\\n") == nil) then
        if(string.find(str,"\r\n")) then
            str = string.gsub(str, "\r\n", "\\n{}\\");
        else
            str = string.gsub(str, "\n", "\\n{}\\");
            str = string.gsub(str, "\r", "\\n{}\\");
        end
    end

    local datas = {};
    local words = string.split(str,"\\");
    for i,var in pairs(words) do
        if string.len(var) > 0 then
            local data = self:decodeOneWord(var);
            table.insert(datas,data);
        end
    end

    self:setData(datas);

end

function RTFLayer:setStringForCutWidth(str,cutWidth)

    local isNeedCut = false;
    -- 替换换行符
    if(string.find(str,"\\n") == nil) then
        if(string.find(str,"\r\n")) then
            str = string.gsub(str, "\r\n", "\\n{}\\");
        else
            str = string.gsub(str, "\n", "\\n{}\\");
            str = string.gsub(str, "\r", "\\n{}\\");
        end
    end

    local datas = {};
    local words = string.split(str,"\\");
    for i,var in pairs(words) do
        if string.len(var) > 0 then
            local data = self:decodeOneWord(var);
            table.insert(datas,data);
        end
    end

    -- print_lua_table(datas);

    local rtfNodes = {};
    local leftWidth = cutWidth;
    local nodeWidth = 0;
    for i,var in pairs(datas) do
        local type = var.type;
        if type == "word" then

            local font = var.font;
            if font == nil then
                font = self.defaultFont;
            end
            local fontsize = var.fontsize;
            if fontsize == nil then
                fontsize = self.defaultFontsize;
            end

            -- print("leftWidth = "..leftWidth);
            local cutWord,isCut = gGetWordWithWidth(var.word,font,fontsize,leftWidth);
            -- print("cutWord = "..cutWord);
            local node = clone(var);
            node.word = cutWord;
            table.insert(rtfNodes,node);
            if(isCut)then
                isNeedCut = true;
                break;
            else
                local lab = gCreateWordLabelTTF(cutWord,font,fontsize,cc.c3b(0,0,0));
                nodeWidth = lab:getContentSize().width;
                -- print("nodeWidth = "..nodeWidth);    
            end
            -- self:addWord(var.word,var.font,var.fontsize,var.color,var.opacity,var.tag,var.outline_color,var.outline_offset);
        elseif type == "image" then
            local rc = cc.Sprite:create(var.imagePath);
            if(rc)then
                nodeWidth = rc:getContentSize().width * var.scale;
                if(leftWidth>=nodeWidth)then
                    local node = clone(var);
                    table.insert(rtfNodes,node);
                else
                    isNeedCut = true;
                    break;    
                end
            end 
        elseif type == "node" then
            if(var.node)then
                nodeWidth = var.node:getContentSize().width;
                if(leftWidth>=nodeWidth)then
                    local node = clone(var);
                    table.insert(rtfNodes,node);
                else
                    isNeedCut = true;
                    break;    
                end
            end 
        elseif type == "nextLine" then 
            isNeedCut = true;
            break;    
        end

        leftWidth = leftWidth - nodeWidth;
    end 
    self:setData(rtfNodes);        


    return isNeedCut;
end


function RTFLayer:layout()
    self.richText:formatText();
    self:setContentSize(self.richText:getVirtualRendererSize());
 --   self:ignoreAnchorPointForPosition(false); 
end


function RTFLayer:decodeOneWord( str )
    -- body
    local ret = {};
    ret.type = "word";
    if string.sub(str,1,2) == "w{" then
        --w{c=ffffff;s=20;f=xxx}wordContent
        ret.type = "word";
        local pos = string.find(str,"}",2);
        if pos ~= nil then
            local config = string.sub(str,3,pos-1);
            local pros = string.split(config,";");
            -- print_lua_table(pros);
            for i,var in pairs(pros) do
                -- print("var = "..var);
                local first = string.sub(var,1,1);
                if first == "c" then
                    if string.len(var) >= 8 then
                        local r = tonumber(string.sub(var,3,4),16);
                        local g = tonumber(string.sub(var,5,6),16);
                        local b = tonumber(string.sub(var,7,8),16);
                        -- local r = string.format("%d",string.sub(var,3,4));
                        -- local g = string.format("%d",string.sub(var,5,6));
                        -- local b = string.format("%d",string.sub(var,7,8));
                        ret.color = cc.c3b(r,g,b);
                    end
                elseif first == "s" then
                    if string.len(var) >= 3 then
                        ret.fontsize = string.sub(var,3);
                    end
                elseif first == "f" then
                    if string.len(var) >= 3 then
                        local font = string.sub(var,3,3);
                        if string.sub(var,3,3) == "0" then
                            ret.font = gCustomFont;
                        elseif string.sub(var,3,3) == "1" then
                            ret.font = gFont;    
                        else
                            ret.font = string.sub(var,3);
                        end
                    end
                elseif first == "o" then
                    if( string.len(var) >= 3) then
                        local content = string.sub(var,3);
                        local contentTab = string.split(content,",");
                        local r = tonumber(string.sub(contentTab[1],1,2),16);
                        local g = tonumber(string.sub(contentTab[1],3,4),16);
                        local b = tonumber(string.sub(contentTab[1],5,6),16);
                        local o = tonumber(string.sub(contentTab[1],7,8),16);
                        ret.outline_color = cc.c4b(r,g,b,o);
                        ret.outline_offset = tonumber(contentTab[2]);
                    end    
                end
            end
            ret.word = string.sub(str,pos+1);
        end

    elseif string.sub(str,1,2) == "i{" then
        --i{p=xxxxx;s=0.5;}
        local pos = string.find(str,"}",2);
        if(pos ~= nil)then
            ret.type = "image";
            local config = string.sub(str,3,pos-1);
            local pros = string.split(config,";");
            for i,var in pairs(pros) do
                local first = string.sub(var,1,1);
                if first == "p" then
                    if string.len(var) >= 3 then
                        ret.imagePath = string.sub(var,3);
                    end
                elseif first == "s" then
                    if string.len(var) >= 3 then
                        ret.scale = string.sub(var,3);
                    end
                end
            end
        end 
    elseif string.sub(str,1,2) == "n{" then
        ret.type = "nextLine";    
    else
        ret.type = "word";
        ret.word = str;
        ret.color = self.defaultColor;
        ret.font = self.defaultFont;
        ret.fontsize = self.defaultFontsize;    
    end
    -- print_lua_table(ret);
    return ret;
end
function RTFLayer:addWord(word,font,fontsize,color,opacity,tag,outline_color,outline_offset)
    -- body
    if font == nil then
        font = self.defaultFont;
    end
    
    if fontsize == nil then
        fontsize = self.defaultFontsize;
    end
    if color == nil then
        color = self.defaultColor;
    end
    if opacity == nil then
        opacity = 255;
    end
    if tag == nil then
        tag = self:getMaxNodeTag();
    end
 

    if outline_color == nil then
        local rc =ccui.RichElementText:create(tag, color, opacity, word, font, fontsize);
        self.richText:pushBackElement(rc)
    else
        local node = gCreateWordLabelTTF(word,font,fontsize,color);
        node:enableOutline(outline_color,fontsize*outline_offset);
        self:addNode(node,opacity,color,tag);
    end
end

function RTFLayer:addImage(imagePath,scale,opacity,color,tag)
    if scale == nil then
        scale = 1;
    end
    if color == nil then
        color = cc.c3b(255,255,255);
    end
    if opacity == nil then
        opacity = 255;
    end
    if tag == nil then
        tag = self:getMaxNodeTag();
    end
    local rc = cc.Sprite:create(imagePath);
    rc:setScale(scale); 
    self:addNode(rc,opacity,color,tag);  
end

function RTFLayer:addNode(node,opacity,color,tag)
    -- body
    if color == nil then
        color = cc.c3b(255,255,255);
    end
    if opacity == nil then
        opacity = 255;
    end
    if tag == nil then
        tag = self:getMaxNodeTag();
    end
    local rc =ccui.RichElementCustomNode:create(tag, color, opacity, node);
    self.richText:pushBackElement(rc)
end

function RTFLayer:getNode(tag)
    if(self.richText)then
        return self.richText:getChildByTag(tag);
    end
    return nil;
end

function RTFLayer:addNextLine(height,tag)
    
    if(self.width <= 0)then
        return;
    end

    if height == nil then
        height = self.defaultFontsize + self.space;
    end
    if tag == nil then
        tag = self:getMaxNodeTag();
    end
    local rc = ccui.RichElementNextLine:create(tag,height);
    self.richText:pushBackElement(rc)
end

function RTFLayer:onTouchBegan(touch,event)
end

function RTFLayer:onTouchMoved(touch,event)
end

function RTFLayer:onTouchEnded(touch,event)
end
 