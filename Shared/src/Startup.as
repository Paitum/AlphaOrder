package {

import citrus.core.starling.StarlingCitrusEngine;
import citrus.core.starling.ViewportMode;

import flash.events.Event;
import flash.filesystem.File;
import flash.geom.Rectangle;

public class Startup extends StarlingCitrusEngine {
    private var viewPort:Rectangle = new Rectangle();

    public function Startup() {
        super();

        _viewportMode = ViewportMode.MANUAL;

        stage.color = 0xEEEEFF;
        stage.frameRate = 60;

        trace("**************************************************");
        Constants.getDeviceInfo();
        trace("(" + stage.stageWidth + ", " + stage.stageHeight + ") full(" + stage.fullScreenWidth + ", " + stage.fullScreenHeight + ")");
        trace("Working Directory[" + File.applicationDirectory.nativePath + "]");
        trace("**************************************************");
    }

    override public function initialize():void {
        super.initialize();
        setUpStarling(true);
    }

    override public function handleStarlingReady():void {
        super.handleStarlingReady();

        setupView();

        state = new GameState();

        stage.addEventListener(Event.RESIZE, handleResize1);
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
        trace("RESIZE (" + stage.stageWidth + ", " + stage.stageHeight + ") Orient[" + this.stage.deviceOrientation + "] target[" + event.target + "] currTar[" + event.currentTarget + "] " + event);
        setupView();
    }
}
}