package {

import starling.utils.AssetManager;

[SWF(width="480", height="720", frameRate="30", backgroundColor="#0000AA")]
public class SWF extends Startup {
    public function SWF() {
        super();
    }


    override protected function getScreenWidth():int {
        return 480;
    }

    override protected function getScreenHeight():int {
        return 720;
    }

    override protected function initializeAssets(scale:Number):void {
        Assets.assets = new AssetManager(scale);

//        if(scale == 1) {
//            Assets.assets.enqueue(SWF_Assets_1x);
//        } else if(scale == 2) {
//            Assets.assets.enqueue(SWF_Assets_2x);
//        } else {
//            throw new Error("Unsupported scale");
//        }

        Assets.assets.enqueue(SWF_Assets_1x);
        Assets.assets.enqueue(SWF_Assets_Sounds);
    }
}
}
