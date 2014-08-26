package {

import citrus.core.starling.StarlingState;

import flash.utils.getTimer;

import starling.animation.Tween;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.extensions.particles.PDParticleSystem;
import starling.extensions.particles.ParticleSystem;
import starling.text.TextField;
import starling.text.TextFieldAutoSize;
import starling.textures.Texture;
import starling.utils.HAlign;

public class GameState extends StarlingState {
    private var stopwatch:Stopwatch;
    private var stopwatchText:TextField;
    private var endStopwatchTween:Tween;
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
    private var modeTextField:TextField;
    private var particleSystem:ParticleSystem;
    private var fadeWallResetTime:int;

    public function GameState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        var stageWidth:int = stage.stageWidth;
        var stageHeight:int = stage.stageHeight;
        var deviceInfo:Object = Constants.getDeviceInfo();

        stage.color = Constants.BACKGROUND_COLOR;

        var texture:Texture;
        texture = Assets.assets.getTexture("Background");

        if(texture == null) {
//            var backgroundQuad:Quad = new Quad(stageWidth, stageHeight, Constants.BACKGROUND_COLOR);
//            backgroundQuad.setVertexColor(0, 0x0F366A);
//            backgroundQuad.setVertexColor(1, 0x0F366A);
//            backgroundQuad.setVertexColor(2, 0x113f7c);
//            backgroundQuad.setVertexColor(3, 0x113f7c);
//            addChild(backgroundQuad);
        } else {
            var backgroundImage:Image = new Image(texture);
            backgroundImage.width = stageWidth;
            backgroundImage.height = stageHeight;
            backgroundImage.color = Constants.BACKGROUND_COLOR;
            addChild(backgroundImage);
        }

        padding = 10;

        yDivider = stageHeight / 10;
        breadcrumbDivider = yDivider + stageHeight / 10;
        var boardCenterX:int = stageWidth / 2;
        var boardCenterY:int = (stageHeight - breadcrumbDivider) / 2;
        var boardWidth:int = stageWidth - 2 * padding;
        var boardHeight:int = (stageHeight - breadcrumbDivider) - 2 * padding;
        var breadcrumbHeight:int = breadcrumbDivider - yDivider - 2 * padding;
        var breadcrumbCenterY:int = yDivider + breadcrumbHeight / 2 + padding;

        var smallEdge:int = Math.min(boardWidth, boardHeight);
        var tileSize:int = smallEdge / 3;
        var columns:int = boardWidth / tileSize;
        var rows:int = boardHeight / tileSize;
        columns = columns < 3 ? 3 : columns > 4 ? 4 : columns;
        rows = rows < 3 ? 3 : rows > 4 ? 4 : rows;

        var tempQuad:Quad;
        tempQuad = new Quad(stageWidth, yDivider, 0x000000);
        tempQuad.alpha = 0.4;
        tempQuad.x = 0;
        tempQuad.y = 0;
        tempQuad.touchable = false;
        addChild(tempQuad);

        tempQuad = new Quad(stageWidth, breadcrumbDivider - yDivider, 0x000000);
        tempQuad.alpha = 0.2;
        tempQuad.x = 0;
        tempQuad.y = yDivider;
        tempQuad.touchable = false;
        addChild(tempQuad);

        var dividerQuad:Quad;
        dividerQuad = new Quad(stageWidth, 1,  Constants.DETAIL_COLOR);
        dividerQuad.alpha = 0.2;
        dividerQuad.x = 0;
        dividerQuad.y = yDivider;
        dividerQuad.touchable = false;
        addChild(dividerQuad);

        dividerQuad = new Quad(stageWidth, 1, Constants.DETAIL_COLOR);
        dividerQuad.alpha = 0.2;
        dividerQuad.x = 0;
        dividerQuad.y = breadcrumbDivider;
        dividerQuad.touchable = false;
        addChild(dividerQuad);

//        var alphabet:String = "ABCXYZ";
//        models[0] = RandomCaseModel.createBoardModelForLetters(rows, columns, "a");
//        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "A");
        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        modelLabels[0] = "ABC";
        models[1] = BoardModel.createBoardModelForLetters(rows, columns, "abcdefghijklmnopqrstuvwxyz");
        modelLabels[1] = "abc";
        models[2] = RandomCaseModel.createBoardModelForLetters(rows, columns, "abcdefghijklmnopqrstuvwxyz");
        modelLabels[2] = "aBc";
        currentModel = 0;
        currentModelLabel = modelLabels[currentModel];

        var scale:int = Math.min(boardWidth / columns, boardHeight / rows);
        board = new StringBoard(models[0], Constants.DEFAULT_FONT, boardCallback);
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

        var leftButton:DisplayObject = createButton(HAlign.LEFT);
        leftButton.addEventListener(TouchEvent.TOUCH, handleLeftButtonTrigger);
        addChild(leftButton);

//        var centerButton:DisplayObject = createButton(HAlign.CENTER);
//        centerButton.addEventListener(Event.TRIGGERED, handleCenterButtonTrigger);
//        addChild(centerButton);

        var rightButton:DisplayObject = createButton(HAlign.RIGHT);
        rightButton.addEventListener(TouchEvent.TOUCH, handleRightButtonTrigger);
        addChild(rightButton);

        stopwatch = new Stopwatch();
        Starling.juggler.add(stopwatch);

        stopwatchText = createTextField(boardWidth, boardHeight, "XXXX.XX");
        stopwatchText.color = Constants.TEXT_COLOR;
        stopwatchText.x = stageWidth / 2;
        stopwatchText.y = stageHeight / 2;
        stopwatchText.scaleX = 1;
        stopwatchText.scaleY = 1;
        stopwatchText.touchable = false;
        addChild(stopwatchText);

        endStopwatchTween = new Tween(stopwatchText, 1, "easeIn");

        var textField:TextField;
        textField = createTextField((controlsWidth / 3) * 1.2, controlsHeight * 1.2, "AlphaOrder", "ArtBrushLarge");
        textField.color = Constants.TEXT_COLOR;
        textField.pivotX = textField.width / 2;
        textField.pivotY = textField.height / 2;
        textField.x = controlsCenterX;
        textField.y = controlsCenterY;
        addChild(textField);

        modeTextField = createTextField(controlsWidth / 3, controlsHeight * 0.4, "ABC");
        modeTextField.color = Constants.TEXT_COLOR;
        modeTextField.pivotX = 0;
        modeTextField.pivotY = modeTextField.height / 2;
        modeTextField.x = padding;
        modeTextField.y = controlsCenterY;
        addChild(modeTextField);

        var restartIcon:Image;
        restartIcon = new Image(Assets.assets.getTexture("restart"));
        restartIcon.color = Constants.TEXT_COLOR;
        restartIcon.pivotX = restartIcon.width;
        restartIcon.pivotY = restartIcon.height / 2;
        restartIcon.height = controlsHeight / 2;
        //noinspection JSSuspiciousNameCombination
        restartIcon.width = restartIcon.height;
        restartIcon.x = padding + controlsWidth;
        restartIcon.y = controlsCenterY;
        restartIcon.touchable = false;
        addChild(restartIcon);

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

        var now:int = getTimer();

        if(touch != null && touch.phase == TouchPhase.BEGAN && now > fadeWallResetTime) {
            board.resetAndStart();
            _ce.sound.playSound("beep");
        }
    }

    private function createButton(hAlign:String):Quad {
        var button:Quad = new Quad(stage.stageWidth / 3, yDivider, 0x000000);
        button.alpha = 0.0;
        button.pivotX = 0;
        button.pivotY = 0;
        button.x = (hAlign == HAlign.LEFT ? 0 : hAlign == HAlign.CENTER ? 1 : 2) * button.width;
        button.y = 0;

        return button;
    }

    private function handleLeftButtonTrigger(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null || touch.phase != TouchPhase.BEGAN) {
            return;
        }

        currentModel = (currentModel + 1) % models.length;
        currentModelLabel = modelLabels[currentModel];
        board.changeModel(models[currentModel]);
        modeTextField.text = modelLabels[currentModel];

        _ce.sound.playSound("beep");
    }

    private function handleCenterButtonTrigger(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null || touch.phase != TouchPhase.BEGAN) {
            return;
        }

        // Do something
    }

    private function handleRightButtonTrigger(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null || touch.phase != TouchPhase.BEGAN) {
            return;
        }

        board.resetAndStart();
        _ce.sound.playSound("beep");
    }

    private function boardCallback(op:int, token:String = null):void {
        var nextToken:String = board.getModel().getCurrentSolutionToken();

        if(op == Board.CORRECT) {
            breadcrumbs.addToken(token, nextToken);
            playCorrectSound(token);
        } else if(op == Board.INCORRECT) {
            _ce.sound.playSound("wrong");
        } else if(op == Board.START) {
            breadcrumbs.reset();
            if(nextToken != null) breadcrumbs.setNextToken(nextToken);
            hideEndTime();
            stopwatch.reset();
            stopwatch.start();
            fadeWall.alpha = 0;
            fullScreenTouch.touchable = false;
            particleSystem.alpha = 0;
            particleSystem.stop();
            Starling.juggler.remove(particleSystem);
        } else if(op == Board.FINISH) {

            _ce.sound.playSound("celebrate");
            stopwatch.stop();
            showEndTime();
            fadeWall.alpha = 0.9;
            particleSystem.alpha = 1;
            particleSystem.start();
            Starling.juggler.add(particleSystem);
        }
    }

    private function playCorrectSound(token:String):void {
        _ce.sound.playSound(token.toLowerCase());
    }

    private function hideEndTime():void {
        Starling.juggler.remove(endStopwatchTween);
        stopwatchText.alpha = 0.0;

        fullScreenTouch.touchable = false;
    }

    private function showEndTime():void {
        var time:Number = stopwatch.getAccumulatedTime();
        var seconds:uint      = Math.floor(time);
        var milliseconds:uint = int((time - seconds) * 100);
        var secondsStr:String = seconds.toString();
        var msStr:String = milliseconds.toString();
        msStr = msStr.length == 1 ? "0" + msStr : msStr;
        stopwatchText.text = secondsStr + "." + msStr;
        stopwatchText.pivotX = stopwatchText.width / 2;
        stopwatchText.pivotY = stopwatchText.height / 2;
        stopwatchText.alpha = 0.2;
        stopwatchText.scaleX = 0.2;
        stopwatchText.scaleY = 0.2;

        var delay:Number = 0.5;
        endStopwatchTween.reset(stopwatchText, 0.5, "easeIn");
        endStopwatchTween.animate("alpha", 1.0);
        endStopwatchTween.animate("scaleX", 1.0);
        endStopwatchTween.animate("scaleY", 1.0);
        endStopwatchTween.animate("rotation", Math.PI * 2);
        Starling.juggler.add(endStopwatchTween);

        fadeWallResetTime = getTimer() + delay * 1000;
        fullScreenTouch.touchable = true;
    }

    public function createTextField(width:Number, height:Number, msg:String, font:String = Constants.DEFAULT_FONT):TextField {
        var fontSize:Number = Math.min(width, height);
        var textField:TextField = new TextField(width, height, msg, font, fontSize, 0xFFFFFF);
        textField.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
        textField.touchable = false;

        var scaleX:Number = width / textField.width;
        var scaleY:Number = height / textField.height;
        textField.fontSize = fontSize * Math.min(scaleX, scaleY);

        return textField;
    }
}
}