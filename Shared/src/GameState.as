package {

import citrus.core.starling.StarlingState;

import starling.display.Quad;
import starling.events.Event;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;

public class GameState extends StarlingState {

    [Embed(source="../media/fonts/ArtBrush72.fnt", mimeType="application/octet-stream")]
    public static const ArtBrush72Xml:Class;

    [Embed(source = "../media/fonts/ArtBrush72.png")]
    public static const ArtBrush72Texture:Class;

    private var textField:TextField;
    private var counter:int = 0;

    public function GameState() {
        super();

        addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    private function handleEnterFrame(event:Event):void {
        if(textField != null) {
            textField.text = counter.toString();
            counter++;
        }
    }

    override public function initialize():void {
        super.initialize();

        stage.color = 0x222288;

        var texture:Texture = Texture.fromBitmap(new ArtBrush72Texture());
        var xml:XML = XML(new ArtBrush72Xml());
        TextField.registerBitmapFont(new BitmapFont(texture, xml));

        var quad:Quad = new Quad(200,100, 0xEEEEEE);
        quad.pivotX = quad.width / 2;
        quad.pivotY = quad.height;
        quad.x = _ce.baseWidth / 2;
        quad.y = _ce.baseHeight;
        addChild(quad);

        textField = new TextField(quad.width, quad.height, "000", "ArtBrush72", 72, 0xFFFFFF);
        textField.hAlign = "left";
        textField.vAlign = "bottom";
        textField.pivotX = quad.pivotX;
        textField.pivotY = quad.pivotY;
        textField.x = quad.x;
        textField.y = quad.y;
        addChild(textField);
    }
}
}