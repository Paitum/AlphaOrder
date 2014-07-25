package {

import citrus.core.starling.StarlingState;

import feathers.controls.Button;

import flash.geom.Point;

import starling.core.Starling;
import starling.events.Event;

public class GameState extends StarlingState {
    private var startStopButton:Button;
    private var stopwatch:StopwatchSprite;
    private var board:Board;

    public function GameState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        // 1 0xC348CC 0xF45AFF Pink
        // 2 0x4631D6 0x4C35E8 Dark Blue
        // 3 0x358FBF 0x47BFFF Light Blue
        // 4 0x31D68A 0x35E895 Green
        // 5 0x61BF2C 0x82FF3A Bright Green


        stage.color = 0x195BB2;

        var columns:int = 3;
        var rows:int = 3;
        var padding:int = 10;
        var size:int = Math.min(
                (stage.stageWidth - 2 * padding) / columns,
                (stage.stageHeight - 2 * padding) / rows);
//        var alphabet:String = "ABCXYZ";
        var alphabet:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var model:BoardModel = BoardModel.createBoardModelForLetters(rows, columns, alphabet);
        var fontSize:Number = 200 / size;
        var offset:Point = new Point(15 / size, -15 / size);
        board = new StringBoard(model, "ArtBrushLarge", fontSize, offset, boardCallback);
        board.pivotX = columns / 2;
        board.pivotY = rows / 2;
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

        stopwatch = new StopwatchSprite(125);
        stopwatch.x = _ce.stage.stageWidth * 0.5;
        stopwatch.y = _ce.stage.stageHeight * 0.08;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);
        stopwatch.getStopwatch().start();

        startStopButton = new Button();
        startStopButton.label = "Restart";
        startStopButton.width = 150;
        startStopButton.height = 75;
        startStopButton.pivotX = startStopButton.width / 2;
        startStopButton.pivotY = startStopButton.height / 2;
        startStopButton.x =  _ce.stage.stageWidth * 0.5;
        startStopButton.y =  _ce.stage.stageHeight * 0.925;
        startStopButton.addEventListener(Event.TRIGGERED, handleStartStop);
        addChild(startStopButton);

        board.resetAndStart();
    }

    private function boardCallback(op:int):void {
        if(op == Board.START) {
            stopwatch.getStopwatch().reset();
            stopwatch.getStopwatch().start();
        } else if(op == Board.FINISH) {
            stopwatch.getStopwatch().stop();
        }
    }

    private function handleStartStop(event:Event):void {
        board.resetAndStart();
    }
}
}