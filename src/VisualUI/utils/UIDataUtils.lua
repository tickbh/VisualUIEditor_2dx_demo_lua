--UI创建模块
module("UIDataUtils", package.seeall)

local CacheDataTable = {}

local MultiLanguageData = {}
local CurrentLanguageSet = "Zh"

function GetJsonDataFromFile(name, fullpath)
    if CacheDataTable[name] then
        return CacheDataTable[name]
    end

    local filePath = name
    if fullpath and string.len(fullpath) > 0 then
        filePath = fullpath
    end

    local content = cc.FileUtils:getInstance():getStringFromFile(filePath)
    if not content or string.len(content) == 0 then
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

function SetLanguagePath(path)
    MultiLanguageData = GetJsonDataFromFile(path) or {}
end

function SetLanguageData(data)
    MultiLanguageData = data
end

function SetCurrentLangSet(langSet)
    CurrentLanguageSet = langSet
end

function GetLangFromConfig(key) 
    if MultiLanguageData[key] == nil then
        return nil
    end
    return MultiLanguageData[key][CurrentLanguageSet] or ""
end

function TryAnalyseLang(str)
    local data = {isKey = false}
    if string.find(str, "@") == 1 then
        local key = string.sub(str, 2)
        local lang = GetLangFromConfig(key)
        if lang ~= nil then
            data.value = lang
            data.isKey = true
            data.key = key
        end
    end
    return data
end