package {

import citrus.core.starling.StarlingState;

import feathers.controls.Button;
import feathers.controls.TabBar;

import starling.animation.Tween;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.extensions.particles.PDParticleSystem;
import starling.extensions.particles.ParticleSystem;
import starling.textures.Texture;
import starling.utils.HAlign;

public class GameState extends StarlingState {
    private var leftButton:Button;
    private var centerButton:Button;
    private var rightButton:Button;
    private var endStopwatch:StopwatchSprite;
    private var endStopwatchTween:Tween;
    private var modeBar:TabBar;
    private var models:Vector.<BoardModel> = new Vector.<BoardModel>(2);
    private var modelLabels:Vector.<String> = new Vector.<String>();
    private var currentModelLabel:String;
    private var currentModel:int = -1;
    private var board:Board;
    private var breadcrumbs:StringBreadcrumbs;
    private var fadeWall:Quad;
    private var fullScreenTouch:Quad;
    private var yDivider:int;
    private var breadcrumbDivider:int;
    private var padding:int;
    private var particleSystem:ParticleSystem;

    public function GameState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        var stageWidth:int = stage.stageWidth;
        var stageHeight:int = stage.stageHeight;

        stage.color = 0x195BB2;

        var texture:Texture = Assets.assets.getTexture("Background");

        if(texture == null) {
            var backgroundQuad:Quad = new Quad(stageWidth, stageHeight, 0x195BB2);
            backgroundQuad.setVertexColor(0, 0x001240);
            backgroundQuad.setVertexColor(1, 0x00237F);
            backgroundQuad.setVertexColor(2, 0x00237F);
            backgroundQuad.setVertexColor(3, 0x0046FF);
            addChild(backgroundQuad);
        } else {
            var backgroundImage:Image = new Image(texture);
            backgroundImage.width = stageWidth;
            backgroundImage.height = stageHeight;
            backgroundImage.color = 0x0046FF;
            addChild(backgroundImage);
        }

        var columns:int = 3;
        var rows:int = 4;
        padding = 10;

        yDivider = stageHeight / 10;
        breadcrumbDivider = yDivider + stageHeight / 10;
        var boardCenterX:int = stageWidth / 2;
        var boardCenterY:int = (stageHeight - breadcrumbDivider) / 2;
        var boardWidth:int = stageWidth - 2 * padding;
        var boardHeight:int = (stageHeight - breadcrumbDivider) - 2 * padding;
        var breadcrumbHeight:int = breadcrumbDivider - yDivider - 2 * padding;
        var breadcrumbCenterY:int = yDivider + breadcrumbHeight / 2 + padding;
        var scale:int = Math.min(boardWidth / columns, boardHeight / rows);

        var dividerQuad:Quad;

        dividerQuad = new Quad(stageWidth - 2 * padding, 1, 0xFFFF00);
        dividerQuad.x = padding;
        dividerQuad.y = yDivider;
        dividerQuad.alpha = 1;
        addChild(dividerQuad);

        dividerQuad = new Quad(stageWidth - 2 * padding, 1, 0xFFFF00);
        dividerQuad.x = padding;
        dividerQuad.y = breadcrumbDivider;
        dividerQuad.alpha = 1;
        addChild(dividerQuad);

//        var alphabet:String = "ABCXYZ";
        models[0] = RandomCaseModel.createBoardModelForLetters(rows, columns, "a");
//        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        modelLabels[0] = "ABC";
        models[1] = BoardModel.createBoardModelForLetters(rows, columns, "abcdefghijklmnopqrstuvwxyz");
        modelLabels[1] = "abc";
        models[2] = RandomCaseModel.createBoardModelForLetters(rows, columns, "abcdefghijklmnopqrstuvwxyz");
        modelLabels[2] = "aBc";
        currentModel = 0;
        currentModelLabel = modelLabels[currentModel];

        board = new StringBoard(models[0], "ArtBrushLarge", boardCallback);
        board.pivotX = board.width / 2;
        board.pivotY = board.height / 2;
        board.x = boardCenterX;
        board.y = breadcrumbDivider + boardCenterY;
        board.scaleX = scale;
        board.scaleY = scale;
        addChild(board);

        var divisions:int = boardWidth / breadcrumbHeight;
        breadcrumbs = new StringBreadcrumbs(divisions);
        breadcrumbs.pivotX = breadcrumbs.width / 2;
        breadcrumbs.pivotY = breadcrumbs.height / 2;
        breadcrumbs.x = boardCenterX;
        breadcrumbs.y = breadcrumbCenterY;
        //noinspection JSSuspiciousNameCombination
        breadcrumbs.scaleX = breadcrumbHeight;
        breadcrumbs.scaleY = breadcrumbHeight;
        addChild(breadcrumbs);

        fadeWall = new Quad(stageWidth, stageHeight, 0x888888);
        fadeWall.x = 0;
        fadeWall.y = 0;
        fadeWall.blendMode = BlendMode.MULTIPLY;
        fadeWall.alpha = 0;
        fadeWall.touchable = false;
        addChild(fadeWall);

        var xml:XML = XML(Assets.assets.getXml("particleConfig"));
        texture = Assets.assets.getTexture("particleTexture");
        particleSystem = new PDParticleSystem(xml, texture);
        particleSystem.emitterX = board.x;
        particleSystem.emitterY = stageHeight;
        particleSystem.alpha = 0;
        addChild(particleSystem);

        var controlsWidth:int = boardWidth;
        var controlsHeight:int = yDivider - 2 * padding;
        var controlsCenterX:int = boardCenterX;
        var controlsCenterY:int = padding + controlsHeight / 2;

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

        scale = Math.min(stageWidth, stageHeight) / 4;
        endStopwatch = new StopwatchSprite(scale);
        endStopwatch.x = stageWidth / 2;
        endStopwatch.y = stageHeight / 2;
        endStopwatch.scaleX = 1;
        endStopwatch.scaleY = 1;
        endStopwatch.touchable = false;
        endStopwatch.showMilliseconds(true);
        addChild(endStopwatch);
        Starling.juggler.add(endStopwatch);

        endStopwatchTween = new Tween(endStopwatch, 1, "easeIn");

        fullScreenTouch = new Quad(stageWidth, stageHeight, 0xFFFFFF);
        fullScreenTouch.x = 0;
        fullScreenTouch.y = 0;
        fullScreenTouch.alpha = 0.0;
        addChild(fullScreenTouch);
        fullScreenTouch.addEventListener(TouchEvent.TOUCH, handleFadeWallTouch);

        board.resetAndStart();
        Starling.juggler.add(board);
    }

    private function handleFadeWallTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch != null && touch.phase == TouchPhase.BEGAN) {
            trace(event);
            board.resetAndStart();
        }
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

    }

    private function handleRightButtonTrigger(event:Event):void {
        board.resetAndStart();
    }

    private function boardCallback(op:int, token:String = null):void {
        if(op == Board.FOUND) {
            breadcrumbs.addToken(token);
        } else if(op == Board.START) {
            breadcrumbs.reset();
            hideEndTime();
            endStopwatch.getStopwatch().reset();
            endStopwatch.getStopwatch().start();
            fadeWall.alpha = 0;
            fullScreenTouch.touchable = false;
            particleSystem.alpha = 0;
            particleSystem.stop();
            Starling.juggler.remove(particleSystem);
        } else if(op == Board.FINISH) {
            endStopwatch.getStopwatch().stop();
            showEndTime();
            fadeWall.alpha = 0.9;
            particleSystem.alpha = 1;
            particleSystem.start();
            Starling.juggler.add(particleSystem);
        }
    }

    private function hideEndTime():void {
        Starling.juggler.remove(endStopwatchTween);
        endStopwatch.alpha = 0.0;
    }

    private function showEndTime():void {
        endStopwatch.alpha = 0.2;
        endStopwatch.scaleX = 0.2;
        endStopwatch.scaleY = 0.2;

        endStopwatchTween.reset(endStopwatch, 0.5, "easeIn");
        endStopwatchTween.animate("alpha", 1.0);
        endStopwatchTween.animate("scaleX", 1.0);
        endStopwatchTween.animate("scaleY", 1.0);
        endStopwatchTween.animate("rotation", Math.PI * 2);
        Starling.juggler.add(endStopwatchTween);

        Starling.juggler.delayCall(function():void {
            fullScreenTouch.touchable = true;
            trace("touch");
        }, 1);
    }
}
}