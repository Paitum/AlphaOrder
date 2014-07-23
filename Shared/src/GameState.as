package {

import citrus.core.starling.StarlingState;

import starling.animation.IAnimatable;

import starling.core.Starling;

import starling.display.Quad;

public class GameState extends StarlingState {

    public function GameState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        stage.color = 0x222288;

//        var quad:Quad = new Quad(300,200, 0xEEEEEE);
//        quad.pivotX = quad.width / 2;
//        quad.pivotY = quad.height;
//        quad.x = _ce.baseWidth / 2;
//        quad.y = _ce.baseHeight;
//        addChild(quad);
//
//        textField = new TextField(quad.width, quad.height, "000", "ArtBrushLarge", 150, 0xFFFFFF);
//        textField.hAlign = "left";
//        textField.vAlign = "bottom";
//        textField.pivotX = quad.pivotX;
//        textField.pivotY = quad.pivotY;
//        textField.x = quad.x;
//        textField.y = quad.y;
//        addChild(textField);

        var divisions:int = 3;
        var padding:int = 10;
        var pixelsPerQuad:int = Math.min(
                (stage.stageWidth - 2 * padding) / divisions,
                (stage.stageHeight - 2 * padding) / divisions);
        var board:Board = new Board(divisions);
        board.x = padding;
        board.y = padding;
        board.scaleX = pixelsPerQuad;
        board.scaleY = pixelsPerQuad;
        addChild(board);

        var stopwatch:StopwatchSprite;

        stopwatch = new StopwatchSprite(24);
        stopwatch.x = _ce.stage.stageWidth * 0.75;
        stopwatch.y = _ce.stage.stageHeight * 0.65;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);

        stopwatch.getStopwatch().start();
        stopwatch= new StopwatchSprite(36);
        stopwatch.x = _ce.stage.stageWidth * 0.75;
        stopwatch.y = _ce.stage.stageHeight * 0.70;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);
        stopwatch.getStopwatch().start();

        stopwatch = new StopwatchSprite(72);
        stopwatch.x = _ce.stage.stageWidth * 0.75;
        stopwatch.y = _ce.stage.stageHeight * 0.75;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);
        stopwatch.getStopwatch().start();

        stopwatch = new StopwatchSprite(92);
        stopwatch.x = _ce.stage.stageWidth * 0.75;
        stopwatch.y = _ce.stage.stageHeight * 0.85;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);
        stopwatch.getStopwatch().start();
    }
}
}