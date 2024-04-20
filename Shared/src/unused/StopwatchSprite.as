package unused {

import alphaOrder.Constants;

import starling.animation.IAnimatable;
import starling.display.Quad;

import starling.text.TextField;
import starling.display.Sprite;
import starling.events.Event;

public class StopwatchSprite extends Sprite implements IAnimatable {
    private var stopwatch:Stopwatch = new Stopwatch();
    protected var secondsField:TextField;
    protected var secondsQuad:Quad;
    protected var millisecondsField:TextField;
    protected var millisecondsQuad:Quad;
    protected var pivotQuad:Quad;
    protected var fontsize:int;
    protected var msShow:Boolean = false;
    protected var msAdded:Boolean = false;

    private static const DEBUG:Boolean = false;

    protected var widths:Vector.<int> = new Vector.<int>(9, true);

    public function StopwatchSprite(fontsize:int) {
        this.fontsize = fontsize;
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function setAccumulatedTime(time:Number):void {
        stopwatch.setAccumulatedTime(time);
        updateFields();
    }

    public function getStopwatch():Stopwatch {
        return stopwatch;
    }

    private function handleAddedToStage(event:Event):void {
        if(secondsField == null) {
            initialize();
        }
    }

    private function initialize():void {
        var separationOffset:int = -fontsize / 2.5;
        var pivotOffset:int = -fontsize / 15;
        var msOffset:int = fontsize / 4;

        // TODO Don't instantiate again just because added back to stage
        secondsField = new TextField(500, 500, "0", Constants.DEFAULT_FONT, fontsize, 0xFFFFFF);
        secondsField.touchable = false;

        var i:int;
        var largestLetter:int = -1;
        var largestLetterWidth:Number = -1;
        for(i = 0; i < 10; i++) {
            secondsField.text = i.toString();
            if(secondsField.textBounds.width > largestLetterWidth) {
                largestLetterWidth = secondsField.textBounds.width;
                largestLetter = i;
            }
        }

        secondsField.text = "";
        for(i = 0; i < widths.length; i++) {
            secondsField.text += largestLetter.toString();
            widths[i] = Math.abs(secondsField.textBounds.width);
        }

        secondsField.text = "0";
        secondsField.hAlign = "left";
        secondsField.vAlign = "top";
        secondsField.pivotX = secondsField.width + pivotOffset;
        secondsField.pivotY = secondsField.textBounds.height / 2;
        secondsField.x = 0;
        secondsField.y = pivotOffset;
//trace("(" + secondsField.x + ", " + secondsField.y + ")[" + secondsField.width + ", " + secondsField.height + "] pivot[" + secondsField.pivotX + ", " + secondsField.pivotY + "]");
        secondsField.color = Constants.TEXT_COLOR;


        millisecondsField = new TextField(500, 500, "000", Constants.DEFAULT_FONT, fontsize * 0.5, 0xFFFFFF);
        millisecondsField.touchable = false;
        millisecondsField.hAlign = "left";
        millisecondsField.vAlign = "top";
        millisecondsField.pivotX = -separationOffset;
        millisecondsField.pivotY = secondsField.textBounds.height / 2 - msOffset;
//        millisecondsField.y = millisecondsField.textBounds.height;
        millisecondsField.color = Constants.TEXT_COLOR;

        if(DEBUG) {
            secondsQuad = new Quad(secondsField.width, secondsField.height, 0xFFFF00);
            secondsQuad.touchable = false;
            secondsQuad.pivotX = secondsField.pivotX;
            secondsQuad.pivotY = secondsField.pivotY;
            secondsQuad.x = secondsField.x;
            secondsQuad.y = secondsField.y;
            secondsQuad.alpha = 0.25;
            addChild(secondsQuad);

            millisecondsQuad = new Quad(millisecondsField.width, millisecondsField.height, 0xFFFF00);
            millisecondsQuad.touchable = false;
            millisecondsQuad.pivotX = millisecondsField.pivotX;
            millisecondsQuad.pivotY = millisecondsField.pivotY;
            millisecondsQuad.x = millisecondsField.x;
            millisecondsQuad.y = millisecondsField.y;
            millisecondsQuad.alpha = 0.25;
        }

        addChild(secondsField);

        if(DEBUG) {
            pivotQuad = new Quad(5, 5, 0xFF0000);
            pivotQuad.touchable = false;
            pivotQuad.pivotX = pivotQuad.width / 2;
            pivotQuad.pivotY = pivotQuad.height / 2;
            addChild(pivotQuad);
        }

        processMilliseconds(msShow);
    }

    public function showMilliseconds(show:Boolean):void {
        msShow = show;
        processMilliseconds(show);
    }

    public function getShowMilliseconds():Boolean {
        return msShow;
    }

    private function processMilliseconds(show:Boolean):void {
        // wait until initialized
        if(millisecondsField == null) {
            return;
        }

        updateFields();

        if(show && !msAdded) {
            if(DEBUG) addChild(millisecondsQuad);
            addChild(millisecondsField);
            msAdded = true;
        } else if(!show && msAdded) {
            if(DEBUG) removeChild(millisecondsQuad);
            removeChild(millisecondsField);
            msAdded = false;
        }
    }

    public function advanceTime(passedTime:Number):void {
        stopwatch.advanceTime(passedTime);
        updateFields();
    }

    private function updateFields():void {
        var time:Number = stopwatch.getAccumulatedTime();
        var seconds:uint      = Math.floor(time);
        var milliseconds:uint = int((time - seconds) * 100);
        var secondsStr:String = seconds.toString();
        var msStr:String = milliseconds.toString();

        secondsField.text = secondsStr;
        secondsField.width = widths[secondsStr.length];
        secondsField.pivotX = secondsField.width - fontsize / 5;

        millisecondsField.text = msStr.length == 1 ? "0" + msStr : msStr;
        pivotX = -widths[secondsStr.length] / 2;

        if(DEBUG) {
            secondsQuad.width = secondsField.width;
            pivotQuad.x = pivotX;
            pivotQuad.y = pivotY;
        }
    }
}
}