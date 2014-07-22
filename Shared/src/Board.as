package {
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class Board extends Sprite {

    public function Board() {
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    private function handleAddedToStage(event:Event):void {
        var q:Quad = new Quad(200, 200);
        addChild(q);
    }

}
}
