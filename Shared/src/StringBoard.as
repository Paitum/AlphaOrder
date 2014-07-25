package {
import starling.display.DisplayObjectContainer;
import starling.text.TextField;

public class StringBoard extends Board {

    public function StringBoard(model:BoardModel, callback:Function) {
        super(model, callback);
    }

    override protected function createPiece(token:String):DisplayObjectContainer {
        var piece:TextField = new TextField(1, 1, token, "ArtBrushLarge", 0.9, 0xFFFFFF);
        piece.hAlign = "center";
        piece.vAlign = "center";
        piece.pivotX = piece.width / 2;
        piece.pivotY = piece.height / 2;
        return piece;
    }
}
}
