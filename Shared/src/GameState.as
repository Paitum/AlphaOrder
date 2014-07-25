package {

import citrus.core.starling.StarlingState;

import feathers.controls.Button;

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

        stage.color = 0x222288;

        var columns:int = 3;
        var rows:int = 3;
        var padding:int = 10;
        var size:int = Math.min(
                (stage.stageWidth - 2 * padding) / columns,
                (stage.stageHeight - 2 * padding) / rows);
        board = new Board(columns, rows, "ABCXYZ", boardCallback);
//        board = new Board(divisions, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", boardCallback);
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

        stopwatch = new StopwatchSprite(72);
        stopwatch.x = _ce.stage.stageWidth * 0.5;
        stopwatch.y = _ce.stage.stageHeight * 0.075;
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

    }

    private function boardCallback(op:int):void {
trace("CALLBACK[" + op+ "]");
        if(op == Board.START) {
            stopwatch.getStopwatch().reset();
            stopwatch.getStopwatch().start();
        } else if(op == Board.FINISH) {
            stopwatch.getStopwatch().stop();
        }
    }

    private function handleStartStop(event:Event):void {
        board.reset();
    }
}
}