package {

import citrus.core.starling.StarlingState;

import feathers.controls.Button;
import feathers.controls.TabBar;
import feathers.data.ListCollection;

import flash.geom.Point;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.extensions.particles.PDParticleSystem;
import starling.extensions.particles.ParticleSystem;
import starling.textures.Texture;

public class GameState extends StarlingState {
    private var startStopButton:Button;
    private var stopwatch:StopwatchSprite;
    private var modeBar:TabBar;
    private var models:Vector.<BoardModel> = new Vector.<BoardModel>(2);
    private var board:Board;
    private var blackhole:Image;
    private var currentModel:int = -1;
    private var yDivider:int;
    private var padding:int;
    private var particleSystem:ParticleSystem;

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
        padding = 10;

        yDivider = stage.stageHeight / 10;
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
        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "A");
//        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        models[1] = BoardModel.createBoardModelForLetters(rows, columns, "abcdefghijklmnopqrstuvwxyz");
        models[2] = BoardModel.createBoardModelForLetters(rows, columns, "0123456789");
        var fontSize:Number = 0.979729;
        var offset:Point = new Point(0.06, -0.10);
        board = new StringBoard(models[0], "ArtBrushLarge", fontSize, offset, boardCallback);
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

        texture = Assets.assets.getTexture("blackhole");
        blackhole = new Image(texture);
        blackhole.pivotX = blackhole.width / 2;
        blackhole.pivotY = blackhole.height / 2;
        blackhole.x = board.x;
        blackhole.y = board.y;
        blackhole.scaleX = 8;
        blackhole.scaleY = 4;
        blackhole.blendMode = BlendMode.MULTIPLY;
        blackhole.alpha = 0;
        blackhole.touchable = false;
        addChild(blackhole);

        var xml:XML = XML(Assets.assets.getXml("particleConfig"));
        texture = Assets.assets.getTexture("particleTexture");
        particleSystem = new PDParticleSystem(xml, texture);
        particleSystem.emitterX = board.x;
        particleSystem.emitterY = board.y;
        particleSystem.alpha = 0;
        addChild(particleSystem);

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
        addChild(startStopButton);

        modeBar = new TabBar();
        modeBar.dataProvider = new ListCollection(
        [
            { label: "ABC" },
            { label: "abc" },
            { label: "123" },
//            { label: "Aa" },
        ]);
        modeBar.height = 92;
        modeBar.pivotX = modeBar.width / 2;
        modeBar.pivotY = modeBar.height / 2;
        modeBar.scaleX = 0.75;
        modeBar.scaleY  = 0.75;
        modeBar.x = padding + modeBar.width / 2;
        modeBar.y = controlsCenterY;
        this.addChild( modeBar );

        startStopButton.addEventListener(Event.TRIGGERED, handleRestart);
        modeBar.addEventListener( Event.CHANGE, handleModeChange);

        board.resetAndStart();
        Starling.juggler.add(board);
    }

    private function stopWatchPosition(makeBig:Boolean):void {
        var boardCenterX:int = stage.stageWidth / 2;
        var boardCenterY:int = (stage.stageHeight - yDivider) / 2;
        var controlsHeight:int = yDivider - 2 * padding;
        var controlsCenterX:int = boardCenterX;
        var controlsCenterY:int = padding + controlsHeight / 2;

        if(makeBig) {
            stopwatch.x = boardCenterX;
            stopwatch.y = yDivider + boardCenterY;
            stopwatch.scaleX = 2;
            stopwatch.scaleY = 2;
            stopwatch.showMilliseconds(true);
        } else {
            stopwatch.x = controlsCenterX;
            stopwatch.y = controlsCenterY;
            stopwatch.scaleX = 0.5;
            stopwatch.scaleY = 0.5;
            stopwatch.showMilliseconds(false);
        }
    }

    private function handleModeChange(event:Event):void {
        currentModel = modeBar.selectedIndex;
        board.changeModel(models[currentModel]);
    }

    private function boardCallback(op:int):void {
        if(op == Board.START) {
            stopwatch.getStopwatch().reset();
            stopwatch.getStopwatch().start();
            blackhole.alpha = 0;
            particleSystem.alpha = 0;
            particleSystem.stop();
            Starling.juggler.remove(particleSystem);
            stopWatchPosition(false);
        } else if(op == Board.FINISH) {
            stopwatch.getStopwatch().stop();
            blackhole.alpha = 0.9;
            particleSystem.alpha = 1;
            particleSystem.start();
            Starling.juggler.add(particleSystem);
            stopWatchPosition(true);
        }
    }

    private function handleRestart(event:Event):void {
        board.resetAndStart();
    }
}
}