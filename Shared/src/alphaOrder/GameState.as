package alphaOrder {

import citrus.core.starling.StarlingState;

import flash.utils.getTimer;

import starling.animation.Tween;

import starling.core.Starling;
import starling.display.BlendMode;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
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
    private var rows:int;
    private var columns:int;
    private var stopwatch:Stopwatch;
    private var stopwatchText:TextField;
    private var endStopwatchTween:Tween;
    private var secondsText:TextField;
    private var models:Vector.<AlphaOrderBoardModel> = new Vector.<AlphaOrderBoardModel>(2);
    private var displayTokens:DisplayTokens;
    private var modelLabels:Vector.<String> = new Vector.<String>();
    private var currentModelLabel:String;
    private var currentModel:int = -1;
    private var board:AlphaOrderBoard;
    private var breadcrumbs:StringBreadcrumbs;
    private var fadeWall:Quad;
    private var fullScreenTouch:Quad;
    private var xDivider:int;
    private var yDivider:int = 5;
    private var padding:int;
    private var modeTextField:TextField;
    private var particleSystem:ParticleSystem;
    private var fadeWallResetTime:int;

    private var backgroundImage:Image;

    // initialized Event triggered at the end of the initalize() method
    [Event(name="initialized", type="starling.events.Event")]
    public static const INITIALIZED_EVENT:String = "initialized";

    public function GameState() {
        super();
    }

    override public function initialize():void {
        super.initialize();

        stage.color = Constants.BACKGROUND_COLOR;

        if(backgroundImage == null) {
            var texture:Texture;
            texture = Assets.assets.getTexture("Background");

            if(texture != null) {
                backgroundImage = new Image(texture);
                addChild(backgroundImage);
            }
        }

        setupState();
    }

    public function setupState():void {
        if(stage == null) return;

        var stageWidth:int = stage.stageWidth;
        var stageHeight:int = stage.stageHeight;
        var isLandscape:Boolean = stageWidth > stageHeight;

        trace("GameState setupState(" + stageWidth + ", " + stageHeight + ")");

        padding = 10;
        xDivider = stageWidth / 50;
        var breadcrumbWidth:int = isLandscape ? stageWidth / 10 : stageWidth - 2 * padding;
        var breadcrumbHeight:int = isLandscape ? stageHeight - 2 * padding : stageHeight / 10;
        var breadcrumbCenterX:int = xDivider + padding + breadcrumbWidth / 2;
        var breadcrumbCenterY:int = padding + breadcrumbHeight / 2;

        var boardWidth:int = isLandscape ?
                stageWidth - (xDivider + breadcrumbWidth + 2 * padding) :
                breadcrumbWidth;
        var boardHeight:int = isLandscape ?
                breadcrumbHeight :
                stageHeight - (breadcrumbHeight + 2 * padding);
        var boardCenterX:int = xDivider + padding + boardWidth / 2 + (isLandscape ? breadcrumbWidth : 0);
        var boardCenterY:int = padding + boardHeight / 2 + (isLandscape ? 0 : breadcrumbHeight);

        var smallEdge:int = Math.min(boardWidth, boardHeight);
        var tileSize:int = smallEdge / 3;

        columns = boardWidth / tileSize;
        rows = boardHeight / tileSize;
        columns = columns < 3 ? 3 : columns > 4 ? 4 : columns;
        rows = rows < 3 ? 3 : rows > 4 ? 4 : rows;

        if(backgroundImage != null) {
            backgroundImage.width = stageWidth;
            backgroundImage.height = stageHeight;
            backgroundImage.color = Constants.BACKGROUND_COLOR;
        }

//        var tempQuad:Quad;
//        tempQuad = new Quad(stageWidth, yDivider, 0x000000);
//        tempQuad.alpha = 0.4;
//        tempQuad.x = 0;
//        tempQuad.y = 0;
//        tempQuad.touchable = false;
//        addChild(tempQuad);
//
//        tempQuad = new Quad(stageWidth, breadcrumbDivider - yDivider, 0x000000);
//        tempQuad.alpha = 0.2;
//        tempQuad.x = 0;
//        tempQuad.y = yDivider;
//        tempQuad.touchable = false;
//        addChild(tempQuad);
//
//        var dividerQuad:Quad;
//        dividerQuad = new Quad(stageWidth, 1,  Constants.DETAIL_COLOR);
//        dividerQuad.alpha = 0.1;
//        dividerQuad.x = 0;
//        dividerQuad.y = yDivider;
//        dividerQuad.touchable = false;
//        addChild(dividerQuad);
//
//        dividerQuad = new Quad(stageWidth, 1, Constants.DETAIL_COLOR);
//        dividerQuad.alpha = 0.05;
//        dividerQuad.x = 0;
//        dividerQuad.y = breadcrumbDivider;
//        dividerQuad.touchable = false;
//        addChild(dividerQuad);

//        var logoOffset:int = 7;
//        var logo:Image = new Image(Assets.assets.getTexture("levelHalf"));
//        logo.pivotX = Math.floor(logo.width / 2);
//        logo.pivotY = Math.floor(logo.height / 2);
//        logo.rotation = -Math.PI / 4;
//        logo.x = Math.floor(stageWidth - logo.width / 2 + logoOffset);
//        logo.y = Math.floor(stageHeight - logo.height / 2 + logoOffset);
//        logo.color = Constants.BACKGROUND_COLOR;
//        logo.alpha = 0.5;
//        logo.touchable = false;
//        addChild(logo);

        if(displayTokens == null) {
            displayTokens = StringDisplayTokens.createStringDisplayTokensForLetters(
                    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", Constants.DEFAULT_FONT);
        }

//        var alphabet:String = "ABCXYZ";
//        models[0] = RandomCaseModel.createBoardModelForLetters(rows, columns, "a");
//        models[0] = BoardModel.createBoardModelForLetters(rows, columns, "A");
        var totalPositions:int = rows * columns;
        var shouldReset:Boolean = true;
        if(models[0] == null) {
            models[0] = AlphaOrderBoardModel.createBoardModelForLetters("ABCXYZ", totalPositions);
//            models[0] = BoardModel.createBoardModelForLetters("ABCDEFGHIJKLMNOPQRSTUVWXYZ", totalPositions);
            modelLabels[0] = "ABC";
            models[1] = AlphaOrderBoardModel.createBoardModelForLetters("abcdefghijklmnopqrstuvwxyz", totalPositions);
            modelLabels[1] = "abc";
            models[2] = RandomCaseModel.createBoardModelForLetters("abcdefghijklmnopqrstuvwxyz", totalPositions);
            modelLabels[2] = "aBc";

            currentModel = 0;
            currentModelLabel = modelLabels[currentModel];
        } else if(models[0].getTotalPositions() != totalPositions) {
            models[0].setTotalPositions(totalPositions);
            models[1].setTotalPositions(totalPositions);
            models[2].setTotalPositions(totalPositions);
        } else {
            shouldReset = false;
        }

        var scale:int = Math.min(boardWidth / columns, boardHeight / rows);
        if(board == null) {
            board = new AlphaOrderBoard(columns, rows, isLandscape, models[currentModel], displayTokens);
            board.addEventListener(Board.BOARD_EVENT, boardCallback0);
            addChild(board);
        } else {
            board.setDimensions(columns, rows, isLandscape);
        }

        board.pivotX = board.width / 2;
        board.pivotY = board.height / 2;
        board.x = boardCenterX;
        board.y = boardCenterY;
        board.scaleX = scale;
        board.scaleY = scale;

        if(breadcrumbs == null) {
            breadcrumbs = new StringBreadcrumbs(breadcrumbWidth, breadcrumbHeight, models[currentModel]);
            breadcrumbs.addEventListener(BreadcrumbEvent.TOKEN_TOUCHED, breadcrumbCallback0);
            addChild(breadcrumbs);
        } else {
            breadcrumbs.setDimensions(breadcrumbWidth, breadcrumbHeight);
            breadcrumbs.setModel(models[currentModel]);
        }

        breadcrumbs.pivotX = breadcrumbs.width / 2;
        breadcrumbs.pivotY = breadcrumbs.height / 2;
        breadcrumbs.x = breadcrumbCenterX;
        breadcrumbs.y = breadcrumbCenterY;

        if(fadeWall == null) {
            fadeWall = new Quad(1, 1, 0x888888);
            fadeWall.blendMode = BlendMode.MULTIPLY;
            fadeWall.touchable = false;
            fadeWall.alpha = 0;
            addChild(fadeWall);
        }

        fadeWall.x = 0;
        fadeWall.y = 0;
        fadeWall.scaleX = stageWidth;
        fadeWall.scaleY = stageHeight;

        if(particleSystem == null) {
            var xml:XML = XML(Assets.assets.getXml("particleConfig"));
            var texture:Texture = Assets.assets.getTexture("particleTexture");
            particleSystem = new PDParticleSystem(xml, texture);
            particleSystem.alpha = 0;
            addChild(particleSystem);
        }

        particleSystem.emitterX = stageWidth / 2;
        particleSystem.emitterY = stageHeight;
        particleSystem.x = 0;
        particleSystem.y = 0;
//        particleSystem.scaleX = particleSystem.scaleY = stageWidth / 300;
//trace(particleSystem.scaleX + " " + particleSystem.scaleY + " " + particleSystem.emitterX + ", " + particleSystem.emitterY);
//trace(particleSystem.x + ", " + particleSystem.y + " " + particleSystem.width + " " + particleSystem.height);
        PDParticleSystem(particleSystem).emitterXVariance = boardWidth;

        var controlsWidth:int = boardWidth;
        var controlsHeight:int = yDivider - 2 * padding;
        var controlsCenterX:int = boardCenterX;
        var controlsCenterY:int = padding + controlsHeight / 2;

//        var leftButton:DisplayObject = createButton(HAlign.LEFT);
//        leftButton.addEventListener(TouchEvent.TOUCH, handleLeftButtonTrigger);
//        addChild(leftButton);
//
//        var centerButton:DisplayObject = createButton(HAlign.CENTER);
//        centerButton.addEventListener(TouchEvent.TOUCH, handleCenterButtonTrigger);
//        addChild(centerButton);
//
//        var rightButton:DisplayObject = createButton(HAlign.RIGHT);
//        rightButton.addEventListener(TouchEvent.TOUCH, handleRightButtonTrigger);
//        addChild(rightButton);

        if(stopwatch == null) {
            stopwatch = new Stopwatch();
            Starling.juggler.add(stopwatch);
        }

        var textHeight:Number = boardHeight / 5;
        if(stopwatchText == null) {
            stopwatchText = createTextField(boardWidth, textHeight, "XXXX.XX");
            stopwatchText.color = Constants.TEXT_COLOR;
            stopwatchText.touchable = false;
            stopwatchText.scaleX = 1;
            stopwatchText.scaleY = 1;
            stopwatchText.alpha = 0.0;
            addChild(stopwatchText);

            secondsText = createTextField(boardWidth, textHeight / 2, "seconds");
            secondsText.fontSize = stopwatchText.fontSize * 0.5;
            secondsText.color = Constants.TEXT_COLOR;
            secondsText.touchable = false;
            secondsText.alpha = 0.0;
            addChild(secondsText);

            endStopwatchTween = new Tween(stopwatchText, 1, "easeIn");
        } else {
            stopwatchText.width = boardWidth;
            stopwatchText.height = textHeight;
            secondsText.width = boardWidth;
            secondsText.height = textHeight / 2;
        }

        stopwatchText.x = boardCenterX;
        stopwatchText.y = boardCenterY;

        secondsText.x = stopwatchText.x;
        secondsText.y = stopwatchText.y + stopwatchText.height;
        secondsText.pivotX = secondsText.width / 2;
        secondsText.pivotY = secondsText.height / 2;
        secondsText.scaleX = 1;
        secondsText.scaleY = 1;

//        modeTextField = createTextField(controlsWidth / 3, controlsHeight * 0.45, "ABC");
//        modeTextField.color = Constants.TEXT_COLOR;
//        modeTextField.pivotX = 0;
//        modeTextField.pivotY = modeTextField.height / 2;
//        modeTextField.x = padding * 2;
//        modeTextField.y = controlsCenterY;
//        addChild(modeTextField);

//        var title:Image;
//        title = new Image(Assets.assets.getTexture("AlphaOrder"));
//        title.color = 0xFFFFFF;
//        title.pivotX = title.width / 2;
//        title.pivotY = 0;
//        title.x = controlsCenterX;
//        title.y = controlsHeight * 0.2;
//        title.scaleX = title.scaleY = yDivider / title.height;
//        title.touchable = false;
//        addChild(title);
//
//        var restartIcon:Image;
//        restartIcon = new Image(Assets.assets.getTexture("restart"));
//        restartIcon.color = Constants.TEXT_COLOR;
//        restartIcon.pivotX = restartIcon.width;
//        restartIcon.pivotY = restartIcon.height / 2;
//        restartIcon.height = controlsHeight / 2;
//        //noinspection JSSuspiciousNameCombination
//        restartIcon.width = restartIcon.height;
//        restartIcon.x = controlsWidth;
//        restartIcon.y = controlsCenterY;
//        restartIcon.touchable = false;
//        addChild(restartIcon);

        if(fullScreenTouch == null) {
            fullScreenTouch = new Quad(1, 1, 0xFFFFFF);
            fullScreenTouch.addEventListener(TouchEvent.TOUCH, handleFadeWallTouch);
            fullScreenTouch.alpha = 0.0;
            fullScreenTouch.touchable = false;
            addChild(fullScreenTouch);
        }

        fullScreenTouch.scaleX = stageWidth;
        fullScreenTouch.scaleY = stageHeight;
        fullScreenTouch.x = 0;
        fullScreenTouch.y = 0;

        if(shouldReset) {
            board.restart();
        } else {
            board.update();
        }

        Starling.juggler.add(board);

        dispatchEvent(new Event(INITIALIZED_EVENT, false));
    }

    private function breadcrumbCallback0(event:BreadcrumbEvent):void {
        var token:String = event.getToken();

        if(token != null) {
            _ce.sound.playSound(token.toLowerCase());
        }
    }

    protected function initializeModels():void {

    }

    public function getBoard():AlphaOrderBoard {
        return board;
    }

    public function getStopwatch():Stopwatch {
        return stopwatch;
    }

    public function mute():void {
        _ce.sound.masterMute = true;
    }

    private function handleFadeWallTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        var now:int = getTimer();

        if(touch != null && touch.phase == TouchPhase.BEGAN && now > fadeWallResetTime) {
            board.restart();
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

        nextGameMode();

        _ce.sound.playSound("beep");
    }

    public function nextGameMode():void {
        currentModel = (currentModel + 1) % models.length;
        currentModelLabel = modelLabels[currentModel];
        board.setModel(models[currentModel], displayTokens);
        modeTextField.text = modelLabels[currentModel];
    }

    private function handleCenterButtonTrigger(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null || touch.phase != TouchPhase.BEGAN) {
            return;
        }

        _ce.sound.stopAllPlayingSounds();
        _ce.sound.playSound("AlphaOrder");
    }

    private function handleRightButtonTrigger(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null || touch.phase != TouchPhase.BEGAN) {
            return;
        }

        board.restart();
        _ce.sound.playSound("beep");
    }

    private function boardCallback0(event:BoardEvent):void {
        var op:int = event.getState();
        var token:String = event.getToken();
        var nextToken:String = board.getModel().getCurrentSolutionToken();

        if(op == BoardEvent.CORRECT) {
            breadcrumbs.setNextToken(token, false);

            if(nextToken != null) {
                breadcrumbs.shiftTokens();
                breadcrumbs.setNextToken(nextToken, true);
            }

            playCorrectSound(token);
        } else if(op == BoardEvent.INCORRECT) {
            playWrongSound();
        } else if(op == BoardEvent.START) {
            breadcrumbs.clear();
            hideEndTime();
            stopwatch.reset();
            stopwatch.start();
            fadeWall.alpha = 0;
            fullScreenTouch.touchable = false;
            particleSystem.alpha = 0;
            particleSystem.stop();
            Starling.juggler.remove(particleSystem);
        } else if(op == BoardEvent.FINISH) {
            stopwatch.stop();
            fadeWall.alpha = 0.0;
            Starling.juggler.tween(fadeWall, 2, {alpha: 1.0});
            fadeWallResetTime = getTimer() + 3 * 1000;
            fullScreenTouch.touchable = true;

            Starling.juggler.delayCall(function():void {
                _ce.sound.playSound("celebrate");
                showEndTime();
                particleSystem.alpha = 0.0;
                particleSystem.start();
                particleSystem.populate(100);
                Starling.juggler.add(particleSystem);
                Starling.juggler.tween(particleSystem, 1, {alpha: 1.0});
            }, 1);
        }
    }

    private function playWrongSound():void {
        if(models[currentModel].isAtStart()) {
            _ce.sound.stopAllPlayingSounds();
            _ce.sound.playSound("TouchTheLetters");
        } else {
            var random:int = Constants.WRONG_SOUNDS.length * Math.random();
            _ce.sound.playSound(Constants.WRONG_SOUNDS[random]);
        }
    }

    private function playCorrectSound(token:String):void {
        _ce.sound.playSound(token.toLowerCase());
    }

    private function hideEndTime():void {
        Starling.juggler.remove(endStopwatchTween);
        stopwatchText.alpha = 0.0;
        secondsText.alpha = 0.0;

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

        var delay:Number = 1;
        endStopwatchTween.reset(stopwatchText, delay, "easeIn");
        endStopwatchTween.animate("alpha", 1.0);
        endStopwatchTween.animate("scaleX", 1.0);
        endStopwatchTween.animate("scaleY", 1.0);
        endStopwatchTween.animate("rotation", Math.PI * 2);
        Starling.juggler.add(endStopwatchTween);

        Starling.juggler.delayCall(function():void {
            secondsText.alpha = 1.0;
        }, delay);
    }

    public function createTextField(width:Number, height:Number, msg:String, font:String = Constants.DEFAULT_FONT):TextField {
        var fontSize:Number = Math.min(width, height);
        var textField:TextField = new TextField(width, height, msg, font, fontSize, 0xFFFFFF);
        textField.autoSize = TextFieldAutoSize.BOTH_DIRECTIONS;
        textField.touchable = false;
//
//        var scaleX:Number = width / textField.width;
//        var scaleY:Number = height / textField.height;
//        textField.fontSize = fontSize * Math.min(scaleX, scaleY);

        return textField;
    }
}
}