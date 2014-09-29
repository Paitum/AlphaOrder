package {
import com.adobe.images.PNGEncoder;

import flash.desktop.NativeApplication;

import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import flash.utils.ByteArray;
import flash.utils.getTimer;

import starling.core.Starling;

[SWF(width="640", height="960", frameRate="30", backgroundColor="#0000AA")]
public class ScreenshotsStartup extends Startup {
    var prefix:String;
    var directory:String;

    public function ScreenshotsStartup() {
    }

    override protected function getScreenWidth():int {
        return stage.stageWidth;
    }

    override protected function getScreenHeight():int {
        return stage.stageHeight;
    }

    override protected function transitionToGameState():void {
        directory = "D:\\trash\\ss\\";
        prefix = "AlphaOrder 0.9.2 " + stage.stageWidth + "x" + stage.stageHeight;

        takeScreenshot(prefix + " Loading");

        super.transitionToGameState();
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
            }, 1, 6)
        }, 1);
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
        var fileName:String = directory + name;

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
