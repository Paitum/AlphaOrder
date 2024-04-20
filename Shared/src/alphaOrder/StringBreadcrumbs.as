package alphaOrder {

import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.utils.HAlign;

public class StringBreadcrumbs extends Sprite {
    protected var _width:int;
    protected var _height:int;
    protected var isLandscape:Boolean;
    protected var divisions:int;
    protected var insertPosition:int;
    protected var fields:Vector.<TextField>;
    protected var model:AlphaOrderBoardModel;

    [Event(name="crumbEvent", type="starling.events.Event")]
    public static const BOARD_EVENT:String = "crumbEvent";

    public function StringBreadcrumbs(width:Number, height:Number, isLandscape:Boolean, model:AlphaOrderBoardModel) {
        super();

        setup(width, height, isLandscape, model);
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function setDimensions(width:Number, height:Number, isLandscape:Boolean):void {
        setup(width, height, isLandscape, model);
    }

    public function setModel(model:AlphaOrderBoardModel):void {
        setup(_width, _height, isLandscape, model);
    }

    public function setup(width:Number, height:Number, isLandscape:Boolean, model:AlphaOrderBoardModel):void {
        this._width = width;
        this._height = height;
        this.isLandscape = isLandscape;
        this.divisions = isLandscape ? height / width : width / height;
        scaleX = scaleY = isLandscape ? width : height;

        this.model = model;
        initialize();
    }

    override public function get width():Number {
        return isLandscape ? 1 : divisions;
    }

    override public function get height():Number {
        return isLandscape ? divisions : 1;
    }

    private function handleAddedToStage(event:Event):void {
        initialize();
    }

    private function initialize():void {
        // Wait until added to stage
        if(stage == null) {
            return;
        }

        if(fields == null) {
            fields = new Vector.<TextField>()
        }

        var i:int;
        var currentLength:int = fields.length;

        // Remove unneeded fields
        if(divisions < currentLength) {
            for(i = currentLength; i < divisions; i++) {
                fields[i].removeEventListener(TouchEvent.TOUCH, handleTouch);
                removeChild(fields[i]);
                fields[i] = null;
            }
        }

        fields.length = divisions;

        // Determine font-size to accomodate the largest letter
        var testField:TextField = createTextField(1,"A");
        var largestLetter:String = null;
        var largestLetterSize:Number = -1;
        for(i = 0; i < 26; i++) {
            testField.text = String.fromCharCode(i + "A".charCodeAt());
            if(testField.textBounds.width > largestLetterSize) {
                largestLetterSize = testField.textBounds.width;
                largestLetter = testField.text;
            }
        }

        if(currentLength < divisions) {
            for(i = 0; i < divisions; i++) {
                if(fields[i] == null) {
                    fields[i] = createTextField(largestLetterSize, largestLetter);
                    fields[i].addEventListener(TouchEvent.TOUCH, handleTouch);
                    addChild(fields[i]);
                }
            }
        }

        for(i = 0; i < divisions; i++) {
            fields[i].fontSize = largestLetterSize;
            fields[i].hAlign = HAlign.CENTER;
            fields[i].color = Constants.TEXT_COLOR;
            fields[i].pivotX = fields[i].width / 2;
            fields[i].pivotY = fields[i].height / 2;
            fields[i].x = isLandscape ? 0.5 : i + 0.5;
            fields[i].y = isLandscape ? i + 0.5 : 0.5;
        }

        clear();
    }

    /**
     * Clears the breadcrumbs
     */
    public function clear():void {
        if(fields == null) {
            return;
        }

        var length:int = fields.length;
        var i:int;
        for(i = 0; i < length; i++) {
            fields[i].text = "_";
            fields[i].alpha = 0.0;
        }

        insertPosition = isLandscape ? 0 : (length - 1);

        var count:int = model.getPastTokenCount();
        for(i = count; i >= 0; i--) {
            var token:String = model.getPastToken(i);

            if(token != null) {
                if(i < count) shiftTokens();
                setNextToken(token, false);
            }
        }

        var solution:String = model.getCurrentSolutionToken();
        if(solution != null) {
            setNextToken(solution, true);
        }
    }

    public function shiftTokens():void {
        var length:int = fields.length;

        insertPosition++;

        if(insertPosition > length - 1) {
            insertPosition = length - 1;

            // scroll fields
            for(var i:int = 0; i < length - 1; i++) {
                fields[i].text = fields[i+1].text;
                fields[i].alpha = fields[i+1].alpha;
                fields[i].color = Constants.TEXT_COLOR;
                fixTextFieldSize(fields[i]);
            }
        }

    }

    public function setNextToken(string:String, isHint:Boolean):void {
        fields[insertPosition].text = string;
        fields[insertPosition].alpha = isHint ? 0.75 : 1.0;
        fields[insertPosition].color = isHint ? Constants.BREADCRUMB_TEXT_COLOR : Constants.TEXT_COLOR;
        fixTextFieldSize(fields[insertPosition]);
    }

    private function handleTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null || touch.phase != TouchPhase.BEGAN) {
            return;
        }

        if(event.currentTarget is TextField) {
            var textField:TextField = event.currentTarget as TextField;

            if(textField != null && textField.alpha > 0.2) {
                if(textField.text != null) {
                    dispatchEvent(new BreadcrumbEvent(BreadcrumbEvent.TOKEN_TOUCHED, textField.text));
                }
            }
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