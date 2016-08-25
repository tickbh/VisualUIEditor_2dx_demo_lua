local UISub1=class("UISub1", UILayer)

function UISub1:ctor(...)
    UISub1.super.ctor(self, ...)
end

function UISub1:eventListener(event)
    print("UISub1")
    dump(event)
end

UIUtils.RegisterPathTemple("ui/sub1.ui", UISub1)