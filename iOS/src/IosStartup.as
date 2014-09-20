package {

import starling.core.Starling;

public class IosStartup extends Startup {

    // Startup image for HD screens
    [Embed(source="../media/textures/Default@2x.png")]
    private static var Default1:Class;
    [Embed(source="../media/textures/Default-568h@2x.png")]
    private static var Default2:Class;
    [Embed(source="../media/textures/Default-Portrait@2x.png")]
    private static var Default3:Class;
    [Embed(source="../media/textures/Default-375w-667h@2x.png")]
    private static var Default4:Class;
    [Embed(source="../media/textures/Default-414w-736h@3x.png")]
    private static var Default5:Class;

    public function IosStartup() {
        super();
    }

    override public function initialize():void {
        Starling.multitouchEnabled = true;
        Starling.handleLostContext = false; // Recommended to disable on iOS

        super.initialize();
    }

    override protected function showNativeSplashScreen():void {
        var width:int = getScreenWidth();
        var height:int = getScreenHeight();
        var aspect:Number = height / width;
        var scale:Number = 1.0;
        var backgroundClass:Class = null;

        if(width == 1536 && height == 2048) { // iPad 3 =>
            backgroundClass = Default3;
        } else if(width == 768 && height == 1024) { // iPad 2
            backgroundClass = Default3;
            scale = 0.5;
        } else if(aspect == (2208 / 1242)) { // iPhone 6 plus
            backgroundClass = Default5;
            scale = height / 2208;
//        } else if(width == 1242 && height == 2208) { // iPhone 6 plus
//            backgroundClass = Default5;
//        } else if(width == 1080 && height == 1920) { // iPhone 6 plus
//            backgroundClass = Default5;
//            scale = 1920 / 2208;
        } else if(width == 750 && height == 1334) { // iPhone 6
            backgroundClass = Default4;
        } else if(width == 640 && height == 1136) { // iPhone 5
            backgroundClass = Default2;
        } else if(width == 640 && height == 960) { // iPhone 4 =>
            backgroundClass = Default1;
        } else if(width == 320 && height == 480) { // iPhone 4 <
            backgroundClass = Default1;
            scale = 0.5;
        }

        if(backgroundClass != null) {
            background = new backgroundClass();
            background.x = 0;
            background.y = 0;
            background.scaleX = background.scaleY = scale;
            background.smoothing = true;
        } else {
            background = new Default1();
            scale = Math.min(width / background.width, height / background.height);
            if(scale > 1.0) scale = 1.0;
            background.scaleX = background.scaleY = scale;
            background.x = Math.floor(width / 2 - background.width / 2);
            background.y = Math.floor(height/ 2 - background.height / 2);
//trace(width + ", " + height);
//trace(result.x + ", " + result.y + " " + result.width + ", " + result.height + "  scale[" + scale + "]");

            background.smoothing = true;
        }

        addChild(background);

        Default1 = null;
        Default2 = null;
        Default3 = null;
    }
}
}