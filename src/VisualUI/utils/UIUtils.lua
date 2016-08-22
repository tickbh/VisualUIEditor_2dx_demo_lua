
local PathTemple = {}

function CheckPathRepeat(node, path)
    let parent = node
    while parent do
        if path == parent._path or path == parent._sceneSubPath then
            return true
        end
        parent = parent.getParent()
    end
    return false
end

function RegisterPathTemple(path, layer)
    PathTemple[path] = layer
end

function GetPathTemple(path)
    return PathTemple[path]
end