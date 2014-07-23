package {

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
    protected var fontsize:int;

    public function StopwatchSprite(fontsize:int) {
        this.fontsize = fontsize;
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function getStopwatch():Stopwatch {
        return stopwatch;
    }

    private function handleAddedToStage(event:Event):void {
        var offset:int = fontsize / 10;

        secondsField = new TextField(500, 500, "00000", "ArtBrushLarge", fontsize, 0xFFFFFF);
        secondsField.hAlign = "right";
        secondsField.vAlign = "top";
        secondsField.pivotX = secondsField.width + offset;
        secondsField.pivotY = 0;
        secondsField.x = 0;
        secondsField.y = 0;
//trace("(" + secondsField.x + ", " + secondsField.y + ")[" + secondsField.width + ", " + secondsField.height + "] pivot[" + secondsField.pivotX + ", " + secondsField.pivotY + "]");
        secondsField.color = 0x00FF00;

        secondsQuad = new Quad(secondsField.width, secondsField.height, 0xFFFF00);
        secondsQuad.pivotX = secondsField.pivotX;
        secondsQuad.pivotY = secondsField.pivotY;
        secondsQuad.x = secondsField.x;
        secondsQuad.y = secondsField.y;

        millisecondsField = new TextField(500, 500, "000", "ArtBrushLarge", fontsize * 0.66, 0xFFFFFF);
        millisecondsField.hAlign = "left";
        millisecondsField.vAlign = "top";
        millisecondsField.pivotX = -offset;
        millisecondsField.pivotY = -offset;
        millisecondsField.color = 0x00FF00;
//        millisecondsField.x = 0;
//        millisecondsField.y = 0;

        millisecondsQuad = new Quad(millisecondsField.width, millisecondsField.height, 0xFFFF00);
        millisecondsQuad.pivotX = millisecondsField.pivotX;
        millisecondsQuad.pivotY = millisecondsField.pivotY;
        millisecondsQuad.x = millisecondsField.x;
        millisecondsQuad.y = millisecondsField.y;

//        addChild(millisecondsQuad);
//        addChild(secondsQuad);
        addChild(millisecondsField);
        addChild(secondsField);

    }

    public function advanceTime(passedTime:Number):void {
        var time:uint = stopwatch.getAccumulatedTime();
        var seconds:uint      = uint(time / 1000);
        var milliseconds:uint = int((time - seconds * 1000) / 10 );
        var msStr:String = milliseconds.toString();

        secondsField.text = seconds.toString();
        millisecondsField.text = msStr.length == 1 ? "0" + msStr : msStr;
    }
}
}
