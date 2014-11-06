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
    private var endStopwatchTween:Tween;
    private var models:Vector.<AlphaOrderBoardModel> = new Vector.<AlphaOrderBoardModel>(2);
    private var modelLabels:Vector.<String> = new Vector.<String>();
    private var currentModelLabel:String;
    private var currentModel:int = -1;
    private var padding:int;
    private var fadeWallResetTime:int;

    // UI Components
    private var backgroundImage:Image;
    private var controlsBackgroundFade:Quad;
    private var breadcrumbBackgroundFade:Quad;
    private var breadcrumbs:StringBreadcrumbs;
    private var board:AlphaOrderBoard;
    private var stopwatchText:TextField;
    private var secondsText:TextField;
    private var displayTokens:DisplayTokens;
    private var fadeWall:Quad;
    private var fullScreenTouch:Quad;
    private var modeTextField:TextField;
    private var title:Image;
    private var restartIcon:Image;
    private var particleSystem:ParticleSystem;
    private var optionsSprite:OptionsSprite;
    private var leftButton:DisplayObject;
    private var centerButton:DisplayObject;
    private var rightButton:DisplayObject;

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
        var division:int = 11;
        // Assume Portrait
        var portraitHeight:int = isLandscape ? stageWidth : stageHeight;
        var portraitWidth:int = isLandscape ? stageHeight : stageWidth;

        var controlsWidth:int = portraitWidth - 2 * padding;
        var controlsHeight:int = portraitHeight / division;
        var controlsDivider:int = controlsHeight;
        var controlsCenterX:int = padding + controlsWidth / 2;
        var controlsCenterY:int = controlsHeight / 2;

        var breadcrumbWidth:int = controlsWidth;
        var breadcrumbHeight:int = portraitHeight / division;
        var breadcrumbsDivider:int = controlsDivider + breadcrumbHeight + padding;
        var breadcrumbCenterX:int = padding + breadcrumbWidth / 2;
        var breadcrumbCenterY:int = controlsDivider + padding / 2 + breadcrumbHeight / 2;

        var boardWidth:int = controlsWidth;
        var boardHeight:int = portraitHeight - (breadcrumbsDivider + padding * 1.5);
        var boardCenterX:int = padding + boardWidth / 2;
        var boardCenterY:int = breadcrumbsDivider + padding / 2 + boardHeight / 2;

        if(isLandscape) {
            var temp:int;
            temp = controlsWidth; controlsWidth = controlsHeight; controlsHeight = temp;
            temp = controlsCenterX; controlsCenterX = controlsCenterY; controlsCenterY = temp;
            temp = breadcrumbWidth; breadcrumbWidth = breadcrumbHeight; breadcrumbHeight = temp;
            temp = breadcrumbCenterX; breadcrumbCenterX = breadcrumbCenterY; breadcrumbCenterY = temp;
            temp = boardWidth; boardWidth = boardHeight; boardHeight = temp;
            temp = boardCenterX; boardCenterX = boardCenterY; boardCenterY = temp;
        }

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

        if(controlsBackgroundFade == null) {
            controlsBackgroundFade = new Quad(1, 1, 0x000000);
            controlsBackgroundFade.touchable = false;
            controlsBackgroundFade.alpha = 0.4;
            controlsBackgroundFade.x = 0;
            controlsBackgroundFade.y = 0;
            addChild(controlsBackgroundFade);
        }

        controlsBackgroundFade.scaleX = isLandscape ? controlsDivider : portraitWidth;
        controlsBackgroundFade.scaleY = isLandscape ? portraitWidth : controlsDivider;

        if(breadcrumbBackgroundFade == null) {
            breadcrumbBackgroundFade = new Quad(1, 1, 0x000000);
            breadcrumbBackgroundFade.touchable = false;
            breadcrumbBackgroundFade.alpha = 0.2;
            breadcrumbBackgroundFade.x = 0;
            breadcrumbBackgroundFade.y = 0;
            addChild(breadcrumbBackgroundFade);
        }

        breadcrumbBackgroundFade.scaleX = isLandscape ? breadcrumbsDivider : portraitWidth;
        breadcrumbBackgroundFade.scaleY = isLandscape ? portraitWidth : breadcrumbsDivider;

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
//            models[0] = AlphaOrderBoardModel.createBoardModelForLetters("AB", totalPositions);
            models[0] = AlphaOrderBoardModel.createBoardModelForLetters("ABCDEFGHIJKLMNOPQRSTUVWXYZ", totalPositions);
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
            breadcrumbs = new StringBreadcrumbs(breadcrumbWidth, breadcrumbHeight, isLandscape, models[currentModel]);
            breadcrumbs.addEventListener(BreadcrumbEvent.TOKEN_TOUCHED, breadcrumbCallback0);
            addChild(breadcrumbs);
        } else {
            breadcrumbs.setup(breadcrumbWidth, breadcrumbHeight, isLandscape, models[currentModel]);
        }

        breadcrumbs.pivotX = breadcrumbs.width / 2;
        breadcrumbs.pivotY = breadcrumbs.height / 2;
        breadcrumbs.x = breadcrumbCenterX;
        breadcrumbs.y = breadcrumbCenterY;

        if(leftButton == null) {
            leftButton = createButton(HAlign.LEFT, stageWidth / 3, controlsDivider);
            leftButton.addEventListener(TouchEvent.TOUCH, handleLeftButtonTrigger);
            addChild(leftButton);
        }

        leftButton.x = 0;
        leftButton.y = isLandscape ? stageHeight : 0;
        leftButton.rotation = isLandscape ? -Math.PI / 2 : 0;

        if(centerButton == null) {
            centerButton = createButton(HAlign.CENTER, stageWidth / 3, controlsDivider);
            centerButton.addEventListener(TouchEvent.TOUCH, handleCenterButtonTrigger);
            addChild(centerButton);
        }

        centerButton.x = isLandscape ? 0 : stageWidth / 3;
        centerButton.y = isLandscape ? stageHeight / 3 * 2 : 0;
        centerButton.rotation = isLandscape ? -Math.PI / 2 : 0;

        if(rightButton == null) {
            rightButton = createButton(HAlign.RIGHT, stageWidth / 3, controlsDivider);
            rightButton.addEventListener(TouchEvent.TOUCH, handleRightButtonTrigger);
            addChild(rightButton);
        }

        rightButton.x = isLandscape ? 0 : stageWidth / 3 * 2;
        rightButton.y = isLandscape ? stageHeight / 3 : 0;
        rightButton.rotation = isLandscape ? -Math.PI / 2 : 0;


        if(modeTextField == null) {
            modeTextField = createTextField(controlsWidth / 3, controlsHeight * 0.40, "ABC");
            modeTextField.color = Constants.TEXT_COLOR;
            modeTextField.pivotX = modeTextField.width / 2;
            modeTextField.pivotY = modeTextField.height / 2;
            addChild(modeTextField);
        }

        modeTextField.x = isLandscape ? controlsCenterX : padding + modeTextField.pivotX;
        modeTextField.y = isLandscape ? padding + controlsHeight - modeTextField.pivotX : controlsCenterY;
