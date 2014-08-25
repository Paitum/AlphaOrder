package {

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class StringBreadcrumbs extends Sprite {
    protected var divisions:int;
    protected var fields:Vector.<TextField> = new Vector.<TextField>();
    protected var fontSize:Number;

    public function StringBreadcrumbs(divisions:int) {
        super();
        this.divisions = divisions;

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function reset():void {
        var length:int = fields.length;
        for(var i:int = 0; i < length; i++) {
            fields[i].text = "_";
            fields[i].alpha = 0.0;
        }

        fields[length-1].text = "_";
        fields[length-1].alpha = 1.0;
    }

    public function addToken(string:String, nextToken:String = null):void {
        var length:int = fields.length;

        if(nextToken == null) {
            fields[length-1].text = string;
            fields[length-1].alpha = 1.0;
            fields[length-1].color = Constants.TEXT_COLOR;
            fixTextFieldSize(fields[length-1]);
        } else {
            for(var i:int = 0; i < length - 2; i++) {
                fields[i].text = fields[i+1].text;
                fields[i].alpha = fields[i+1].alpha;
                fields[i].color = Constants.TEXT_COLOR;
                fixTextFieldSize(fields[i]);
            }

            fields[length-2].text = string;
            fields[length-2].alpha = 1.0;
            fields[length-2].color = Constants.TEXT_COLOR;
            fixTextFieldSize(fields[length-2]);

            setNextToken(nextToken);
        }
    }

    public function setNextToken(string:String):void {
        var lastToken:int = fields.length - 1;
        fields[lastToken].text = string;
        fields[lastToken].alpha = 0.75;
        fields[lastToken].color = Constants.BREADCRUMB_TEXT_COLOR;
        fixTextFieldSize(fields[lastToken]);
    }

    override public function get width():Number {
        return divisions;
    }

    override public function get height():Number {
        return 1;
    }

    private function handleAddedToStage(event:Event):void {
        var length:int = divisions;
        for(var i:int = 0; i < length; i++) {
//            var image:Image = new Image(Assets.assets.getTexture("Tile"));
//            image.width = 1;
//            image.height = 1;
//            image.x = i;
//            image.y = 0;
//            image.color = 0x4897FC;
//            addChild(image);

            var testField:TextField = createTextField(1,"A");
            var i2:int;
            var largestLetter:String = null;
            var largestLetterWidth:Number = -1;
            for(i2 = 0; i2 < 26; i2++) {
                var letter:String = String.fromCharCode(i2 + "A".charCodeAt());
                testField.text = letter;
                if(testField.textBounds.width > largestLetterWidth) {
                    largestLetterWidth = testField.textBounds.width;
                    largestLetter = testField.text;
                }
            }
            fontSize = largestLetterWidth;

            const size:Number = 1;
            var textField:TextField = createTextField(fontSize, largestLetter);
            addChild(textField);
            textField.hAlign = HAlign.CENTER;
            textField.color = Constants.TEXT_COLOR;
            textField.pivotX = textField.width / 2;
            textField.pivotY = textField.height / 2;
            textField.x = i + 0.5;
            textField.y = 0.5;
            fields.push(textField);
        }
    }

    private function createTextField(fontSize:Number, msg:String):TextField {
        var textField:TextField = new TextField(width, height, msg, Constants.DEFAULT_FONT, fontSize, 0xFFFFFF);
        textField.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
        return textField;
    }

    private function fixTextFieldSize(textField:TextField):void {
        textField.pivotX = textField.width / 2;
        textField.pivotY = textField.height / 2;
    }
}
}
