


function CheckPathRepeat(node, path) {
    let parent = node
    while(parent) {
        if(path == parent._path || path == parent._sceneSubPath) {
            return true
        }
        parent = parent.getParent()
    }
    return false
}