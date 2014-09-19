package {

import starling.core.Starling;

public class AndroidStartup extends Startup {

    public function AndroidStartup() {
        super();
    }

    override public function initialize():void {
        Starling.multitouchEnabled = true;
        Starling.handleLostContext = true;

        super.initialize();
    }

}
}