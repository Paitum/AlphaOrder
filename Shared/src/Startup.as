package {

import aze.motion.eaze;

import citrus.core.starling.StarlingCitrusEngine;
import citrus.core.starling.StarlingState;
import citrus.core.starling.ViewportMode;

import flash.events.Event;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import starling.utils.AssetManager;

public class Startup extends StarlingCitrusEngine {
    private var viewPort:Rectangle = new Rectangle();
    private var scale:Number;
    private var startTime:Number;
    private var debug:Boolean;

    public function Startup() {
        startTime = getTimer();
        super();

        debug = false;
        scale = 1;
        _viewportMode = ViewportMode.MANUAL;

        stage.color = 0xEEEEFF;
        stage.frameRate = 60;

        trace("**************************************************");
        Constants.getDeviceInfo();
        trace("(" + stage.stageWidth + ", " + stage.stageHeight + ") full(" + stage.fullScreenWidth + ", " + stage.fullScreenHeight + ")");
        trace("**************************************************");
    }

    override public function initialize():void {
        super.initialize();
        setUpStarling(debug);
    }

    override public function handleStarlingReady():void {
        super.handleStarlingReady();

        state = new LoadState();

        setupView();
        initializeAssets(scale);
        loadAssets();

        stage.addEventListener(Event.RESIZE, handleResize1);
    }

    protected function initializeAssets(scale:Number):void {
        Assets.assets = new AssetManager(scale);
        Assets.assets.enqueue("media/fonts/" + scale + "x/" + Constants.DEFAULT_FONT + ".fnt");
        Assets.assets.enqueue("media/fonts/" + scale + "x/" + Constants.DEFAULT_FONT + ".png");
        Assets.assets.enqueue("media/fonts/" + scale + "x/ArtBrushLarge.fnt");
        Assets.assets.enqueue("media/fonts/" + scale + "x/ArtBrushLarge.png");

        Assets.assets.enqueue("media/textures/" + scale + "x/Tile.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/Background.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/levelHalf.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/restart.png");
        Assets.assets.enqueue("media/particles/particleConfig.pex");
        Assets.assets.enqueue("media/particles/particleTexture.png");
        Assets.assets.enqueue("media/sounds/beep.mp3");
        Assets.assets.enqueue("media/sounds/celebrate.mp3");
        Assets.assets.enqueue("media/sounds/wrong.mp3");

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
            } else if(state is LoadState) {
                (state as LoadState).updateProgress(ratio);
            }
        });
    }

    protected function loadingComplete():void {
        var diff:Number = (getTimer() - startTime) / 1000;
        diff = int(diff * 1000) / 1000;
        trace("Assets Loaded in " + diff + " seconds");

        // Initialize sounds
        sound.addSound("beep", {sound:Assets.assets.getSound("beep")});
        sound.addSound("wrong", {sound:Assets.assets.getSound("wrong")});
        sound.addSound("celebrate", {sound:Assets.assets.getSound("celebrate")});

        var charCode:int = "a".charCodeAt(0);
        for(var i:int = 0; i < 26; i++) {
            var letter:String = String.fromCharCode(charCode + i);
            sound.addSound(letter, {sound:Assets.assets.getSound(letter)});
        }

        var gameState:StarlingState = new GameState();
        gameState.x = +stage.stageWidth;
        futureState = gameState;

        // Transition from loading state to game state
        eaze(state).to(0.5,{x:-stage.stageWidth});
        eaze(futureState).to(0.5,{x:0}).onComplete(function():void {
            state = futureState;
        });
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