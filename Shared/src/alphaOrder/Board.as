package alphaOrder {

import flash.geom.Point;

import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

public class Board extends Sprite {
    protected var rows:int;
    protected var columns:int;

    // isLandscape, is used to change col/row mapping to the model
    protected var isLandscape:Boolean;
    protected var model:AlphaOrderBoardModel;
    protected var displayTokens:DisplayTokens;

    // [r][c] -> tile:Quad
    protected var tiles:Vector.<Vector.<Quad>>;
    // [r][c] -> highlightTile:Quad
    protected var highlightTiles:Vector.<Vector.<Quad>>;
    // [r][c] -> tween:Tween
    protected var highlightTweens:Vector.<Vector.<Tween>>;

    // cache
    private var touchPoint:Point = new Point();
    protected var tempPoint:Point = new Point();

    [Event(name="boardEvent", type="starling.events.Event")]
    public static const BOARD_EVENT:String = "boardEvent";

    public function Board(columns:int, rows:int, isLandscape:Boolean, model:AlphaOrderBoardModel, displayTokens:DisplayTokens) {
        super();

        setupBoard(columns, rows, isLandscape, model, displayTokens);

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function getModel():AlphaOrderBoardModel {
        return model;
    }

    public function setModel(model:AlphaOrderBoardModel, displayTokens:DisplayTokens):void {
        setupBoard(columns, rows, isLandscape, model, displayTokens);
    }

    public function setDimensions(columns:int, rows:int, isLandscape:Boolean):void {
        if(columns != this.columns || rows != this.rows || isLandscape != this.isLandscape) {
            setupBoard(columns, rows, isLandscape, model, displayTokens);
        }
    }

    public function setupBoard(columns:int, rows:int, isLandscape:Boolean, model:AlphaOrderBoardModel, displayTokens:DisplayTokens):void {
        if(columns * rows != model.getTotalPositions()) {
            throw new Error("Failed to setup board. Positions mismatch [" +
                model.getTotalPositions() + "] vs CR[" + columns + ", " + rows + "]");
        }

        var shouldReset:Boolean = model != this.model ||
                columns * rows != this.model.getTotalPositions() ||
                displayTokens != this.displayTokens;

        this.columns = columns;
        this.rows = rows;
        this.isLandscape = isLandscape;
        this.model = model;
        this.displayTokens = displayTokens;

        if(shouldReset) {
            restart();
        } else {
            update();
        }
    }

    public function restart():void {
        model.reset();
        update();
        dispatchStateEvent(BoardEvent.START);
    }

    public function update():void {
        initialize();
        reset();
        populateBoard();
    }

    public function dispatchStateEvent(state:int, token:String = null):void {
        dispatchEvent(new BoardEvent(BOARD_EVENT, state, token));
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

        if(tiles == null) {
            tiles = new Vector.<Vector.<Quad>>();
            highlightTiles = new Vector.<Vector.<Quad>>();
            highlightTweens = new Vector.<Vector.<Tween>>();
        } else if(tiles.length > rows) {
            // Cull extra rows
            for(r = rows; r < tiles.length; r++) {
                if(tiles[r] == null) continue;

                for(c = 0; c < tiles[r].length; c++) {
                    removeChild(tiles[r][c]);
                    removeChild(highlightTiles[r][c]);
                    tiles[r][c] = null;
                    highlightTiles[r][c] = null;
                    highlightTweens[r][c] = null;
                }
                tiles[r] = null;
                highlightTiles[r] = null;
                highlightTweens[r] = null;
            }
        }

        // TODO clean up these loops and conditionals
        for(r = 0; r < rows; r++) {
            if(!tiles.hasOwnProperty(String(r)) || tiles[r] == null) tiles[r] = new Vector.<Quad>();
            if(!highlightTiles.hasOwnProperty(String(r)) || highlightTiles[r] == null) highlightTiles[r] = new Vector.<Quad>();
            if(!highlightTweens.hasOwnProperty(String(r)) || highlightTweens[r] == null) highlightTweens[r] = new Vector.<Tween>();

            // this will shrink the vectors, if needed
            if(tiles[r].length > columns) {
                // Cull extra columns
                for(c = columns; c < tiles[r].length; c++) {
                    removeChild(tiles[r][c]);
                    removeChild(highlightTiles[r][c]);
                    tiles[r][c] = null;
                    highlightTiles[r][c] = null;
                    highlightTweens[r][c] = null;
                }
            }

            tiles[r].length = columns;
            highlightTiles[r].length = columns;
            highlightTweens[r].length = columns;

            for(c = 0; c < columns; c++) {
                if(tiles[r][c] == null) {
                    tiles[r][c] = new Image(Assets.assets.getTexture("Tile"));
                    addChild(tiles[r][c]);
                }

                tiles[r][c].width = 1;
                tiles[r][c].height = 1;
                tiles[r][c].color = getTileColor(r,c);
                tiles[r][c].x = c;
                tiles[r][c].y = r;
                tiles[r][c].alpha = 1.0;

                if(highlightTiles[r][c] == null) {
                    highlightTiles[r][c] = new Image(Assets.assets.getTexture("Tile"));
                    addChild(highlightTiles[r][c]);
                }

                highlightTiles[r][c].width = 1;
                highlightTiles[r][c].height = 1;
                highlightTiles[r][c].x = c;
                highlightTiles[r][c].y = r;
                highlightTiles[r][c].alpha = 0.0;
                highlightTiles[r][c].touchable = false;

                if(highlightTweens[r][c] == null) {
                    highlightTweens[r][c] = new Tween(highlightTiles[r][c], 0.25, "easeOut");
                    highlightTweens[r][c].animate("alpha", 0.0);
                    Starling.juggler.add(highlightTweens[r][c]);
                }
            }
        }

        addEventListener(TouchEvent.TOUCH, handleTouchEvent);
    }

    /**
     * Sets the data structures to neutral values
     */
    protected function reset():void {
        displayTokens.removeFromDisplayContrainer(this);
    }

    public function populateBoard():void {
        var length:int = model.getTotalPositions();

        for(var i:int = 0; i < length; i++) {
            var token:String = model.getTokenAtPosition(i);

            if(token != null) {
                addPiece(token, i);
            }
        }
    }

    protected function addPiece(token:String, position:int):void {
        getCoordinateFromPosition(position, tempPoint);
        var piece:DisplayObject = displayTokens.getDisplayObject(token);
        piece.x = tempPoint.x + 0.5;
        piece.y = tempPoint.y + 0.5;
        if(!contains(piece)) {
            addChild(piece);
        }
    }

    protected function getCoordinateFromPosition(position:int, result:Point):Point {
        if(result == null) result = new Point();
        var r:int, c:int;

        if(isLandscape) {
            r = (rows - 1) - position % rows;
            c = Math.floor(position / rows);
        } else {
            r = Math.floor(position / columns);
            c = position % columns;
        }

        result.setTo(c, r);
        return result;
    }

    protected function getPositionFromCoordinate(column:int, row:int):int {
        var result:int;
        if(isLandscape) {
            result = ((rows - 1) - row) + column * rows;
        } else {
            result = column + row * columns;
        }

        return result;
    }

    private static function getTileColor(row:int, columns:int):uint {
        return ((row % 2 + columns) % 2) == 0 ? Constants.TILE_COLOR1 : Constants.TILE_COLOR2;
//        var shade:uint = ((row % 2 + columns) % 2) * 128 + 128;
//        return (255 << 16) | (shade << 8) | shade;
//        return uint(Math.random() * 255) << 16 | uint(Math.random() * 255) << 8 | uint(Math.random() * 255);
    }

    override public function get width():Number {
        return columns;
    }

    override public function get height():Number {
        return rows;
    }

    private function handleTouchEvent(event:TouchEvent):void {
        var touches:Vector.<Touch> = event.getTouches(this);

        if(touches.length == 0) {
            return;
        }

        var length:int = touches.length;
        for(var i:int = 0; i < length; i++) {
            handleTouch(touches[i]);
        }
    }

    private function handleTouch(touch:Touch):void {
        touch.getLocation(this, touchPoint);

        var column:int = Math.floor(touchPoint.x);
        var row:int = Math.floor(touchPoint.y);
        var success:Boolean = false;
        var position:int = getPositionFromCoordinate(column, row);

//trace(touch.phase + " (" + column + ", " + row + ") (" + touchPoint.x + ", " + touchPoint.y + ") " + newTileTouched + " " + lastTileTouched);

        if(touch.phase == TouchPhase.HOVER) {
            return;
        }

        processUITouch(column, row, touch.phase);
    }

    /**
     *
     * @param column    the column touched, MAY BE OUT OF BOUNDS
     * @param row       the row touched, , MAY BE OUT OF BOUNDS
     * @param phase     the touch phase
     */
    protected function processUITouch(column:int, row:int, phase:String):void {
        throw new Error("subclass implement");
    }

    protected function setHighlightTileColor(row:int, column:int, color:uint):void {
        var tile:Quad = highlightTiles[row][column];
        Starling.juggler.remove(highlightTweens[row][column]);
        tile.color = color;
        tile.alpha = 1.0;
    }

    protected function fadeHighlightTile(row:int, column:int):void {
        var tile:Quad = highlightTiles[row][column];
        var tween:Tween = highlightTweens[row][column];
        tween.reset(tile, 0.5, "easeOut");
        tween.animate("alpha", 0.0);
        Starling.juggler.add(tween);
    }

    protected function positionTouched(position:int):Boolean {
        throw new Error("subclass must implement");
    }

}
}
