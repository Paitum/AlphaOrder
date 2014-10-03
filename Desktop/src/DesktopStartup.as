package {

import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.events.InvokeEvent;

import starling.core.Starling;

public class DesktopStartup extends InvokableStartup {

    protected var explicitScreenWidth:int = -1;
    protected var explicitScreenHeight:int = -1;

    public function DesktopStartup() {
        super();
    }

    override protected function processInvokeEvent(invocation:InvokeEvent):void {
        Starling.multitouchEnabled = false;
        Starling.handleLostContext = true;

        var window:NativeWindow = NativeApplication.nativeApplication.activeWindow;
        var width:int = 640;
        var height:int = 640;

        if(window == null) {
            throw new Error("NativeWindow is null");
        }

        if(invocation.arguments == null) {
            trace("Warning: No arguments provided. Defaulting to [" + width + " " + height + "] dimension");
        } else {
            trace("Arguments: " + invocation.arguments);
            // Account for window-frame
            explicitScreenWidth = int(invocation.arguments[0]);
            explicitScreenHeight = int(invocation.arguments[1]);
            width = explicitScreenWidth + window.width - window.stage.stageWidth;
            height = explicitScreenHeight + window.height - window.stage.stageHeight;
        }

        trace("Setting NativeWindow(" + window.width + ", " + window.height + ") to (" + width + ", " + height + ")");
        window.width = width;
        window.height = height;

        var length:int = invocation.arguments.length;
        for(var i:int = 0; i < length; i++) {
            if(invocation.arguments[i] == "debug") {
                trace("*** DEBUG ENABLED ***");
                debug = true;
            }
        }
    }

    override protected function getStageWidth():int {
        return explicitScreenWidth == -1 ? super.getStageWidth() : explicitScreenWidth;
    }

    override protected function getStageHeight():int {
        return explicitScreenHeight == - 1 ? super.getStageHeight() : explicitScreenHeight;
    }
}
}