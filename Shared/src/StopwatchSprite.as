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
    protected var pivotQuad:Quad;
    protected var fontsize:int;

    protected var widths:Vector.<int> = new Vector.<int>(9, true);

    public function StopwatchSprite(fontsize:int) {
        this.fontsize = fontsize;
        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function getStopwatch():Stopwatch {
        return stopwatch;
    }

    private function handleAddedToStage(event:Event):void {
        var separationOffset:int = 0;
        var msOffset:int = fontsize / 4;

        secondsField = new TextField(500, 500, "0", "ArtBrushLarge", fontsize, 0xFFFFFF);

        secondsField.text = "";
        for(var i:int = 0; i < widths.length; i++) {
            secondsField.text += "0";
            widths[i] = secondsField.textBounds.width;
        }

        secondsField.text = "0";
        secondsField.hAlign = "left";
        secondsField.vAlign = "top";
        secondsField.pivotX = secondsField.width + separationOffset;
        secondsField.pivotY = secondsField.textBounds.height / 2;
        secondsField.x = 0;
        secondsField.y = 0;
//trace("(" + secondsField.x + ", " + secondsField.y + ")[" + secondsField.width + ", " + secondsField.height + "] pivot[" + secondsField.pivotX + ", " + secondsField.pivotY + "]");
        secondsField.color = 0x00FF00;

        secondsQuad = new Quad(secondsField.width, secondsField.height, 0xFFFF00);
        secondsQuad.pivotX = secondsField.pivotX;
        secondsQuad.pivotY = secondsField.pivotY;
        secondsQuad.x = secondsField.x;
        secondsQuad.y = secondsField.y;
        secondsQuad.alpha = 0.25;

        millisecondsField = new TextField(500, 500, "000", "ArtBrushLarge", fontsize * 0.5, 0xFFFFFF);
        millisecondsField.hAlign = "left";
        millisecondsField.vAlign = "top";
        millisecondsField.pivotX = -separationOffset;
        millisecondsField.pivotY = secondsField.textBounds.height / 2 - msOffset;
//        millisecondsField.y = millisecondsField.textBounds.height;
        millisecondsField.color = 0x00FF00;

        millisecondsQuad = new Quad(millisecondsField.width, millisecondsField.height, 0xFFFF00);
        millisecondsQuad.pivotX = millisecondsField.pivotX;
        millisecondsQuad.pivotY = millisecondsField.pivotY;
        millisecondsQuad.x = millisecondsField.x;
        millisecondsQuad.y = millisecondsField.y;
        millisecondsQuad.alpha = 0.25;

//        addChild(millisecondsQuad);
//        addChild(secondsQuad);
        addChild(millisecondsField);
        addChild(secondsField);

//        pivotQuad = new Quad(5, 5, 0xFF0000);
//        pivotQuad.pivotX = pivotQuad.width / 2;
//        pivotQuad.pivotY = pivotQuad.height / 2;
//        addChild(pivotQuad);
    }

    public function advanceTime(passedTime:Number):void {
        var time:uint = stopwatch.getAccumulatedTime();
        var seconds:uint      = uint(time / 1000);
        var milliseconds:uint = int((time - seconds * 1000) / 100 );
        var secondsStr:String = seconds.toString();
        var msStr:String = milliseconds.toString();

        secondsField.text = secondsStr;
        secondsField.width = -widths[secondsStr.length];
        secondsField.pivotX = secondsField.width - 20;

        secondsQuad.width = secondsField.width;
        millisecondsField.text = msStr;
//        millisecondsField.text = msStr.length == 1 ? "0" + msStr : msStr;
        pivotX = -widths[secondsStr.length] / 2;
//        pivotQuad.x = pivotX;
//        pivotQuad.y = pivotY;
    }
}
}
