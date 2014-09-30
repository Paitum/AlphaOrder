package {
import com.adobe.images.PNGEncoder;

import flash.desktop.NativeApplication;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import flash.utils.ByteArray;

import starling.core.Starling;

//[SWF(width="768", height="1024")]
//[SWF(width="1536", height="2048")]

//[SWF(width="320", height="480")]
//[SWF(width="640", height="960")]
//[SWF(width="640", height="1136")]
//[SWF(width="750", height="1334")]
//[SWF(width="1242", height="2208")]

//[SWF(width="480", height="800")]
//[SWF(width="1080", height="1920")] // Galaxy S5
[SWF(width="1600", height="2560")] // Nexus 10
public class ScreenshotsStartup extends Startup {
    var prefix:String;
    var superDirectory:String;
    var directory:String;

    public function ScreenshotsStartup() {
        super();
    }

    override protected function getScreenWidth():int {
        return stage.stageWidth;
    }

    override protected function getScreenHeight():int {
        return stage.stageHeight;
    }

    override protected function transitionToGameState():void {
        var dimensions:String = stage.stageWidth + "x" + stage.stageHeight;

        directory = "D:\\trash\\ss\\";
        superDirectory = dimensions + " " + getDeviceName();
        prefix = "AlphaOrder 0.9.2 " + dimensions;

        takeScreenshot(prefix + " Loading");

        super.transitionToGameState();
    }

    private function getDeviceName():String {
        var w:int = getScreenWidth();
        var h:int = getScreenHeight();


        if(w == 768 && h == 1024) return "iPad";
        if(w == 1536 && h == 2048) return "iPad Retina";

        if(w == 640 && h == 960) return "iPhone 4x";
        if(w == 640 && h == 1136) return "iPhone 5x";
        if(w == 750 && h == 1334) return "iPhone 6";
        if(w == 1242 && h == 2208) return "iPhone 6 Plus";

        if(w == 480 && h == 800) return "Galaxy S2";
        if(w == 1080 && h == 1920) return "Galaxy S5";
        if(w == 1600 && h == 2560) return "Nexus 10";

        return "UNKNOWN";
    }

    override protected function loadingComplete():void {
        super.loadingComplete();

        var gameState:GameState = state as GameState;
        var solveCount:int = 7;
        gameState.mute();

        // ABC
        gameState.getBoard().solve(solveCount);
        takeScreenshot(prefix + " ABC-upper");

        // abc
        gameState.nextGameMode();
        gameState.getBoard().solve(solveCount);
        takeScreenshot(prefix + " abc-lower");

        // aBc
        gameState.nextGameMode();
        gameState.getBoard().solve(solveCount);
        takeScreenshot(prefix + " aBc-mix");

        // Victory
        gameState.nextGameMode();
        gameState.getStopwatch().setAccumulatedTime(35.123 + Math.random() * 50);
        gameState.getBoard().solve(26);
        var screenShotCount:int = 0;
        juggler.delayCall(function():void {
            juggler.repeatCall(function():void {
                takeScreenshot(prefix + " Celebrate" + screenShotCount);

                screenShotCount++;
                if(screenShotCount > 5) {
                    terminate();
                }
            }, 2, 6)
        }, 4);
    }

    private function terminate():void {
        trace("Terminate");
        NativeApplication.nativeApplication.exit(0);
    }

    private function takeScreenshot(name:String):void {
        savePng(name);
    }

    /**
     * http://www.baconbanditgames.com/2013/10/28/saving-starling-screenshots/
     */
    public function savePng(name:String):void
    {
        var starlingStatsWereShowing:Boolean;
        starlingStatsWereShowing = Starling.current.showStats;
        Starling.current.showStats = false;

        var png:ByteArray = PNGEncoder.encode(Starling.current.stage.drawToBitmapData());

        Starling.current.showStats = starlingStatsWereShowing;

        saveImageFile(png, name + ".png");
    }

    private function saveImageFile(image:ByteArray, name:String):void
    {
        var fileName:String = directory + superDirectory + "\\" + name;

        trace("Saving " + fileName + ".......");

        var file:File = new File();
        file.nativePath = fileName;
        var fileStream:FileStream = new FileStream();
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeBytes(image);
        fileStream.close();
    }
}
}
