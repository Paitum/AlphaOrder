package {

import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;
import starling.utils.AssetManager;

[SWF(width="480", height="720", frameRate="30", backgroundColor="#0000AA")]
public class SWF extends Startup {
    [Embed(source="../../Shared/media/fonts/1x/ArtBrushLarge.fnt", mimeType="application/octet-stream")]
    public static const ArtBrushLarge_1xFNT:Class;
    [Embed(source="../../Shared/media/fonts/1x/ArtBrushLarge.png")]
    public static const ArtBrushLarge_1xPNG:Class;
    
    [Embed(source="../../Shared/media/fonts/2x/ArtBrushLarge.fnt", mimeType="application/octet-stream")]
    public static const ArtBrushLarge_2xFNT:Class;
    [Embed(source="../../Shared/media/fonts/2x/ArtBrushLarge.png")]
    public static const ArtBrushLarge_2xPNG:Class;

    public function SWF() {
        super();
    }

    override protected function initializeAssets(scale:Number):void {
        Assets.assets = new AssetManager(scale);

        var texture:Texture;
        var xml:XML;

        // Load Bitmap Font
        if(scale == 1) {
            texture = Texture.fromBitmap(new ArtBrushLarge_1xPNG());
            xml = XML(new ArtBrushLarge_1xFNT());
        } else if(scale == 2) {
            texture = Texture.fromBitmap(new ArtBrushLarge_2xPNG());
            xml = XML(new ArtBrushLarge_2xFNT());
        } else {
            throw new Error("Unsupported scale");
        }

        TextField.registerBitmapFont(new BitmapFont(texture, xml));
    }
}
}
