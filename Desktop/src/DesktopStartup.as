package {

import starling.core.Starling;

public class DesktopStartup extends Startup {
    public function DesktopStartup() {
        super();
    }

    override public function initialize():void {
        Starling.multitouchEnabled = false;
        Starling.handleLostContext = true;

        super.initialize();
    }
}
}