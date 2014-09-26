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
}
}