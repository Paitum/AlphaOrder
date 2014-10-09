package alphaOrder {
import starling.text.TextField;
import starling.text.TextFieldAutoSize;

public class StringDisplayTokens extends DisplayTokens {
    private var fontName:String = null;

    public static function createStringDisplayTokensForLetters(letters:String, fontName:String):StringDisplayTokens
    {
        var names:Vector.<String> = new Vector.<String>();
        for(var i:int = 0; i < letters.length; i++) {
            names.push(letters.charAt(i));
        }

        return new StringDisplayTokens(names, fontName);
    }

    public function StringDisplayTokens(tokens:Vector.<String>, fontName:String) {
        this.fontName = fontName;
        super(tokens);
    }

    override protected function createDisplayObject(token:String):void {
        if(fontName == null) {
            throw new Error("Must specify font characteristics");
        }

        const fontSize:Number = 0.9;
        var piece:TextField = new TextField(1, 1, token, fontName, fontSize, 0xFFFFFF);
        piece.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
        piece.pivotX = piece.width / 2;
        piece.pivotY = piece.height / 2;
        piece.color = Constants.TEXT_COLOR;
        displayObjects[token] = piece;
    }
}
}
