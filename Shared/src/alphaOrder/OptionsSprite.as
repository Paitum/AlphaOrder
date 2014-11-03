package alphaOrder {

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class OptionsSprite extends Sprite {
    protected var background:Quad;

    [Event(name="optionsEvent", type="starling.events.Event")]
    public static const OPTIONS_EVENT:String = "optionsEvent";

    public function OptionsSprite() {
        super();
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    private function handleAddedToStage(event:Event):void {
        initialize();
    }

    override public function get height():Number {
        return 1;
    }

    override public function get width():Number {
        return 1;
    }

    private function initialize():void {
        // Wait until added to stage
        if(stage == null) {
            return;
        }

        var stageHeight:int = stage.stageHeight;
        var stageWidth:int = stage.stageWidth;

        if(background == null) {
            background = new Quad(1, 1, 0xFF0000);
            addChild(background);
//            background.pivotX = background.width / 2;
//            background.pivotY = background.height / 2;
        }
    }
}
}
