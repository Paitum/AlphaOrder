package {
import flash.geom.Point;
import flash.utils.Dictionary;

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


    override protected function initializePieces():void {
        pieces = new Dictionary();
        var characters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for(var i:int = 0; i < characters.length; i++) {
            var token:String = characters.charAt(i);
            pieces[token] = createPiece(token);
            pieces[token].color = 0xFFED26;
            pieces[token].touchable = false;
        }
    }

    protected function createPiece(token:String):DisplayObjectContainer {
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
