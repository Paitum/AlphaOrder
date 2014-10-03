package {

import starling.core.Starling;

public class IosStartup extends MobileStartup {

    public function IosStartup() {
        super();
    }
    override protected function launch():void {
        Starling.multitouchEnabled = true;
        Starling.handleLostContext = false; // Recommended to disable on iOS

        super.launch();
    }

    override protected function start():void {
        super.start();

//        // testing code
//        trace("Testing Logic Enabled in IosStartup");
//        var gameState:GameState = state as GameState;
//        gameState.mute();
//        gameState.getStopwatch().setAccumulatedTime(35.123 + Math.random() * 50);
//        gameState.getBoard().solve(26);
    }
}
}