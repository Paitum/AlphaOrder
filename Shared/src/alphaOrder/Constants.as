package alphaOrder {

import starling.errors.AbstractClassError;

public class Constants {
    public function Constants() { throw new AbstractClassError(); }

    public static const DEFAULT_FONT:String = "Souses";

    public static const BACKGROUND_COLOR:uint = 0x0046FF;
    public static const DETAIL_COLOR:uint = 0xFFED26;
    public static const TEXT_COLOR:uint = 0xFFED26;
    public static const BREADCRUMB_TEXT_COLOR:uint = 0x888888;
    public static const TILE_COLOR1:uint = 0x9BC6FF;
    public static const TILE_COLOR2:uint = 0x64A7FF;
    public static const TILE_HIGHLIGHT_CORRECT:uint = 0x00FF00;
    public static const TILE_HIGHLIGHT_INCORRECT:uint = 0xFF0000;

    public static const WRONG_SOUNDS:Vector.<String> = new <String>["No", "Noo", "Nooo", "Noooo", "Nope"];
}
}
