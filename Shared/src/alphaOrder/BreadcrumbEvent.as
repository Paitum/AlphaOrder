package alphaOrder {
import starling.events.Event;

public class BreadcrumbEvent extends Event {
    public static const TOKEN_TOUCHED:String = "tokenTouched";

    public var token:String;

    public function BreadcrumbEvent(type:String, token:String) {
        super(type);
        this.token = token;
    }

    public function getToken():String {
        return token;
    }

}
}