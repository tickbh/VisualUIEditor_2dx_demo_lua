local EventManager={}
cc.exports.EventManager=EventManager
EventManager.targets={}



function EventManager:regster(target)
    EventManager.targets[target]=1
end


function EventManager.unregster(target)
    EventManager.targets[target]=nil
end



function EventManager.dispatchEvent(event)
    for target, var in pairs(EventManager.targets) do
        if(target.events)then
            for key, var in pairs(target.events) do
                if(var==event)then
                    target.dealEvent(event)
                end
            end
        end
    end
end
 