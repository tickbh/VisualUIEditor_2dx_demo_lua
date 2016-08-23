function cc.exports.loadFlaPacker(name,weaponid,skinid)
    local plist={}
    getFlaPackerRes(name,weaponid,skinid,plist)
    for packer, var in pairs(plist) do
        cc.SpriteFrameCache:getInstance():addSpriteFrames(packer)
    end
end

function cc.exports.cloneClassMethod(src,dest)

    for key, var in pairs(src) do
        if(
            key~="new" and
            key~="__cname" and
            key~="create" and
            key~="ctor" and
            key~="__index"
            )then
            if(dest[key]==nil)then
                dest[key]=src[key]
            else
                dest["_"..key]=src[key]
            end
        end
    end
end


function  cc.exports.getRand(num1,num2)  
    return math.random(num1,num2)   
end


function cc.exports.getFlaPackerRes(name,weaponid,skinid,plists)
    if(gFlaPackers and gFlaPackers[name])then
        local packers= string.split(gFlaPackers[name],",")
        for key, packer in pairs(packers) do

            if(packer~="")then
                if(weaponid and string.find(packer,"images_role_"))then
                    local weaponPacker=packer.."_w_"..weaponid
                    plists["packer/"..weaponPacker..".plist"]=1
                end
                local needLoad=true
                if(skinid and string.find(packer,"images_role_"))then
                    local skinPacker=packer.."_s_"..skinid

                    if(cc.FileUtils:getInstance():isFileExist("packer/"..skinPacker..".plist"))then
                        plists["packer/"..skinPacker..".plist"]=1
                        needLoad=false
                    end
                end
                if(needLoad )then
                    plists["packer/"..packer..".plist"]=1
                end
            end
        end
    end

end


function cc.exports.loadFlaXml(name,weaponid,skinid)
    loadFlaPacker(name,weaponid,skinid)
    if(cc.FileUtils:getInstance():isFileExist("fla/"..name..".xml"))then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("fla/"..name..".xml")
        return true
    end
    return false
end

function cc.exports.loadRelationFlaXml(name)
    loadFlaXml(name)
    if(gFlaRelation[name])then
        local flaXmls=string.split(gFlaRelation[name],",")
        for key, var in pairs(flaXmls) do
            if(var~="")then
                loadFlaXml(var)
            end
        end
    end
end


function cc.exports.getActionTime(name)
    local animationData= ccs.ArmatureDataManager:getInstance():getAnimationData(name)

    if(animationData)then
        local movementData=  animationData:getMovement("stand")
        return movementData.duration/FLASH_FRAME
    end
    return 0
end