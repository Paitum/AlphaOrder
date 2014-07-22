package {

public class DesktopStartup extends Startup {
    public function DesktopStartup() {
        super();
    }

    override public function initialize():void {
        trace("DesktopStartup.initialize()");
        super.initialize();
    }
}
}