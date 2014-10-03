package {

import starling.core.Starling;

public class AndroidStartup extends Startup {

    public function AndroidStartup() {
        super();
    }

    override protected function launch():void {
        Starling.multitouchEnabled = true;
        Starling.handleLostContext = true;

        super.launch();
    }
}
}