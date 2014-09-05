package {

import aze.motion.eaze;

import citrus.core.starling.StarlingCitrusEngine;
import citrus.core.starling.StarlingState;
import citrus.core.starling.ViewportMode;

import flash.display.Bitmap;

import flash.events.Event;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import starling.utils.AssetManager;

public class Startup extends StarlingCitrusEngine {
    private var viewPort:Rectangle = new Rectangle();
    private var scale:Number;
    private var startTime:Number;
    private var debug:Boolean;
    private var background:Bitmap;

    // Startup image for HD screens
    [Embed(source="../../Shared/media/textures/SplashHD.png")]
    private static var BackgroundHD:Class;

    public function Startup() {
        startTime = getTimer();
        super();

        debug = true;
        scale = 1;
        _viewportMode = ViewportMode.MANUAL;

        stage.color = Constants.BACKGROUND_COLOR;
        stage.frameRate = 60;

        trace("**************************************************");
        Constants.getDeviceInfo();
        trace("(" + stage.stageWidth + ", " + stage.stageHeight + ") full(" + stage.fullScreenWidth + ", " + stage.fullScreenHeight + ")");
        trace("**************************************************");

        background = new BackgroundHD();
        BackgroundHD = null;

        var viewPort:Rectangle = new Rectangle(0, 0, stage.fullScreenWidth, stage.fullScreenHeight);
        var backgroundScale:Number = Math.min(viewPort.width / background.width, viewPort.height / background.height);
        if(backgroundScale > 0.66) backgroundScale = 1.0;
        background.scaleX = background.scaleY = backgroundScale;
        background.x = Math.floor(viewPort.x + viewPort.width / 2 - background.width / 2);
        background.y = Math.floor(viewPort.y + viewPort.height/ 2 - background.height / 2);
        background.smoothing = true;
        addChild(background);
    }

    override public function initialize():void {
        super.initialize();
        setUpStarling(debug);
    }

    override public function handleStarlingReady():void {
        super.handleStarlingReady();

//        state = new LoadState();

        setupView();
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
                loadingComplete();
            }
//            else if(state is LoadState) {
//                (state as LoadState).updateProgress(ratio);
//            }
        });
    }

    protected function loadingComplete():void {
        loadSounds();

        var diff:Number = (getTimer() - startTime) / 1000;
        diff = int(diff * 1000) / 1000;
        trace("Assets Loaded in " + diff + " seconds");

        state = new GameState();
        removeChild(background);
        background = null;

//        var gameState:StarlingState = new GameState();
//        gameState.x = +stage.stageWidth;
//        futureState = gameState;
//
//        // Transition from loading state to game state
//        eaze(state).to(5,{x:-stage.stageWidth});
//        eaze(futureState).to(5,{x:0}).onComplete(function():void {
//            state = futureState;
//        });
    }

    private function loadSounds():void {
        // Initialize sounds
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
        _starling.viewPort = getViewPort();
        trace("VIEWPORT(" + viewPort.width + "x" + viewPort.height + ")");

        var isPortrait:Boolean = stage.fullScreenHeight > stage.fullScreenWidth;
        var deviceInfo:Object = Constants.getDeviceInfo();

        if(deviceInfo.isDesktop) {
            _starling.stage.stageWidth = viewPort.width;
            _starling.stage.stageHeight = viewPort.height;
        } else {
            _starling.stage.stageWidth = isPortrait ? deviceInfo.shortEdge : deviceInfo.longEdge;
            _starling.stage.stageHeight = isPortrait ? deviceInfo.longEdge : deviceInfo.shortEdge;
        }
    }

    private function getViewPort():Rectangle {
        var deviceInfo:Object = Constants.getDeviceInfo();

        if(deviceInfo.isDesktop) {
            viewPort.setTo(0, 0, stage.stageWidth, stage.stageHeight);
        } else {
            var isPortrait:Boolean = stage.fullScreenHeight > stage.fullScreenWidth;
            var width:int = isPortrait ? deviceInfo.shortEdge : deviceInfo.longEdge;
            var height:int = isPortrait ? deviceInfo.longEdge : deviceInfo.shortEdge;
            viewPort.setTo(0, 0, width, height);
        }

        return viewPort;
    }

    private function handleResize1(event:Event):void {
        trace("RESIZE (" + stage.stageWidth + ", " + stage.stageHeight + ") target[" + event.target + "] currTar[" + event.currentTarget + "] " + event);
        setupView();
    }
}
}