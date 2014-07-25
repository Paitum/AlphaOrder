package {

import flash.geom.Point;
import flash.utils.Dictionary;

import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class Board extends Sprite {

    // name:String -> tile:Quad
    private var tiles:Vector.<Vector.<Quad>>;
    // name:String -> DisplayObjectContainer
    private var pieces:Dictionary;

    protected var callback:Function;
    protected var model:BoardModel;

    private var mark:Quad;

    // cache
    private var touchPoint:Point = new Point();
    private var positionVector:Vector.<Point> = new Vector.<Point>();

    public static const START:int = 0;
    public static const FINISH:int = 1;

    public function Board(model:BoardModel, callback:Function) {
        this.model = model;
        this.callback = callback;

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function stop():void {
        callback(FINISH);
    }

    public function resetAndStart():void {
        model.reset();
        reset();
        populateBoard();
        callback(START);
    }

    private function handleAddedToStage(event:Event):void {
        initialize();
    }

    /**
     * Instantiates internal data structures
     */
    protected function initialize():void {
        var r:int, c:int;

        tiles = new Vector.<Vector.<Quad>>();
        for(r = 0; r < model.getRows(); r++) {
            tiles[r] = new Vector.<Quad>();
        }

        for(r = 0; r < model.getRows(); r++) {
            for(c = 0; c < model.getColumns(); c++) {
                tiles[r][c] = new Quad(1, 1, getTileColor(r, c));
                tiles[r][c].x = c;
                tiles[r][c].y = r;
                tiles[r][c].alpha = 0.5;
                addChild(tiles[r][c]);
            }
        }

        pieces = new Dictionary();
        var tokenCount:int = model.getTokenCount();
        for(var i:int = 0; i < tokenCount; i++) {
            var token:String = model.getToken(i);
            pieces[token] = createPiece(token);
        }

        mark = new Quad(0.05, 0.05, 0xFF0000);
        mark.pivotX = mark.width / 2;
        mark.pivotY = mark.width / 2;
        addChild(mark);

        addEventListener(TouchEvent.TOUCH, handleTouch);
    }

    /**
     * Sets the data structures to neutral values
     */
    protected function reset():void {
        var tokenCount:int = model.getTokenCount();
        for(var i:int = 0; i < tokenCount; i++) {
            var token:String = model.getToken(i);
            removeChild(pieces[token]);
        }

        populateBoard();
    }

    protected function createPiece(token:String):DisplayObjectContainer {
        throw new Error("Subclass must override");
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
        var shade:uint = ((row % 2 + columns) % 2) * 128 + 128;
        return shade << 16 | shade << 8 | shade * 255;
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
        mark.x = touchPoint.x;
        mark.y = touchPoint.y;

        if(touch.phase == TouchPhase.BEGAN) {
            positionTouched(touchPoint);
        }
    }

    private function positionTouched(point:Point):void {
        var token:String = model.checkSolution(int(point.y), int(point.x));

        if(token != null) {
            removeChild(pieces[token]);

            if(model.hasNextToken()) {
                populateBoard();
            }

            if(model.getCurrentSolutionToken() == null) {
                stop();
            }
        }
    }
}
}
