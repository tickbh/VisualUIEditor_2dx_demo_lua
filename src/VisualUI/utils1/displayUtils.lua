DisplayUtil={}
DisplayUtil.LIST_DONT_GRAY = {
    "getSprite",     --ProgressTimer
    "setString",     --Label
}
--判断能否灰化
function DisplayUtil.canGray(node)
    for i,v in ipairs(DisplayUtil.LIST_DONT_GRAY) do
        if node[v] then
            return false
        end
    end
    return true
end

--灰化对象
function DisplayUtil.setGray(node, v)
    if type(node) ~= "userdata" then
        return
    end

    if v == nil then
        v = true
    end



    if v then

        if(node["changeBoneParent"])then
            node:setChildShaderName("ShaderPositionTextureGray")

        else
            if(node["setState"])then
                node:setState(1)
            elseif DisplayUtil.canGray(node) then
                node:setGLProgram(Shader.getShader(Shader.GRAY_SHADER))
            end
            --children
            local children = node:getChildren()
            if children and table.nums(children) > 0 then
                --遍历子对象设置
                for i,v in ipairs(children) do
                    if DisplayUtil.canGray(v) then
                        DisplayUtil.setGray(v)
                    end
                end
            end
        end


    else
        DisplayUtil.removeGray(node)
    end
    node.__isGray__ = v
end
--取消灰化
function DisplayUtil.removeGray(node)
    if type(node) ~= "userdata" then
        print("node must be a userdata")
        return
    end
    if not node.__isGray__ then
        return
    end


    if(node["changeBoneParent"])then
        node:setChildShaderName("ShaderPositionTextureColor_noMVP")
    else

        if(node["setState"])then
            node:setState(0)
        elseif DisplayUtil.canGray(node) then
            local glProgram = cc.GLProgramCache:getInstance():getGLProgram(
                "ShaderPositionTextureColor_noMVP")
            node:setGLProgram(glProgram)
        end
        --children
        local children = node:getChildren()
        if children and table.nums(children) > 0 then
            --遍历子对象设置
            for i,v in ipairs(children) do
                if DisplayUtil.canGray(v) then
                    DisplayUtil.removeGray(v)
                end
            end
        end
    end

    node.__isGray__ = false
end