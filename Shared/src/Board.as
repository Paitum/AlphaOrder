package {
import flash.geom.Point;
import flash.utils.Dictionary;

import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;
import starling.text.TextField;

public class Board extends Sprite {
    private var divisions:int;
    private var alphabet:String;
    // Uppercase and Lowercase Text Sprites
    private var letterSprites:Dictionary;
    protected var nextPosition:int = 0;
    // [letter:String] -> position:Point
    private var letterToPosition:Dictionary;
    // [r:int][c:int] -> letter:String
    private var positionToLetter:Vector.<Vector.<String>>;

    // cache
    private var positionVector:Vector.<Point> = new Vector.<Point>();
    public function Board(divisions:int, alphabet:String) {
        this.divisions = divisions;
        this.alphabet = alphabet;

        letterSprites = new Dictionary();

        positionToLetter = new Vector.<Vector.<String>>();
        for(var r:int = 0; r < divisions; r++) {
            positionToLetter[r] = new Vector.<String>();
            for(var c:int = 0; c < divisions; c++) {
                positionToLetter[r][c] = null;
            }
        }

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
    }

    public function reset():void {
        nextPosition = 0;
        clear();
        populateBoard();
    }

    protected function clear():void {
        for(var r:int = 0; r < divisions; r++) {
            for(var c:int = 0; c < divisions; c++) {
                positionToLetter[r][c] = null;
            }
        }
trace("clear");
        var length:int = alphabet.length;
        for(var i:int = 0; i < length; i++) {
            var letter:String = alphabet.charAt(i);
            removeChild(letterSprites[letter]);
            letterToPosition[letter].setTo(-1, -1);
        }
    }

    override public function get width():Number {
        return divisions;
    }

    override public function get height():Number {
        return divisions;
    }

    private function handleAddedToStage(event:Event):void {
        var quad:Quad;

        for(var r:int = 0; r < divisions; r++) {
            for(var c:int = 0; c < divisions; c++) {
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
            trace(letterSprites[letter].textBounds);
            letterSprites[letter].hAlign = "center";
            letterSprites[letter].vAlign = "center";
            letterSprites[letter].pivotX = letterSprites[letter].width / 2;
            letterSprites[letter].pivotY = letterSprites[letter].height / 2;
            letterSprites[letter].x = int(Math.random() * divisions) + 0.5;
            letterSprites[letter].y = int(Math.random() * divisions) + 0.5;
//            addChild(letterSprites[letter]);
            letterToPosition[letter] = new Point(-1, -1);
        }

        populateBoard();
    }

    protected function populateBoard():void {
        while(hasEmptyPosition()) {
            addLetter();
        }
    }

    protected function addLetter():void {
        var position:Point = getRandomEmptyPosition();

        if(position != null) {
            var letter:String = getLetter(nextPosition);
            nextPosition++;

            letterToPosition[letter].copyFrom(position);
            positionToLetter[position.x][position.y] = letter;

            letterSprites[letter].x = position.x + 0.5;
            letterSprites[letter].y = position.y + 0.5;
//trace("addLetter[" + letter + "] to position[" + position + "] field[" + letterSprites[letter].text + "]");
            addChild(letterSprites[letter]);
        }
    }

    protected function getLetter(position:int):String {
        // Natural Order
        return alphabet.charAt(position);
    }

    protected function getRandomEmptyPosition():Point {

        // TODO Ugh, implement an intelligent randomization
        var length:int = 0;
        positionVector.length = 0;
        for(var r:int = 0; r < divisions; r++) {
            for(var c:int = 0; c < divisions; c++) {
                if(positionToLetter[r][c] == null) {
                    if(length >= positionVector.length) {
                        positionVector.push(new Point(r, c));
                    } else {
                        positionVector[length].setTo(r, c);
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

    private static function randomColor():uint {
        return uint(Math.random() * 255) << 16 | uint(Math.random() * 255) << 8 | uint(Math.random() * 255);
    }
}
}
