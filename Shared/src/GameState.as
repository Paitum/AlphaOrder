package {

import citrus.core.starling.StarlingState;

import feathers.controls.Button;
import feathers.controls.TabBar;
import feathers.data.ListCollection;

import flash.geom.Point;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.textures.Texture;

public class GameState extends StarlingState {
    private var startStopButton:Button;
    private var stopwatch:StopwatchSprite;
    private var modeBar:TabBar;
    private var board:Board;

    public function GameState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        stage.color = 0x195BB2;

        var texture:Texture = Assets.assets.getTexture("Background");

        if(texture == null) {
            var backgroundQuad:Quad = new Quad(stage.stageWidth, stage.stageHeight, 0x195BB2);
            backgroundQuad.setVertexColor(0, 0x001240);
            backgroundQuad.setVertexColor(1, 0x00237F);
            backgroundQuad.setVertexColor(2, 0x00237F);
            backgroundQuad.setVertexColor(3, 0x0046FF);
            addChild(backgroundQuad);
        } else {
            var backgroundImage:Image = new Image(texture);
            backgroundImage.width = stage.stageWidth;
            backgroundImage.height = stage.stageHeight;
            backgroundImage.color = 0x0046FF;
            addChild(backgroundImage);
        }

        var columns:int = 3;
        var rows:int = 4;
        var padding:int = 10;

        var yDivider:int = stage.stageHeight / 10;
        var boardCenterX:int = stage.stageWidth / 2;
        var boardCenterY:int = (stage.stageHeight - yDivider) / 2;
        var boardWidth:int = stage.stageWidth - 2 * padding;
        var boardHeight:int = (stage.stageHeight - yDivider) - 2 * padding;
        var scale:int = Math.min(boardWidth / columns, boardHeight / rows);

        var quad1:Quad, quad2:Quad;

        quad1 = new Quad(stage.stageWidth - 2 * padding, 1, 0xFFFF00);
        quad1.x = padding;
        quad1.y = yDivider;
        quad1.alpha = 1;
        addChild(quad1);

//        var alphabet:String = "ABCXYZ";
        var alphabet:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var model:BoardModel = BoardModel.createBoardModelForLetters(rows, columns, alphabet);
        var fontSize:Number = 0.979729;
        var offset:Point = new Point(0.06, -0.10);
        board = new StringBoard(model, "ArtBrushLarge", fontSize, offset, boardCallback);
        board.pivotX = columns / 2;
        board.pivotY = rows / 2;
        board.x = boardCenterX;
        board.y = yDivider + boardCenterY;
        board.scaleX = scale;
        board.scaleY = scale;

//        board.x = 50;
//        board.y = 50;
//        board.scaleX = 10;
//        board.scaleY = 10;
//        board.pivotX = 0;
//        board.pivotY = 0;
        addChild(board);

        var controlsWidth:int = boardWidth;
        var controlsHeight:int = yDivider - 2 * padding;
        var controlsCenterX:int = boardCenterX;
        var controlsCenterY:int = padding + controlsHeight / 2;

        fontSize = stage.stageWidth / 5.12; // 125
        stopwatch = new StopwatchSprite(fontSize);
        stopwatch.pivotX = stopwatch.width/ 2;
        stopwatch.pivotY = stopwatch.height / 2;
        stopwatch.x = controlsCenterX;
        stopwatch.y = controlsCenterY;
        stopwatch.scaleX = 0.5;
        stopwatch.scaleY = 0.5;
        addChild(stopwatch);
        Starling.juggler.add(stopwatch);
        stopwatch.getStopwatch().start();

        startStopButton = new Button();
        startStopButton.nameList.add("restart");
        startStopButton.width = 92;
        startStopButton.height = 92;
        startStopButton.pivotX = startStopButton.width / 2;
        startStopButton.pivotY = startStopButton.height / 2;
        startStopButton.scaleX = 0.75;
        startStopButton.scaleY  = 0.75;
        startStopButton.x = stage.stageWidth - padding - startStopButton.width / 2;
        startStopButton.y = controlsCenterY;
        startStopButton.addEventListener(Event.TRIGGERED, handleStartStop);
        addChild(startStopButton);

        modeBar = new TabBar();
        modeBar.dataProvider = new ListCollection(
        [
            { label: "A" },
            { label: "a" },
            { label: "Aa" },
        ]);
        modeBar.height = 92;
        modeBar.pivotX = modeBar.width / 2;
        modeBar.pivotY = modeBar.height / 2;
        modeBar.scaleX = 0.75;
        modeBar.scaleY  = 0.75;
        modeBar.x = padding + modeBar.width / 2;
        modeBar.y = controlsCenterY;
        this.addChild( modeBar );
        modeBar.addEventListener( Event.CHANGE, handleModeChange);

        board.resetAndStart();
    }

    private function handleModeChange(event:Event):void {
        var tabs:TabBar = TabBar( event.currentTarget );
        trace( "selectedIndex:", tabs.selectedIndex );
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