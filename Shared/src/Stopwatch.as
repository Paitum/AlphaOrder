package {

import flash.utils.getTimer;

public class Stopwatch {
    private var startTime:uint = 0;
    private var accumulatedTime:uint = 0;
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
        this.startTime = getTimer();
        isRunning = true;
    }

    [Inline]
    final public function stop():void {
        accumulatedTime = getAccumulatedTime();
        isRunning = false;
    }

    [Inline]
    final public function getAccumulatedTime():uint {
        return isRunning ? getTimer() - startTime + accumulatedTime :
                accumulatedTime;
    }
}
}
