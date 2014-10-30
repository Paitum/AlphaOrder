package {

import citrus.core.starling.StarlingCitrusEngine;

import flash.desktop.NativeApplication;
import flash.display.StageAspectRatio;

import flash.events.Event;
import flash.utils.getTimer;

/**
 * The following lifecycle shows the sequence of method calls that can/should
 * be customized by StartupBase implementations.
 *
 * I. Launch
 *    1. launch()
 *    2. showNativeSplashScreen()
 *
 * II. Starling and Citrus Engine initialized
 *    1. postConfigure()
 *    2. postUpdate()
 *    3. enqueueAssets()
 *    4. loadingAssets(ratio) called many times ratio 0 through 1.0 inclusive
 *    5. loadComplete()       called called once after assets are loaded
 *
 * III. on resize or orientation change
 *    1. postUpdate()
 */
public class StartupBase extends StarlingCitrusEngine {
    protected var startTime:Number;
    protected var assetsStartLoad:int;
    protected var debug:Boolean = true;

    private var lastWidth:int = -1;
    private var lastHeight:int = -1;

    public function StartupBase() {
        startTime = getTimer();
        super();
        trace("[StartupBase]: Constructor");

        launch();
    }

    public function msSinceStart():int {
        return getTimer() - startTime;
    }

    /**
     * Kicks off the launch of the application.
     *
     * Subclasses can perform initialization before processing super.launch()
     * and can delay the execution of launch, if desired. Subclasses must invoke
     * super.launch().
     */
    protected function launch():void {
        setUpStarling(debug);
    }

    /**
     * This method is not intended to be overridden.
     */
    override public function handleStarlingReady():void {
        super.handleStarlingReady();

        postConfigure();
        postUpdate();
        enqueueAssets();

        Assets.assets.verbose = debug;
        assetsStartLoad = getTimer();
        Assets.assets.loadQueue(function(ratio:Number):void {
            loadingAssets(ratio);

            if(ratio >= 1.0) {
                loadComplete();

                // Allow auto orientation after loading is complete
                stage.setAspectRatio(StageAspectRatio.ANY);
                stage.autoOrients = true;
            }
        });

        stage.addEventListener(Event.RESIZE, handleResize);
    }

    /**
     * Called after the CitrusEngine calls handleStarlingReady.
     *
     * Subclasses should configure the Starling and Citrus environment
     *
     * This should only be called once.
     */
    protected function postConfigure():void {
        // override in subclass
    }

    /**
     * Enqueue assets in AssetManager
     */
    protected function enqueueAssets():void {
        // override in subclass
    }

    /**
     * Asset loading update
     *
     * @param ratio the load status from 0.0 to 1.0
     */
    protected function loadingAssets(ratio:Number):void {
        // override in subclass
    }

    /**
     * Asset loading is complete.
     */
    protected function loadComplete():void {
        // override in subclass
    }

    protected function handleResize(event:Event):void {
        // While developing, the resize trigger happens twice, ignore duplicates
        if(stage.stageWidth == lastWidth &&
           stage.stageHeight == lastHeight)
        {
            return;
        }

        lastWidth = stage.stageWidth;
        lastHeight = stage.stageHeight;

        postUpdate();
    }

    /**
     * Called after the postConfigure, but also after all size and orientation
     * changes.
     */
    protected function postUpdate():void {
        // override in subclass
    }

    protected function getStageWidth():int {
        return stage.stageWidth;
    }

    protected function getStageHeight():int {
        return stage.stageHeight;
    }
}
}