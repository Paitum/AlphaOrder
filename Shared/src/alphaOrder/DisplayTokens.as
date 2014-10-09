package alphaOrder {
import flash.utils.Dictionary;

import starling.display.DisplayObject;

public class DisplayTokens {
    // name:String -> DisplayObject
    protected var displayObjects:Dictionary = new Dictionary();

    public function DisplayTokens(tokens:Vector.<String>) {

        var length:int = tokens.length;
        for(var i:int = 0; i < length; i++) {
            createDisplayObject(tokens[i]);
            displayObjects[tokens[i]].touchable = false;
    }
    }

    protected function createDisplayObject(token:String):void {
        // subclass to implement
    }

    public function getDisplayObject(token:String):DisplayObject {
        return displayObjects[token];
    }
}
}
