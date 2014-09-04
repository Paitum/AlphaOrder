package {

import citrus.core.starling.StarlingState;

import starling.display.Image;
import starling.display.Quad;

import starling.textures.Texture;

public class LoadState extends StarlingState {
    private var progress:Number;
    private var progressBar:Quad;
    private var loadingImage:Image;
    private var logoImage:Image;

    [Embed(source="../../Shared/media/textures/Loading.png")]
    public static const loadingPNG:Class;

    [Embed(source="../../Shared/media/textures/AlphaOrder.png")]
    public static const AlphaOrderPNG:Class;

    [Embed(source="../../Shared/media/textures/logo_white_size1.png")]
    public static const levelPNG:Class;

    public function LoadState() {
        super();
        progress = 0.0;
    }

    override public function initialize():void {
        super.initialize();

        stage.color = Constants.BACKGROUND_COLOR;

        progressBar = new Quad(1, 1, 0xFFFFFF);
        progressBar.pivotX = progressBar.width / 2;
        progressBar.pivotY = progressBar.height / 2;
        progressBar.x = stage.stageWidth / 2;
        progressBar.y = stage.stageHeight / 2;
        progressBar.scaleX = 0;
        progressBar.scaleY = stage.stageHeight;
        progressBar.alpha = 0;
        addChild(progressBar);

        var texture:Texture = Texture.fromBitmap(new loadingPNG());
        loadingImage = new Image(texture);
        loadingImage.pivotX = Math.floor(loadingImage.width / 2);
        loadingImage.pivotY = Math.floor(loadingImage.height / 2);
        loadingImage.x = Math.floor(stage.stageWidth * 0.5);
        loadingImage.y = Math.floor(stage.stageHeight * 0.66);
        loadingImage.color = Constants.TEXT_COLOR;
        var scale:Number = Math.max(loadingImage.width / stage.stageWidth,
                loadingImage.height / stage.stageHeight);
        scale *= 0.25;
        loadingImage.scaleX = scale;
        loadingImage.scaleY = scale;
        addChild(loadingImage);

        texture = Texture.fromBitmap(new AlphaOrderPNG());
        var title:Image = new Image(texture);
        title.pivotX = Math.floor(title.width / 2);
        title.pivotY = Math.floor(title.height / 2);
        title.x = Math.floor(stage.stageWidth * 0.5);
        title.y = Math.floor(stage.stageHeight * 0.33);
trace((stage.stageHeight * 0.2 / title.height) + " , " + (stage.stageWidth * 0.75 / title.width));
        scale = Math.min(stage.stageHeight * 0.2 / title.height, stage.stageWidth * 0.75 / title.width);
        title.scaleX = title.scaleY = scale;
        addChild(title);

        texture = Texture.fromBitmap(new levelPNG());
        logoImage = new Image(texture);
        logoImage.pivotX = Math.floor(logoImage.width / 2);
        logoImage.pivotY = Math.floor(logoImage.height / 2);
        logoImage.x = Math.floor(stage.stageWidth * 0.5);
        logoImage.y = Math.floor(stage.stageHeight * 0.9);
        addChild(logoImage);
    }

    public function updateProgress(update:Number):void {
        progress = update;

        if(progressBar) {
            progressBar.alpha = 0 + progress * 0.2;
            progressBar.scaleX = progress * stage.stageWidth;
        }
    }

}
}
