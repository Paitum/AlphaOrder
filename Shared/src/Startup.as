package {

import citrus.core.starling.StarlingCitrusEngine;
import citrus.core.starling.ViewportMode;

import feathers.controls.Button;

import feathers.themes.MetalWorksMobileTheme;
import feathers.themes.MinimalMobileTheme;

import flash.events.Event;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.textures.Texture;
import starling.utils.AssetManager;

public class Startup extends StarlingCitrusEngine {
    private var viewPort:Rectangle = new Rectangle();
    private var scale:Number;
    private var startTime:Number;
    private var debug:Boolean;
    private var theme:MetalWorksMobileTheme;

    public function Startup() {
        startTime = getTimer();
        super();

        debug = true;
        scale = 2;
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

        setupView();
        initializeAssets(scale);
        loadAssets();

        stage.addEventListener(Event.RESIZE, handleResize1);
    }

    protected function initializeAssets(scale:Number):void {
        Assets.assets = new AssetManager(scale);
        Assets.assets.enqueue("media/fonts/" + scale + "x/ArtBrushLarge.fnt");
        Assets.assets.enqueue("media/fonts/" + scale + "x/ArtBrushLarge.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/ConstructionPaper.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/Background.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/button-down-skin.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/button-up-skin.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/restart.png");
        Assets.assets.enqueue("media/textures/" + scale + "x/blackhole.png");
        Assets.assets.enqueue("media/particles/particleConfig.pex");
        Assets.assets.enqueue("media/particles/particleTexture.png");
    }

    protected function loadAssets():void {
        Assets.assets.verbose = debug;
        Assets.assets.loadQueue(function(ratio:Number):void {
            if(ratio == 1) loadingComplete();
        });
    }

    protected function loadingComplete():void {
        var diff:Number = (getTimer() - startTime) / 1000;
        diff = int(diff * 1000) / 1000;
        trace("Assets Loaded in " + diff + " seconds");
        // Initialize Feather's theme
        theme = new MetalWorksMobileTheme(DisplayObjectContainer(state), false);
        theme.setInitializerForClass(Button, initializeButton, "restart");

        state = new GameState();
    }

    private function initializeButton(button:Button):void {
        button.defaultSkin = new Image(Assets.assets.getTexture("buttonUpSkin"));
        button.downSkin = new Image(Assets.assets.getTexture("buttonDownSkin"));
        button.defaultIcon = new Image(Assets.assets.getTexture("restart"));
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