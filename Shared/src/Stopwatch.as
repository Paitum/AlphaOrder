package {

import starling.animation.IAnimatable;

public class Stopwatch implements IAnimatable {
    private var accumulatedTime:Number = 0;
    private var isRunning:Boolean = false;

    public function Stopwatch() {
    }

    [Inline]
    final public function reset():void {
        accumulatedTime = 0;
        isRunning = false;
    }

    [Inline]
    final public function start():void {
        isRunning = true;
    }

    [Inline]
    final public function stop():void {
        isRunning = false;
    }

    [Inline]
    final public function setAccumulatedTime(time:Number):void {
        accumulatedTime = time;
    }

    [Inline]
    final public function getAccumulatedTime():Number {
        return accumulatedTime;
    }

    [Inline]
    final public function advanceTime(passedTime:Number):void {
        if(isRunning) accumulatedTime += passedTime;
    }
}
}
