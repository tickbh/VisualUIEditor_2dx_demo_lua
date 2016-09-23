--富文本类
local UI_RICHTEXT_CLASS = class("UI_RICHTEXT_CLASS", function()
    return ccui.RichText:create()
end)
cc.exports.UI_RICHTEXT_CLASS=UI_RICHTEXT_CLASS

--{color=display.COLOR_WHITE, fontSize = 20, ocolor = display.COLOR_BLACK, osize = 1 }
function UI_RICHTEXT_CLASS:ctor(text, size, config)
    self.allElement = {}
    self:initWithConfig(config)
    self:setContentSize(size.width or 100, size.height or 100)
    self:ignoreContentAdaptWithSize(false);
    self:SetText(text)

end

function UI_RICHTEXT_CLASS:initWithConfig(config)
    self.originConfig = UIUtils.merge({color= display.COLOR_WHITE, fontSize = 20, ocolor = display.COLOR_BLACK, osize = 0}, config)

    self.curConfig = UIUtils.dup(self.originConfig)
    self.isPic = false
    self.isFace = false
    self.picUrl = ""
    self.txt = {}
end

function UI_RICHTEXT_CLASS:getDiffIdx(text)
    if #self.txt == 0 then 
        return 1
    end

    local idx = 0
    for i = 1, #text do 
        if i > #self.txt or text[i] ~= self.txt[i] then 
            if idx > 0 then 
                return idx 
            else 
                return i 
            end
        else 
            if text[i] == "[" then 
                idx = i
            elseif text[i] == "]" then 
                idx = 0 
            end
        end 
    end

    return 1
end

function UI_RICHTEXT_CLASS:parseText(text)
    local left, right, convert = string.byte("["), string.byte("]"), string.byte("\\")
    local inSerch = false
    local i, pre = 1, 1
    while i < string.len(text) do
        local c = string.byte(text, i)
        if c == left and string.byte(text, i - 1) ~= convert  then
            if i > pre then
                self:addRichElement(string.sub(text, pre, i - 1))
                pre = i
            end
            inSerch = true
            local function findNext(str, index)
                index = string.find(str, "]", index)
                while index ~= nil and string.byte(text, index - 1) == convert do
                    index = string.find(str, "]", index + 1)
                end
                return index
            end

            local index = findNext(text, i + 1)
            if not index then
                break
            end
            local isaddPic  = self:parseConfig(string.sub(text, i + 1, index - 1))
            if isaddPic then
                self:addRichElement()
            end
            i, pre = index, index + 1
            inSerch = false
        end
        inSerch = false
        i = i + 1
    end

    if not inSerch then
        self:addRichElement(string.sub(text, pre))
    end
end

function UI_RICHTEXT_CLASS:AddText(text)
    if text and text ~= "" then 
        self:parseText(text)
    end
end


function UI_RICHTEXT_CLASS:clearAllElement()
    for _,element in ipairs(self.allElement) do
        self.removeElement(element)
    end
    self.allElement = {}
end

function UI_RICHTEXT_CLASS:SetText(text)
    self:clearAllElement()
    self.curConfig = UIUtils.dup(self.originConfig)
    if text and text ~= "" then 
        self:parseText(text)
    end
end

function UI_RICHTEXT_CLASS:addRichElement(str)
    local re
    if self.isPic then
        if self.isFace then
            self.picUrl = "img/icon/face/"..self.picUrl..".png"
        end
        re = ccui.RichElementImage:create(1, self.curConfig.color, 255, self.picUrl)
        self.picUrl = ""
        self.isPic = false
        self.isFace = false
    else
        re = ccui.RichElementText:create(1, self.curConfig.color, 255, str, "", self.curConfig.fontSize)
        if self.curConfig.osize > 0 then
            re:enableOulineColor(self.curConfig.ocolor, 255, self.curConfig.osize)
        end
    end
    table.insert(self.allElement, re)
    self:pushBackElement(re)
end


--更改配置  callback(curConfig, originConfig)
function UI_RICHTEXT_CLASS:parseConfig(value)
    --print("parseConfig", value)
    local len = string.len(value)
    local fontSize = 0
    -- "c200:200:200"
    if value == "/c" then
        self.curConfig.color = self.originConfig.color
    elseif string.sub(value, 1, 3) == "pic" then
        self.isPic = true
        self.picUrl = string.sub(value, 5)
        return true
    elseif string.sub(value, 1, 1) == "p" then
        self.isPic = true
        self.isFace = true
        self.picUrl = string.sub(value, 3)
        local n = tonumber(self.picUrl)
        if not n or n > 27 or n < 10 then
            self.isPic = false
            self.isFace = false
            return false
        end
        return true
    elseif value == "cr" then
        self.curConfig.color = display.COLOR_RED
    elseif value == "cw" then
        self.curConfig.color = display.COLOR_WHITE
    elseif value == "cg" then
        self.curConfig.color = display.COLOR_GREEN
    elseif value == "co" then
        self.curConfig.color = display.COLOR_ORANGE
    elseif value == "cb" then
        self.curConfig.color = display.COLOR_BLACK
    elseif value == "cy" then
        self.curConfig.color = display.COLOR_YELLOW
    elseif value == "cro" then
        self.curConfig.color = cc.c3b(130, 61, 32)
    elseif string.sub(value, 1, 1) == "c" then
        local color = self:richTextGetRGB(string.sub(value, 2))
        if color then
            self.curConfig.color = color
        end
    elseif value == "/oc" then
        self.curConfig.ocolor = self.originConfig.ocolor
    elseif value == "ocr" then
        self.curConfig.ocolor = display.COLOR_RED
    elseif value == "ocw" then
        self.curConfig.ocolor = display.COLOR_WHITE
    elseif value == "ocg" then
        self.curConfig.ocolor = display.COLOR_GREEN
    elseif value == "ocb" then
        self.curConfig.ocolor = display.COLOR_BLACK
    elseif string.sub(value, 1, 2) == "oc" then
        local color = self:richTextGetRGB(string.sub(value, 3))
        if color then
            self.curConfig.ocolor = color
        end
    elseif string.sub(value, 1, 2) == "of" then
        self.curConfig.osize = tonumber(string.sub(value, 3, len))
    elseif value == "/of" then
        self.curConfig.osize = self.originConfig.osize
    elseif string.sub(value, 1, 1) == "f" then
        self.curConfig.fontSize = tonumber(string.sub(value, 2, len)) 
    elseif value == "/f" then
        self.curConfig.fontSize = self.originConfig.fontSize
    elseif callback ~= nil then
        callback(self.curConfig, self.originConfig)
    end 
end

-- "c200:200:200"
function UI_RICHTEXT_CLASS:richTextGetRGB(value)
    local r, g, b = string.match(value, "(%d+):(%d+):(%d+)")
    --print("richTextGetRGB", value, r, g, b)
    local function checkNum(ss)
        if not is_number(ss) then
            return 0
        end
        return math.max(math.min(ss, 255), 0)
    end
    return cc.c3b(checkNum(tonumber(r)), checkNum(tonumber(g)), checkNum(tonumber(b)))
end

return UI_RICHTEXT_CLASS