package {

import flash.geom.Point;
import flash.utils.Dictionary;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextField;

public class Board extends Sprite {
    private var columns:int;
    private var rows:int;
    private var alphabet:String;
    // Uppercase and Lowercase Text Sprites
    private var letterSprites:Dictionary;
    protected var nextSolutionPosition:int = 0;
    protected var nextPosition:int = 0;
    // [letter:String] -> position:Point
    private var letterToPosition:Dictionary;
    // [r:int][c:int] -> letter:String
    private var positionToLetter:Vector.<Vector.<String>>;
    private var mark:Quad;
    private var callback:Function;

    // cache
    private var touchPoint:Point = new Point();
    private var positionVector:Vector.<Point> = new Vector.<Point>();

    public static const START:int = 0;
    public static const FINISH:int = 1;

    public function Board(columns:int, rows:int, alphabet:String, callback:Function) {
        this.columns = columns;
        this.rows = rows;
        this.alphabet = alphabet;
        this.callback = callback;

        letterSprites = new Dictionary();

        positionToLetter = new Vector.<Vector.<String>>();
        for(var r:int = 0; r < rows; r++) {
            positionToLetter[r] = new Vector.<String>();
            for(var c:int = 0; c < columns; c++) {
                positionToLetter[r][c] = null;
            }
        }

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function stop():void {
        callback(FINISH);
    }

    public function reset():void {
        nextPosition = 0;
        nextSolutionPosition = 0;
        clear();
        populateBoard();
        callback(START);
    }

    protected function clear():void {
        for(var r:int = 0; r < rows; r++) {
            for(var c:int = 0; c < columns; c++) {
                positionToLetter[r][c] = null;
            }
        }

        var length:int = alphabet.length;
        for(var i:int = 0; i < length; i++) {
            var letter:String = alphabet.charAt(i);
            removeChild(letterSprites[letter]);
            letterToPosition[letter].setTo(-1, -1);
        }
    }

    override public function get width():Number {
        return columns;
    }

    override public function get height():Number {
        return rows;
    }

    private function handleAddedToStage(event:Event):void {
        var quad:Quad;

        for(var r:int = 0; r < rows; r++) {
            for(var c:int = 0; c < columns; c++) {
                quad = new Quad(1, 1, randomColor());
                quad.x = c;
                quad.y = r;
                quad.alpha = 0.25;
                addChild(quad);
            }
        }

        letterToPosition = new Dictionary();
        var length:int = alphabet.length;
        for(var i:int = 0; i < length; i++) {
            var letter:String = alphabet.charAt(i);
            letterSprites[letter] = new TextField(1, 1, letter, "ArtBrushLarge", 0.9, 0xFFFFFF);
            letterSprites[letter].hAlign = "center";
            letterSprites[letter].vAlign = "center";
            letterSprites[letter].pivotX = letterSprites[letter].width / 2;
            letterSprites[letter].pivotY = letterSprites[letter].height / 2;
            letterSprites[letter].x = int(Math.random() * columns) + 0.5;
            letterSprites[letter].y = int(Math.random() * rows) + 0.5;
//            addChild(letterSprites[letter]);
            letterToPosition[letter] = new Point(-1, -1);
        }

        mark = new Quad(0.1, 0.1, 0xFF0000);
        mark.pivotX = mark.width / 2;
        mark.pivotY = mark.width / 2;
        addChild(mark);

        populateBoard();
        addEventListener(TouchEvent.TOUCH, handleTouch);
    }

    protected function populateBoard():void {
        while(hasEmptyPosition() && hasNextLetter()) {
            addLetter();
        }
    }

    protected function addLetter():void {
        var position:Point = getRandomEmptyPosition();

        if(position != null) {
            var letter:String = getLetter(nextPosition);

            if(letter == null) {
                return;
            }

            nextPosition++;

            letterToPosition[letter].copyFrom(position);
            positionToLetter[position.y][position.x] = letter;

            letterSprites[letter].x = position.x + 0.5;
            letterSprites[letter].y = position.y + 0.5;
//trace("addLetter[" + letter + "] to position[" + position + "] field[" + letterSprites[letter].text + "]");
            addChild(letterSprites[letter]);
        }
    }

    protected function getLetter(position:int):String {
        // Natural Order
        return position >= alphabet.length ? null: alphabet.charAt(position);
    }

    protected function getRandomEmptyPosition():Point {

        // TODO Ugh, implement an intelligent randomization
        var length:int = 0;
        positionVector.length = 0;
        for(var r:int = 0; r < rows; r++) {
            for(var c:int = 0; c < columns; c++) {
                if(positionToLetter[r][c] == null) {
                    if(length >= positionVector.length) {
                        positionVector.push(new Point(c, r));
                    } else {
                        positionVector[length].setTo(c, r);
                    }
                    length++;
                }
            }
        }

        var randomIndex:int = Math.random() * length;
        return length == 0 ? null : positionVector[randomIndex];
    }

    protected function hasEmptyPosition():Boolean {
        return getRandomEmptyPosition() != null;
    }

    protected function hasNextLetter():Boolean {
        return nextPosition < alphabet.length;
    }

    protected function hasNextSolutionLetter():Boolean {
        return nextSolutionPosition < alphabet.length;
    }


    private static function randomColor():uint {
        return uint(Math.random() * 255) << 16 | uint(Math.random() * 255) << 8 | uint(Math.random() * 255);
    }

    private function positionTouched(point:Point):void {
        var c:int = int(point.x);
        var r:int = int(point.y);
        var letter:String = positionToLetter[r][c];

        if(letter != null) {
            var correctLetter:String = alphabet.charAt(nextSolutionPosition);

            if(letter == correctLetter) {
                nextSolutionPosition++;
                removeChild(letterSprites[letter]);
                positionToLetter[r][c] = null;

                if(hasNextLetter()) {
                    addLetter();
                } else if(!hasNextSolutionLetter()) {
                    callback(FINISH);
                }
            } else {
                trace("wrong: expect[" + correctLetter + "] not [" + letter + "]");
            }
        }
    }

    private function handleTouch(event:TouchEvent):void {
        var touch:Touch = event.getTouch(this);

        if(touch == null) {
            trace("null touch");
            return;
        }

        touch.getLocation(this, touchPoint);
        mark.x = touchPoint.x;
        mark.y = touchPoint.y;

        if(touch.phase == TouchPhase.BEGAN) {
            positionTouched(touchPoint);
        }
    }
}
}
