package {
import starling.display.DisplayObjectContainer;
import starling.text.TextField;

public class StringBoard extends Board {
    private var fontSize:Number = NaN;
    private var fontName:String = null;

    public function StringBoard(model:BoardModel, fontName:String, fontSize:Number, callback:Function) {
        this.fontName = fontName;
        this.fontSize = fontSize;

        super(model, callback);
    }


    override protected function createPiece(token:String):DisplayObjectContainer {
        if(fontName == null || isNaN(fontSize)) {
            throw new Error("Must specify font characteristics");
        }

        var piece:TextField = new TextField(2, 2, token, fontName, fontSize, 0xFFFFFF);
        piece.hAlign = "center";
        piece.vAlign = "center";
        piece.pivotX = piece.width / 2;
        piece.pivotY = piece.height / 2;
        return piece;
    }
}
}
