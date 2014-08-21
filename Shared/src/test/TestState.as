package test {

import citrus.core.starling.StarlingState;

import starling.display.Quad;

import starling.text.TextField;
import starling.text.TextFieldAutoSize;

public class TestState extends StarlingState {

    public function TestState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        addTextField(20, 50, 10, 10, "A");
        addTextField(40, 50, 50, 50, "B");
        addTextField(100, 50, 100, 100, "C");
        addTextField(210, 50, 200, 200, "D");
        addTextField(20, 210, 50, 100, "E");
        addTextField(80, 210, 100, 50, "F");
        addTextField(80, 270, 50, 100, "Letters");
    }

    public function addTextField(x:int, y:int, width:int, height:int, msg:String):void {
        x += width / 2;
        y += height / 2;

        var quad:Quad = new Quad(width, height, 0xFF0000);
        quad.alpha = 0.25;
        quad.pivotX = quad.width / 2;
        quad.pivotY = quad.height / 2;
        quad.x = x;
        quad.y = y;
        addChild(quad);

        var textField:TextField = createTextField(width, height, msg);
        addChild(textField);
        textField.pivotX = textField.width / 2;
        textField.pivotY = textField.height / 2;
        textField.x = x;
        textField.y = y;

        quad = new Quad(textField.width, textField.height, 0xFFFF00);
        quad.alpha = 0.25;
        quad.pivotX = quad.width / 2;
        quad.pivotY = quad.height / 2;
        quad.x = x;
        quad.y = y;
        addChild(quad);

        trace("createTextField(" + width + ", " + height + ", " + msg + ") bounds[" + textField.getBounds(this) + "]");
    }

    public function createTextField(width:int, height:int, msg:String):TextField {
        var fontSize:int = Math.min(width, height) * 1.1;
        var textField:TextField = new TextField(width, height, msg, Constants.DEFAULT_FONT, fontSize, 0xFFFFFF);
        textField.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;

        return textField;
    }
}
}
