package alphaOrder {
import starling.events.Event;

public class BoardEvent extends Event {

    public static const START:int = 0;
    public static const FINISH:int = 1;
    public static const CORRECT:int = 2;
    public static const INCORRECT:int = 3;

    public var state:int;
    public var token:String;

    public function BoardEvent(type:String, state:int, token:String = null) {
        super(type);
        this.state = state;
        this.token = token;
    }

    public function getToken():String {
        return token;
    }

    public function getState():int {
        return state;
    }
}
}
