package alphaOrder {

import flash.geom.Point;

import starling.animation.IAnimatable;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.TouchPhase;

public class AlphaOrderBoard extends Board implements IAnimatable  {

    protected var wiggleTween:ShakeTween;
    protected var wigglePosition:int = -1;
    protected var wiggleToken:String = null;

    protected var celebrate:Boolean = false;
    protected var lastCelebrateTime:Number = 0;

    private var celebrateX:int = 0;
    private var celebrateY:int = 0;
    private var celebrateXDir:int = 0;
    private var celebrateYDir:int = 0;

    private var lastTileTouched:Point = new Point(-1, -1);

    public function AlphaOrderBoard(columns:int, rows:int, isLandscape:Boolean,
                                    model:AlphaOrderBoardModel, displayTokens:DisplayTokens)
    {
        super(columns, rows, isLandscape, model, displayTokens);
    }


    override protected function initialize():void {
        super.initialize();

        if(wiggleTween == null) {
            wiggleTween = new ShakeTween(0.05, 0.3);
            Starling.juggler.add(wiggleTween);
        }
    }


    override public function restart():void {
        super.restart();

        celebrate = false;
        lastCelebrateTime = 0;
    }

    override protected function reset():void {
        super.reset();

        wigglePieceStop();

        lastTileTouched.setTo(-1, -1);
    }


    public function solve(count:int):void {
        for(var i:int = 0; i < count; i++) {
            var token:String = model.getCurrentSolutionToken();
            var position:int = model.getPosition(token);
            positionTouched(position);
        }
    }

    override protected function processUITouch(column:int, row:int, phase:String):void {
        var newTileTouched:Boolean = column != lastTileTouched.x || row != lastTileTouched.y;
        var position:int = getPositionFromCoordinate(column, row);

        if(newTileTouched) {
            fadeLastTileTouched();
        }

        if(column < 0 || column >= columns || row < 0 || row >= rows) {
            return;
        }

        if(phase == TouchPhase.BEGAN) {
            var success:Boolean = positionTouched(position);
            setHighlightTileColor(row, column, success ? Constants.TILE_HIGHLIGHT_CORRECT : Constants.TILE_HIGHLIGHT_INCORRECT);

            if(!success) {
                wigglePiece(position);
            }
        } else if(phase == TouchPhase.MOVED) {
            success = model.isSolution(position);

            if(newTileTouched) {
                setHighlightTileColor(row, column, success ? Constants.TILE_HIGHLIGHT_CORRECT : Constants.TILE_HIGHLIGHT_INCORRECT);
            }
        } else if(phase == TouchPhase.ENDED) {
            fadeHighlightTile(row, column);
        }

        lastTileTouched.setTo(column, row);
    }

    public function fadeLastTileTouched():void {
        if(lastTileTouched.y != -1 && lastTileTouched.x != -1) {
            fadeHighlightTile(lastTileTouched.y, lastTileTouched.x);
        }

        lastTileTouched.setTo(-1, -1);
    }

    override protected function positionTouched(position:int):Boolean {
        var token:String = model.processSolution(position);
// TODO Event should be ALphaOrder speciifc
        if(token != null) {
            dispatchStateEvent(BoardEvent.CORRECT, token);
            removeChild(displayTokens.getDisplayObject(token));

            populateBoard();

            if(model.getCurrentSolutionToken() == null) {
                dispatchStateEvent(BoardEvent.FINISH);
                startCelebration();
            }
        } else {
            dispatchStateEvent(BoardEvent.INCORRECT);
        }

        return token != null;
    }

    private function wigglePiece(position:int):void {
        wigglePieceStop();

        var token:String = model.getTokenAtPosition(position);

        if(token == null) {
            return;
        }

        var piece:DisplayObject = displayTokens.getDisplayObject(token);
        wigglePosition = position;
        wiggleToken = token;
        wiggleTween.setTarget(piece);
        Starling.juggler.add(wiggleTween);
    }

    private function wigglePieceStop():void {
        if(wigglePosition != -1) {
            wiggleTween.stop();
            Starling.juggler.remove(wiggleTween);

            var piece:DisplayObject;
            if(wigglePosition >= 0) {
                getCoordinateFromPosition(wigglePosition, tempPoint);
                piece = displayTokens.getDisplayObject(wiggleToken);
                piece.x = tempPoint.x + 0.5;
                piece.y = tempPoint.y + 0.5;
            }
        }

        wigglePosition = -1;
        wiggleToken = null;
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

            if(celebrateXDir > 0 && celebrateX == columns - 1) {
                celebrateXDir = 0;
                celebrateYDir = 1;
            } else if(celebrateXDir < 0 && celebrateX == 0) {
                celebrateXDir = 0;
                celebrateYDir = -1;
            } else if(celebrateYDir > 0 && celebrateY >= rows - 1) {
                celebrateXDir = -1;
                celebrateYDir = 0;
            } else if(celebrateYDir < 0 && celebrateY < 1) {
                celebrateXDir = 1;
                celebrateYDir = 0;
            }

            setHighlightTileColor(celebrateY, celebrateX, Constants.TILE_HIGHLIGHT_CORRECT);
            fadeHighlightTile(celebrateY, celebrateX);

            lastCelebrateTime -= interval;
        }

    }
}
}
