package test {
import starling.animation.IAnimatable;
import starling.animation.Transitions;
import starling.display.Quad;
import starling.events.Event;
import starling.events.EventDispatcher;

public class QuadColorTween extends EventDispatcher implements IAnimatable {
    private var target:Quad;
    private var fromColor:uint;
    private var toColor:uint;
    private var fromAlpha:Number;
    private var toAlpha:Number;
    private var duration:Number;
    private var transitionFunc:Function;
    private var totalTime:Number = 0;
    private var initializedFromColor = false;

    public function QuadColorTween(target:Quad, duration:Number, transition:Object="linear") {
        this.target = target;
        initializedFromColor = false;
        this.toColor = toColor;
        this.duration = duration;

        if(transition is String)
            this.transitionFunc = Transitions.getTransition(transition as String);
        else if(transition is Function)
            this.transitionFunc = transition as Function;
        else
            throw new ArgumentError("Transition must be either a string or a function");
    }

    public function setToColor(toColor:uint, alpha:Number):void {
        this.toColor = toColor;
        this.toAlpha = alpha;
    }

    public function advanceTime(time:Number):void {
        if(!initializedFromColor) {
            this.fromColor = target.color;
            this.fromAlpha = target.alpha;
            initializedFromColor = true;
        }

        totalTime += time;
        var ratio:Number = totalTime / duration;
        ratio = transitionFunc(ratio);

        var tr:Number = toColor >> 16 & 0xFF;
        var tg:Number = toColor >>  8 & 0xFF;
        var tb:Number = toColor & 0xFF;
        var fr:Number = fromColor >> 16 & 0xFF;
        var fg:Number = fromColor >>  8 & 0xFF;
        var fb:Number = fromColor & 0xFF;
        var r:Number = fr + ratio * (tr - fr);
        var g:Number = fg + ratio * (tg - fg);
        var b:Number = fb + ratio * (tb - fb);
        target.color = r << 16 | g << 8 | b;
        target.alpha = fromAlpha + ratio * (toAlpha - fromAlpha);

        if(ratio >= 1.0) {
            dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
        }
    }
}
}
