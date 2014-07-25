package {
import flash.geom.Point;

import starling.display.DisplayObjectContainer;
import starling.text.TextField;

public class StringBoard extends Board {
    private var fontSize:Number = NaN;
    private var fontName:String = null;
    private var offset:Point;

    public function StringBoard(model:BoardModel, fontName:String, fontSize:Number, offset:Point, callback:Function) {
        this.fontName = fontName;
        this.fontSize = fontSize;
        this.offset = offset;

        super(model, callback);
    }


    override protected function createPiece(token:String):DisplayObjectContainer {
        if(fontName == null || isNaN(fontSize)) {
            throw new Error("Must specify font characteristics");
        }

        var piece:TextField = new TextField(2, 2, token, fontName, fontSize, 0xFFFFFF);
        piece.hAlign = "center";
        piece.vAlign = "center";
        piece.pivotX = piece.width / 2 + offset.x;
        piece.pivotY = piece.height / 2 + offset.y;
        return piece;
    }
}
}
