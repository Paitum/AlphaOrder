package {

import citrus.core.starling.StarlingState;

import feathers.controls.Button;
import feathers.controls.TabBar;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.extensions.particles.PDParticleSystem;
import starling.extensions.particles.ParticleSystem;
import starling.textures.Texture;
import starling.utils.HAlign;

public class GameState extends StarlingState {
    private var leftButton:Button;
    private var centerButton:Button;
    private var rightButton:Button;
    private var stopwatch:StopwatchSprite;
    private var modeBar:TabBar;
    private var models:Vector.<BoardModel> = new Vector.<BoardModel>(2);
    private var modelLabels:Vector.<String> = new Vector.<String>();
    private var currentModelLabel:String;
    private var currentModel:int = -1;
    private var board:Board;
    private var breadcrumbs:StringBreadcrumbs;
    private var blackhole:Image;
    private var yDivider:int;
    private var breadcrumbDivider:int;
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
        breadcrumbDivider = yDivider + stage.stageHeight / 10;
        var boardCenterX:int = stage.stageWidth / 2;
        var boardCenterY:int = (stage.stageHeight - breadcrumbDivider) / 2;
        var boardWidth:int = stage.stageWidth - 2 * padding;
        var boardHeight:int = (stage.stageHeight - breadcrumbDivider) - 2 * padding;
        var breadcrumbHeight:int = breadcrumbDivider - yDivider - 2 * padding;
        var breadcrumbCenterY:int = yDivider + breadcrumbHeight / 2 + padding;
        var scale:int = Math.min(boardWidth / columns, boardHeight / rows);

        var dividerQuad:Quad;

        dividerQuad = new Quad(stage.stageWidth - 2 * padding, 1, 0xFFFF00);
        dividerQuad.x = padding;
        dividerQuad.y = yDivider;
        dividerQuad.alpha = 1;
        addChild(dividerQuad);

        dividerQuad = new Quad(stage.stageWidth - 2 * padding, 1, 0xFFFF00);
        dividerQuad.x = padding;
        dividerQuad.y = breadcrumbDivider;
        dividerQuad.alpha = 1;
        addChild(dividerQuad);

//        var alphabet:String = "ABCXYZ";
//        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "A");
        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        modelLabels[0] = "ABC";
        models[1] = BoardModel.createBoardModelForLetters(rows, columns, "abcdefghijklmnopqrstuvwxyz");
        modelLabels[1] = "abc";
        models[2] = BoardModel.createBoardModelForLetters(rows, columns, "012");
        modelLabels[2] = "123";
        currentModel = 0;
        currentModelLabel = modelLabels[currentModel];

        board = new StringBoard(models[0], "ArtBrushLarge", boardCallback);
        board.pivotX = board.width / 2;
        board.pivotY = board.height / 2;
        board.x = boardCenterX;
        board.y = breadcrumbDivider + boardCenterY;
        board.scaleX = scale;
        board.scaleY = scale;

//        board.x = 50;
//        board.y = 50;
//        board.scaleX = 10;
//        board.scaleY = 10;
//        board.pivotX = 0;
//        board.pivotY = 0;
        addChild(board);

        var divisions:int = boardWidth / breadcrumbHeight;
        breadcrumbs = new StringBreadcrumbs(divisions);
        breadcrumbs.pivotX = breadcrumbs.width / 2;
        breadcrumbs.pivotY = breadcrumbs.height / 2;
        breadcrumbs.x = boardCenterX;
        breadcrumbs.y = breadcrumbCenterY;
        breadcrumbs.scaleX = breadcrumbHeight;
        breadcrumbs.scaleY = breadcrumbHeight;
        addChild(breadcrumbs);


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

        var fontSize:int = yDivider * 1.2;
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

        leftButton = createButton(HAlign.LEFT);
        leftButton.addEventListener(Event.TRIGGERED, handleLeftButtonTrigger);
        addChild(leftButton);

        centerButton = createButton(HAlign.CENTER);
        centerButton.addEventListener(Event.TRIGGERED, handleCenterButtonTrigger);
        addChild(centerButton);

        rightButton = createButton(HAlign.RIGHT);
        rightButton.addEventListener(Event.TRIGGERED, handleRightButtonTrigger);
        addChild(rightButton);

        var tempQuad:Quad;
        tempQuad = new Quad(1, controlsHeight, 0x444488);
        tempQuad.alpha = 1;
        tempQuad.x = centerButton.x;
        tempQuad.y = padding;
        tempQuad.touchable = false;
        addChild(tempQuad);

        tempQuad = new Quad(1, controlsHeight, 0x444488);
        tempQuad.alpha = 1;
        tempQuad.x = rightButton.x;
        tempQuad.y = padding;
        tempQuad.touchable = false;
        addChild(tempQuad);

        board.resetAndStart();
        Starling.juggler.add(board);
    }

    private function createButton(hAlign:String):Button {
        var button:Button = new Button();
        button.nameList.add("none");
        button.width = stage.stageWidth / 3;
        button.height = yDivider;
        button.pivotX = 0;
        button.pivotY = 0;
        button.x = (hAlign == HAlign.LEFT ? 0 : hAlign == HAlign.CENTER ? 1 : 2) * button.width;
        button.y = 0;

        return button;
    }

    private function handleLeftButtonTrigger(event:Event):void {
        currentModel = (currentModel + 1) % models.length;
        currentModelLabel = modelLabels[currentModel];
        board.changeModel(models[currentModel]);
    }

    private function handleCenterButtonTrigger(event:Event):void {
        stopwatch.alpha = stopwatch.alpha > 0.5 ? 0.075 : 1.0;
    }

    private function handleRightButtonTrigger(event:Event):void {
        board.resetAndStart();
    }

    private function boardCallback(op:int, token:String = null):void {
        if(op == Board.FOUND) {
            breadcrumbs.addToken(token);
        } else if(op == Board.START) {
            breadcrumbs.reset();
            stopwatch.getStopwatch().reset();
            stopwatch.getStopwatch().start();
            blackhole.alpha = 0;
            particleSystem.alpha = 0;
            particleSystem.stop();
            Starling.juggler.remove(particleSystem);
        } else if(op == Board.FINISH) {
            stopwatch.getStopwatch().stop();
            blackhole.alpha = 0.9;
            particleSystem.alpha = 1;
            particleSystem.start();
            Starling.juggler.add(particleSystem);
        }
    }
}
}