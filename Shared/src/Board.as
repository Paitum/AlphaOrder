package {

import flash.geom.Point;
import flash.utils.Dictionary;

import starling.animation.IAnimatable;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.BlendMode;

import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

import test.ShakeTween;

public class Board extends Sprite implements IAnimatable {

    // [r][c] -> tile:Quad
    protected var tiles:Vector.<Vector.<Quad>>;
    // [r][c] -> highlightTile:Quad
    protected var highlightTiles:Vector.<Vector.<Quad>>;
    // [r][c] -> tween:Tween
    protected var highlightTweens:Vector.<Vector.<Tween>>;
    // name:String -> DisplayObjectContainer
    protected var pieces:Dictionary;
    protected var wiggleTween:ShakeTween;
    protected var wiggleToken:String;

    protected var celebrate:Boolean = false;
    protected var lastCelebrateTime:Number = 0;

    protected var callback:Function;
    protected var model:BoardModel;

    private var mark:Quad;
    private var lastTileTouched:Point = new Point(-1, -1);
    private var celebrateX:int = 0;
    private var celebrateY:int = 0;
    private var celebrateXDir:int = 0;
    private var celebrateYDir:int = 0;

    // cache
    private var touchPoint:Point = new Point();

    public static const START:int = 0;
    public static const FINISH:int = 1;
    private const DEBUG:Boolean = false;

    public function Board(model:BoardModel, callback:Function) {
        this.model = model;
        this.callback = callback;

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function changeModel(model:BoardModel):void {
        if(this.model.getColumns() != model.getColumns() || this.model.getRows() != model.getRows()) {
            throw new Error("New Model mustn't change board dimensions")
        }

        reset();
        this.model = model;
        resetAndStart();
    }

    public function resetAndStart():void {
        model.reset();
        reset();
        populateBoard();
        callback(START);
    }

    private function handleAddedToStage(event:Event):void {
        if(tiles == null) {
            initialize();
        }
    }

    /**
     * Instantiates internal data structures
     */
    protected function initialize():void {
        var r:int, c:int;

        wiggleTween = new ShakeTween(0.05, 0.3);
        Starling.juggler.add(wiggleTween);

        tiles = new Vector.<Vector.<Quad>>();
        highlightTiles = new Vector.<Vector.<Quad>>();
        highlightTweens = new Vector.<Vector.<Tween>>();
        for(r = 0; r < model.getRows(); r++) {
            tiles[r] = new Vector.<Quad>();
            highlightTiles[r] = new Vector.<Quad>();
            highlightTweens[r] = new Vector.<Tween>();

            for(c = 0; c < model.getColumns(); c++) {
                tiles[r][c] = new Image(Assets.assets.getTexture("ConstructionPaper"));
                tiles[r][c].width = 1;
                tiles[r][c].height = 1;
                tiles[r][c].color = getTileColor(r,c);
//                tiles[r][c] = new Quad(1, 1, getTileColor(r, c));
                tiles[r][c].x = c;
                tiles[r][c].y = r;
                tiles[r][c].alpha = 1.0;
                highlightTiles[r][c] = new Quad(1, 1, 0xFF0000);
                highlightTiles[r][c].x = c;
                highlightTiles[r][c].y = r;
                highlightTiles[r][c].alpha = 0.0;
//                highlightTiles[r][c].blendMode = BlendMode.SCREEN;
                highlightTiles[r][c].touchable = false;
                highlightTweens[r][c] = new Tween(highlightTiles[r][c], 0.25, "easeOut");   // this declaration does nothing
                highlightTweens[r][c].animate("alpha", 0.0);
                Starling.juggler.add(highlightTweens[r][c]);
                addChild(tiles[r][c]);
                addChild(highlightTiles[r][c]);
            }
        }

        // Add a gradient to make less repetitive
        var background:Quad = new Quad(model.getColumns(), model.getRows(), 0xFF0000);
        background.setVertexColor(0, 0xBBBBBB);
        background.setVertexColor(1, 0xEEEEEE);
        background.setVertexColor(2, 0xFFFFFF);
        background.setVertexColor(3, 0xFFFFFF);
        background.blendMode = BlendMode.MULTIPLY;
        addChild(background);

        initializePieces();

        if(DEBUG) {
            mark = new Quad(0.05, 0.05, 0xFF0000);
            mark.pivotX = mark.width / 2;
            mark.pivotY = mark.width / 2;
            addChild(mark);
        }

        addEventListener(TouchEvent.TOUCH, handleTouch);
    }

    /**
     * Sets the data structures to neutral values
     */
    protected function reset():void {
        celebrate = false;
        lastCelebrateTime = 0;
        lastTileTouched.setTo(-1, -1);

        var tokenCount:int = model.getTokenCount();
        for(var i:int = 0; i < tokenCount; i++) {
            var token:String = model.getToken(i);
            removeChild(pieces[token]);
        }
    }

    protected function initializePieces():void {
        throw new Error("Subclass to implement");
    }

    protected function populateBoard():void {
        while(model.hasEmptyPosition() && model.hasNextToken()) {
            var position:Point = model.getNextEmptyPosition();
            var token:String = model.placeNextToken(int(position.y), int(position.x));
            addPiece(token, position)
        }
    }

    protected function addPiece(token:String, position:Point):void {
        pieces[token].x = position.x + 0.5;
        pieces[token].y = position.y + 0.5;
        addChild(pieces[token]);
    }

    private static function getTileColor(row:int, columns:int):uint {
        return ((row % 2 + columns) % 2) == 0 ? 0x9BC6FF : 0x64A7FF;
//        var shade:uint = ((row % 2 + columns) % 2) * 128 + 128;
//        return (255 << 16) | (shade << 8) | shade;
//        return uint(Math.random() * 255) << 16 | uint(Math.random() * 255) << 8 | uint(Math.random() * 255);
    }

    override public function get width():Number {
        return model.getColumns();
    }

    override public function get height():Number {
        return model.getRows();
    }

    private function handleTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null) {
            return;
        }

        touch.getLocation(this, touchPoint);

        if(DEBUG) {
            mark.x = touchPoint.x;
            mark.y = touchPoint.y;
        }

        var column:int = Math.floor(touchPoint.x);
        var row:int = Math.floor(touchPoint.y);
        var success:Boolean = false;
        var newTileTouched:Boolean = column != lastTileTouched.x || row != lastTileTouched.y;

//trace(touch.phase + " (" + column + ", " + row + ") (" + touchPoint.x + ", " + touchPoint.y + ") " + newTileTouched + " " + lastTileTouched);
        if(touchPoint.x < 0 || touchPoint.x >= model.getColumns() ||
                touchPoint.y < 0 || touchPoint.y >= model.getRows())
        {
            if(newTileTouched && lastTileTouched.y != -1 && lastTileTouched.x != -1) {
                fadeHighlightTile(lastTileTouched.y, lastTileTouched.x);
            }
            lastTileTouched.setTo(-1, -1);
            return;
        }

        if(touch.phase == TouchPhase.HOVER) {
            return;
        }

        if(touch.phase == TouchPhase.BEGAN) {
            success = positionTouched(row, column);
            setHighlightTileColor(row, column, success ? 0x00FF00 : 0xFF0000);
        }
        else if(touch.phase == TouchPhase.MOVED) {
            success = model.isSolution(row, column);
//            success = positionTouched(row, column);

            if(newTileTouched) {
                setHighlightTileColor(row, column, success ? 0x00FF00 : 0xFF0000);
            }
        } else if(touch.phase == TouchPhase.ENDED) {
            fadeHighlightTile(row, column);
        }

        if(!success && touch.phase == TouchPhase.BEGAN) {
            wigglePiece(model.getTokenOnBoard(row, column));
        }

        if(newTileTouched && lastTileTouched.y != -1 && lastTileTouched.x != -1) {
            fadeHighlightTile(lastTileTouched.y, lastTileTouched.x);
        }

        lastTileTouched.setTo(column, row);
    }

    private function setHighlightTileColor(row:int, column:int, color:uint):void {
        var tile:Quad = highlightTiles[row][column];
        Starling.juggler.remove(highlightTweens[row][column]);
        tile.color = color;
        tile.alpha = 1.0;
    }

    private function fadeHighlightTile(row:int, column:int):void {
        var tile:Quad = highlightTiles[row][column];
        var tween:Tween = highlightTweens[row][column];
        tween.reset(tile, 0.5, "easeOut");
        tween.animate("alpha", 0.0);
        Starling.juggler.add(tween);
    }

    private function wigglePiece(token:String):void {
        if(token == null) {
            return;
        }

        var point:Point;

        // Undo active wiggling
        if(wiggleToken != token) {
            wiggleTween.stop();
            Starling.juggler.remove(wiggleTween);
            point = model.getPosition(wiggleToken);
            if(point != null) {
                pieces[wiggleToken].x = point.x + 0.5;
                pieces[wiggleToken].y = point.y + 0.5;
            }
        }

        point = model.getPosition(token);
        if(point == null) {
            return;
        }

        var piece:DisplayObjectContainer = pieces[token];
        wiggleToken = token;
        if(wiggleToken != token || wiggleTween.isComplete()) {
            wiggleTween.setTarget(piece);
            Starling.juggler.add(wiggleTween);
        }
    }

    private function positionTouched(row:int, column:int):Boolean {
        var token:String = model.processSolution(row, column);

        if(token != null) {
            removeChild(pieces[token]);

            if(model.hasNextToken()) {
                populateBoard();
            }

            if(model.getCurrentSolutionToken() == null) {
                callback(FINISH);
                startCelebration();

            }
        }

        return token != null;
    }

    private function startCelebration():void {
        celebrate = true;
        celebrateX = 0;
        celebrateY = 0;
        celebrateXDir = 1;
        celebrateYDir = 0;
    }



    public function advanceTime(time:Number):void {
        if(!celebrate) return;

        lastCelebrateTime += time;

        const interval:Number = 0.05;
        if(lastCelebrateTime > interval) {
            celebrateX += celebrateXDir;
            celebrateY += celebrateYDir;

            if(celebrateXDir > 0 && celebrateX == model.getColumns() - 1) {
                celebrateXDir = 0;
                celebrateYDir = 1;
            } else if(celebrateXDir < 0 && celebrateX == 0) {
                celebrateXDir = 0;
                celebrateYDir = -1;
            } else if(celebrateYDir > 0 && celebrateY >= model.getRows() - 1) {
                celebrateXDir = -1;
                celebrateYDir = 0;
            } else if(celebrateYDir < 0 && celebrateY < 1) {
                celebrateXDir = 1;
                celebrateYDir = 0;
            }
//trace(celebrateX + ", " + celebrateY);
            setHighlightTileColor(celebrateY, celebrateX, 0x00FF00);
            fadeHighlightTile(celebrateY, celebrateX);

            lastCelebrateTime -= interval;
        }

    }
}
}
