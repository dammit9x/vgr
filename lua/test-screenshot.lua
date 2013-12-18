require "gd"
--foo = gd.createTrueColor(256,224)
foo = gui.gdscreenshot()
gd.createFromGdStr(foo)
foo:pngStr("screen.png")