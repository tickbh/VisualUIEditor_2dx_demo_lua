local TabGroup=class("FightAI")

cc.exports.TabGroup=TabGroup 
 


function TabGroup:ctor(ui,texture1,texture2,callback)
    self.ui=ui 
    self.groups={}
    self.unSelectTexture=texture2
    self.callback=callback
    self.selectTexture=texture1
end
 
 
 

function TabGroup:selectTab(name) 
    for key, var in pairs(self.groups) do 
        self.ui:changeTexture(var,self.unSelectTexture)
    end 
    self.ui:changeTexture(name,self.selectTexture) 
    if(self.callback)then
        self.callback(name)
    end
end

function TabGroup:setTabs(tabs) 
   self.groups=tabs
end
 