local CacheDataTable = {}

function GetJsonDataFromUI(name)
    if CacheDataTable[name] then
        return CacheDataTable[name]
    end

    local filePath = cc.FileUtils:getInstance():fullPathForFilename(name)
    local content = cc.FileUtils:getInstance():getStringFromFile(filePath)
    if not content or content.len() == 0 then
        return nil
    end

    local success, ret = pcall(cjson.decode, content)
    if type(ret) ~= "table" then
        success = false
    end

    if not success then
        return nil
    end
    CacheDataTable[name] = ret
    return ret
end