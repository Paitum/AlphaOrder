package {

import starling.core.Starling;

public class IosStartup extends Startup {

    public function IosStartup() {
        super();
    }

    override public function initialize():void {
        Starling.multitouchEnabled = true;
        Starling.handleLostContext = false; // Recommended to disable on iOS

        super.initialize();
    }


    override protected function loadingComplete():void {
        super.loadingComplete();

//        // testing code
//        trace("Testing Logic Enabled in IosStartup");
//        var gameState:GameState = state as GameState;
//        gameState.mute();
//        gameState.getStopwatch().setAccumulatedTime(35.123 + Math.random() * 50);
//        gameState.getBoard().solve(26);
    }
}
}