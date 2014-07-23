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
        var size:int = Math.min(
                (stage.stageWidth - 2 * padding) / divisions,
                (stage.stageHeight - 2 * padding) / divisions);
        var board:Board = new Board(divisions, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        board.pivotX = divisions / 2;
        board.pivotY = divisions / 2;
        board.x = stage.stageWidth / 2;
        board.y = stage.stageHeight / 2;
        board.scaleX = size;
        board.scaleY = size;

//        board.x = 50;
//        board.y = 50;
//        board.scaleX = 10;
//        board.scaleY = 10;
//        board.pivotX = 0;
//        board.pivotY = 0;
        addChild(board);

        var stopwatch:StopwatchSprite;

        stopwatch = new StopwatchSprite(72);
        stopwatch.x = _ce.stage.stageWidth * 0.5;
        stopwatch.y = _ce.stage.stageHeight * 0.075;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);
        stopwatch.getStopwatch().start();
    }
}
}