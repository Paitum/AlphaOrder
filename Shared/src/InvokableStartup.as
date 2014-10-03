package {

import flash.desktop.NativeApplication;
import flash.events.InvokeEvent;

/**
 * Lifecycle:
 *
 * I. On NativeApplication INVOKE:
 *    1. processInvokeEvent()
 *    2. super.bootstrapLaunch()
 *
 */
public class InvokableStartup extends Startup {

    public function InvokableStartup() {
        super();
        trace("Startup [Desktop]");

        NativeApplication.nativeApplication.addEventListener(
            InvokeEvent.INVOKE, onInvokeEvent);
    }

    override protected function launch():void {
        // Delay execution of super.launch() until after InvokeEvent.INVOKE
    }

    private function onInvokeEvent(invocation:InvokeEvent):void {
        NativeApplication.nativeApplication.removeEventListener(InvokeEvent.INVOKE, onInvokeEvent);

        processInvokeEvent(invocation);

        super.launch();
    }

    protected function processInvokeEvent(invocation:InvokeEvent):void {

    }
}
}
