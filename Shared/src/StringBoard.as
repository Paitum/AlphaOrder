package {

import flash.utils.Dictionary;

import starling.display.DisplayObjectContainer;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;

public class StringBoard extends Board {
    private var fontName:String = null;

    public function StringBoard(model:BoardModel, fontName:String, callback:Function) {
        this.fontName = fontName;

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
        if(fontName == null) {
            throw new Error("Must specify font characteristics");
        }

        const fontSize:Number = 0.9;
        var piece:TextField = new TextField(2, 2, token, fontName, fontSize, 0xFFFFFF);
        piece.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
        piece.pivotX = piece.width / 2;
        piece.pivotY = piece.height / 2;
        return piece;
    }
}
}
