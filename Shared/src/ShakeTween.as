package {
import starling.animation.IAnimatable;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.events.EventDispatcher;

public class ShakeTween extends EventDispatcher implements IAnimatable {
    private var target:DisplayObjectContainer;
    private var distance:Number;
    private var duration:Number;
    private var totalTime:Number = 0;
    private var startX:Number = NaN;
    private var startY:Number = NaN;

    public function ShakeTween(distance:Number, duration:Number) {
        this.distance = distance;
        this.duration = duration;
    }

    public function getTarget():DisplayObjectContainer {
        return target;
    }

    public function setTarget(target:DisplayObjectContainer):void {
        this.target = target;
        startX = NaN;
        startY = NaN;
        totalTime = 0.0;
    }

    public function advanceTime(time:Number):void {
        if(target == null) {
            return;
        }

        if(isNaN(startX) || isNaN(startY)) {
            startX = target.x;
            startY = target.y;
        }

        totalTime += time;
        var ratio:Number = totalTime / duration;

        if(ratio < 1.0) {
            var multiplier:Number = transition(ratio);
            target.x = startX + multiplier * distance;
        } else {
            target.x = startX;
            dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
        }
    }

    private function transition(ratio:Number):Number {
        const cycles:int = 3;
        var stretch:Number = ratio * cycles;
        var distance:Number = stretch - Math.floor(stretch);
        return Math.sin(distance * 2 * Math.PI);
    }

    public function stop():void {
        totalTime = duration;
    }

    public function isComplete():Boolean {
        return totalTime >= duration;
    }
}
}
