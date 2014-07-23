package {
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

public class Board extends Sprite {
    private var divisions:int;

    public function Board(divisions:int) {
        this.divisions = divisions;

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    override public function get width():Number {
        return divisions;
    }

    override public function get height():Number {
        return divisions;
    }

    private function handleAddedToStage(event:Event):void {
        var quad:Quad;
        var divisions:int = 3;

        for(var r:int = 0; r < divisions; r++) {
            for(var c:int = 0; c < divisions; c++) {
                quad = new Quad(1, 1, randomColor());
                quad.x = c;
                quad.y = r;
                addChild(quad);
            }
        }
    }

    private static function randomColor():uint {
        return uint(Math.random() * 255) << 16 | uint(Math.random() * 255) << 8 | uint(Math.random() * 255);
    }
}
}
