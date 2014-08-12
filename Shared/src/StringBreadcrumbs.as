package {

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.utils.HAlign;

public class StringBreadcrumbs extends Sprite {
    protected var divisions:int;
    protected var fields:Vector.<TextField> = new Vector.<TextField>();

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
            fields[length-1].color = 0xFFFF00;
        } else {
            for(var i:int = 0; i < length - 2; i++) {
                fields[i].text = fields[i+1].text;
                fields[i].alpha = fields[i+1].alpha;
                fields[i].color = 0xFFFF00;
            }

            fields[length-2].text = string;
            fields[length-2].alpha = 1.0;
            fields[length-2].color = 0xFFFF00;

            setNextToken(nextToken);
        }
    }

    public function setNextToken(string:String):void {
        var lastToken:int = fields.length - 1;
        fields[lastToken].text = string;
        fields[lastToken].alpha = 0.75;
        fields[lastToken].color = 0x888888;
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

            var textField:TextField = createTextField(1, 1, "A");
            addChild(textField);
            textField.hAlign = HAlign.CENTER;
            textField.color = 0xFFFF00;
            textField.pivotX = textField.width / 2;
            textField.pivotY = textField.height;
            textField.x = i + 0.5;
            textField.y = 1;
            textField.scaleX = 1.2;
            //noinspection JSSuspiciousNameCombination
            textField.scaleY = textField.scaleX;
            fields.push(textField);
        }
    }

    private function createTextField(width:int, height:int, msg:String):TextField {
        var fontSize:int = Math.min(width, height) * 1.1;
        var textField:TextField = new TextField(width, height, msg, "ArtBrushLarge", fontSize, 0xFFFFFF);
        textField.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
        return textField;
    }
}
}