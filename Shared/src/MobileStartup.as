package {
public class MobileStartup extends InvokableStartup {

    public function MobileStartup() {
    }

    override protected function getStageWidth():int {
        return stage.fullScreenWidth;
    }

    override protected function getStageHeight():int {
        return stage.fullScreenHeight;
    }
}
}