//        modeTextField.rotation = isLandscape ? -Math.PI / 2 : 0;

        if(title == null) {
            title = new Image(Assets.assets.getTexture("AlphaOrder"));
            title.pivotX = title.width / 2;
            title.pivotY = title.height / 2;
            title.color = 0xFFFFFF;
            title.scaleX = title.scaleY = controlsDivider / title.height * 1.1;
            title.touchable = false;
            addChild(title);
        }

// Rotate
//        title.scaleX = title.scaleY = 1.0;
//        title.rotation = 0;
//        title.scaleX = title.scaleY = isLandscape ? controlsDivider / title.width : controlsDivider / title.height;
//        title.x = isLandscape ? controlsCenterX : controlsCenterX;
//        title.y = isLandscape ? controlsCenterY : controlsCenterY * 1.4;

        title.x = isLandscape ? controlsCenterX * 1.4 : controlsCenterX;
        title.y = isLandscape ? controlsCenterY : controlsCenterY * 1.4;
        title.rotation = isLandscape ? -Math.PI / 2 : 0;

        if(restartIcon == null) {
            restartIcon = new Image(Assets.assets.getTexture("restart"));
            restartIcon.color = Constants.TEXT_COLOR;
            restartIcon.pivotX = restartIcon.width;
            restartIcon.pivotY = restartIcon.height / 2;
            restartIcon.height = controlsHeight / 2;
            //noinspection JSSuspiciousNameCombination
            restartIcon.width = restartIcon.height;
            restartIcon.touchable = false;
            addChild(restartIcon);
        }

        restartIcon.x = isLandscape ? controlsCenterX : controlsWidth;
        restartIcon.y = isLandscape ? padding : controlsCenterY;
        restartIcon.rotation = isLandscape ? -Math.PI / 2 : 0;

        if(particleSystem == null) {
            var xml:XML = XML(Assets.assets.getXml("particleConfig"));
            var texture:Texture = Assets.assets.getTexture("particleTexture");
            particleSystem = new PDParticleSystem(xml, texture);
            particleSystem.alpha = 0;
            addChild(particleSystem);
        }

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

        particleSystem.emitterX = stageWidth / 2;
        particleSystem.emitterY = stageHeight;
        particleSystem.x = 0;
        particleSystem.y = 0;
//        particleSystem.scaleX = particleSystem.scaleY = stageWidth / 300;
//trace(particleSystem.scaleX + " " + particleSystem.scaleY + " " + particleSystem.emitterX + ", " + particleSystem.emitterY);
//trace(particleSystem.x + ", " + particleSystem.y + " " + particleSystem.width + " " + particleSystem.height);
        PDParticleSystem(particleSystem).emitterXVariance = boardWidth;

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

//        if(optionsSprite == null) {
//            optionsSprite = new OptionsSprite();
//            addChild(optionsSprite);
//            optionsSprite.pivotX = optionsSprite.width / 2;
//            optionsSprite.pivotY = optionsSprite.height / 2;
//        }
//
//        optionsSprite.scaleX = optionsSprite.scaleY = portraitWidth - 2 * padding;
//        optionsSprite.x = stageWidth / 2;
//        optionsSprite.y = stageHeight / 2;

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

    private function createButton(hAlign:String, width:int, height:int):Quad {
        var button:Quad = new Quad(width, height, 0x000000);
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
        breadcrumbs.setModel(models[currentModel]);
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
            fadeWallResetTime = getTimer() + 2000;
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