package {

import aze.motion.eaze;

import citrus.core.starling.StarlingCitrusEngine;
import citrus.core.starling.StarlingState;
import citrus.core.starling.ViewportMode;

import flash.display.Bitmap;

import flash.events.Event;
import flash.geom.Rectangle;
import flash.utils.getTimer;
import starling.core.Starling;
import starling.display.Image;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.AssetManager;

public class Startup extends StarlingCitrusEngine {
    private var viewPort:Rectangle = new Rectangle();
    private var scale:Number;
    private var startTime:Number;
    private var debug:Boolean;
    protected var background:Bitmap;
    protected var logo:Bitmap;
    protected var backgroundImage:Image;
    protected var logoImage:Image;
    protected var splashState:StarlingState;

    // Splash Screen
    [Embed(source="../embedded/textures/UniversalSplash.png")]
    private static var SplashBitmap:Class;
    [Embed(source="../embedded/textures/Level_Standard_2x.png")]
    private static var LogoBitmap:Class;

    public function Startup() {
        startTime = getTimer();
        super();

        debug = false;
        scale = 1;
        _viewportMode = ViewportMode.MANUAL;

        stage.color = Constants.BACKGROUND_COLOR;
        stage.frameRate = 60;

//        trace("**************************************************");
//        Constants.getDeviceInfo();
//        trace("(" + stage.stageWidth + ", " + stage.stageHeight + ") full(" + stage.fullScreenWidth + ", " + stage.fullScreenHeight + ")");
//        trace("**************************************************");

        showNativeSplashScreen();
    }

    protected function showNativeSplashScreen():void {
        var width:int = getScreenWidth();
        var height:int = getScreenHeight();
        var aspect:Number = height / width;
        var scale:Number = 1.0;

        background = new SplashBitmap();
        scale = Math.max(width / background.width, height / background.height);

// This logic attempts to perform cleaner scaling, but the effect was hardly noticable
//        var textureWidth:Number = (aspect < 1 ? background.width : background.width / aspect);
//        var textureHeight:Number = (aspect < 1 ? background.height * aspect : background.height);
//        background.scaleX = width / (2 * Math.floor(textureWidth / 2));
//        background.scaleY = height / (2 * Math.floor(textureHeight / 2));

        background.scaleX = background.scaleY = scale;
        background.x = Math.floor(width / 2 - background.width / 2);
        background.y = Math.floor(height/ 2 - background.height / 2);
        background.smoothing = true;
        addChild(background);

        logo = new LogoBitmap();
        scale = height / logo.height * 0.05;
        if(scale <= 0.33) scale = 0.33;
        if(scale > 0.33 && scale < 0.75) scale = 0.5;
        if(scale >= 0.75 && scale < 1.75) scale = 1;
        if(scale >= 1.75 && scale < 2.75) scale = 2;

        logo.scaleX = logo.scaleY = scale;
        logo.x = Math.floor(width * 0.5 - logo.width / 2);
        logo.y = height - logo.height * 2;
        logo.smoothing = true;
        addChild(logo);

        SplashBitmap = null;
        LogoBitmap = null;
    }

    /**
     * Transfer the native stage splash-screen bitmaps to Starling
     * This enables screenshots and citrus state transitions
     */
    private function transferNativeSplashScreen():void {
        splashState = new ColoredStarlingState(Constants.BACKGROUND_COLOR);
        splashState.clipRect = new Rectangle(0, 0, getScreenWidth(), getScreenHeight());
        var texture:Texture;

        if(background != null) {
            texture = Texture.fromBitmap(background);
            backgroundImage = new Image(texture);
            backgroundImage.x = background.x;
            backgroundImage.y = background.y;
            backgroundImage.scaleX = background.scaleX;
            backgroundImage.scaleY = background.scaleY;
            backgroundImage.smoothing = TextureSmoothing.TRILINEAR;
            splashState.addChild(backgroundImage);
        }

        if(logo != null) {
            texture = Texture.fromBitmap(logo);
            logoImage = new Image(texture);
            logoImage.x = logo.x;
            logoImage.y = logo.y;
            logoImage.scaleX = logo.scaleX;
            logoImage.scaleY = logo.scaleY;
            logoImage.smoothing = TextureSmoothing.TRILINEAR;
            splashState.addChild(logoImage);
        }

        state = splashState;

        if(background != null) {
            removeChild(background);
            background = null;
        }

        if(logo != null) {
            removeChild(logo);
            logo = null;
        }
    }

    private function disposeSplashScreen():void {
        if(splashState != null) {
            splashState.removeChildren();
            splashState.dispose();
            splashState = null;
        }

        if(backgroundImage != null) {
            backgroundImage.dispose();
            backgroundImage = null;
        }

        if(logoImage != null) {
            logoImage.dispose();
            logoImage = null;
        }
    }

    override public function initialize():void {
        super.initialize();
        setUpStarling(debug);
    }

    override public function handleStarlingReady():void {
        super.handleStarlingReady();

        setupView();
        transferNativeSplashScreen();
        initializeAssets(scale);
        loadAssets();

        stage.addEventListener(Event.RESIZE, handleResize1);
    }

    protected function initializeAssets(scale:Number):void {
        Assets.assets = new AssetManager(scale);
        Assets.assets.enqueue("media/fonts/" + scale + "x/" + Constants.DEFAULT_FONT + ".fnt");
        Assets.assets.enqueue("media/fonts/" + scale + "x/" + Constants.DEFAULT_FONT + ".png");
        Assets.assets.enqueue("media/textures/ABCSheet.xml");
        Assets.assets.enqueue("media/textures/ABCSheet.png");
        Assets.assets.enqueue("media/particles/particleConfig.pex");
        Assets.assets.enqueue("media/particles/particleTexture.png");

        enqueueSounds();
    }

    private function enqueueSounds():void {
        var length:int = Constants.WRONG_SOUNDS.length;
        for(i = 0; i < length; i++) {
            Assets.assets.enqueue("media/sounds/" + Constants.WRONG_SOUNDS[i] + ".mp3");
        }

        Assets.assets.enqueue("media/sounds/beep.mp3");
        Assets.assets.enqueue("media/sounds/celebrate.mp3");
        Assets.assets.enqueue("media/sounds/TouchTheLetters.mp3");
        Assets.assets.enqueue("media/sounds/AlphaOrder.mp3");

        var charCode:int = "a".charCodeAt(0);
        for(var i:int = 0; i < 26; i++) {
            var letter:String = String.fromCharCode(charCode + i);
            Assets.assets.enqueue("media/sounds/" + letter + ".mp3");
        }
    }

    protected function loadAssets():void {
        Assets.assets.verbose = debug;
        Assets.assets.loadQueue(function(ratio:Number):void {
            if(ratio == 1)  {
                transitionToGameState();
            }
        });
    }

    protected function transitionToGameState():void {
        registerSounds();

        var diff:Number = (getTimer() - startTime) / 1000;
        diff = int(diff * 1000) / 1000;
        trace("Assets Loaded in " + diff + " seconds");

        var gameState:StarlingState = new GameState();
        gameState.x = +stage.stageWidth;
        futureState = gameState;

        // Transition from loading state to game state
        eaze(state).to(0.5,{x:-stage.stageWidth});
        eaze(futureState).to(0.5,{x:0}).onComplete(function():void {
            state = futureState;
            disposeSplashScreen();
            loadingComplete();
        });
    }

    protected function loadingComplete():void {
        // For subclasses to perform actions following the transition
    }

    private function registerSounds():void {
        sound.addSound("AlphaOrder", {sound:Assets.assets.getSound("AlphaOrder")});
        sound.addSound("beep", {sound:Assets.assets.getSound("beep")});
        sound.addSound("TouchTheLetters", {sound:Assets.assets.getSound("TouchTheLetters")});
        sound.addSound("celebrate", {sound:Assets.assets.getSound("celebrate")});

        var i:int;
        var length:int = Constants.WRONG_SOUNDS.length;
        for(i = 0; i < length; i++) {
            sound.addSound(Constants.WRONG_SOUNDS[i], {sound:Assets.assets.getSound(Constants.WRONG_SOUNDS[i])});
        }

        var charCode:int = "a".charCodeAt(0);
        for(i = 0; i < 26; i++) {
            var letter:String = String.fromCharCode(charCode + i);
            sound.addSound(letter, {sound:Assets.assets.getSound(letter)});
        }
    }

    private function setupView():void {
        // viewPort is the virtual space
        Starling.current.viewPort = getViewPort();

        // stage is the pixel space
        _starling.stage.stageWidth = viewPort.width;
        _starling.stage.stageHeight = viewPort.height;

        trace("'");
        trace("Setup Display: viewPort(" + viewPort.width + ", " + viewPort.height + ") stage(" + _starling.stage.stageWidth + ", " + _starling.stage.stageHeight + ")");
        trace("'");
    }

    private function getViewPort():Rectangle {
        viewPort.setTo(0, 0, stage.stageWidth, stage.stageHeight);

//        trace("       Stage[" + stage.stageWidth + ", " + stage.stageHeight + "]");
//        trace("Capabilities[" + Capabilities.screenResolutionX + ", " + Capabilities.screenResolutionY + "]");

        return viewPort;
    }

    private function handleResize1(event:Event):void {
        setupView();
    }

    protected function getScreenWidth():int {
        return stage.fullScreenWidth;
    }

    protected function getScreenHeight():int {
        return stage.fullScreenHeight;
    }
}
}

import citrus.core.starling.StarlingState;

internal class ColoredStarlingState extends StarlingState {
    var _color:uint;

    public function ColoredStarlingState(color:uint) {
        _color = color;
    }


    override public function initialize():void {
        super.initialize();
        stage.color = _color;
    }
}