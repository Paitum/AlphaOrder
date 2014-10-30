package alphaOrder {

import flash.utils.Dictionary;

/**
 * BoardModel represents the state of a Board and should always be in a valid state
 */
public class BoardModel implements IBoardModel {
    protected var state:int;
    protected var tokens:Vector.<String>;
    // nextToken is the index in the tokens vector for the next UNUSED token
    protected var nextToken:int = 0;
    // index:int -> letter:String
    protected var positionToToken:Vector.<String> = new Vector.<String>();
    // stack of positions, index has no meaning, only values
    protected var availablePositions:Vector.<int> = new Vector.<int>();
    protected var totalPositions:int;

    public static const STATE_ACTIVE:int = 0;
    public static const STATE_STOPPED:int = 1;

    public function BoardModel(tokens:Vector.<String>, totalPositions:int) {
        setup(tokens, totalPositions);
    }

    /**
     * Setup the model
     *
     * @param tokens    the token vector
     * @param totalPositions    the total positions available on the board
     */
    public function setup(tokens:Vector.<String>, totalPositions:int):void {
        this.tokens = tokens;
        this.totalPositions = totalPositions;
        reset();
    }

    public function reset():void {
        state = STATE_ACTIVE;
        clear();
        populateBoard();
    }

    /**
     * Clears the model back to an unpopulated state
     */
    protected function clear():void {
        var i:int;

        nextToken = 0;
        positionToToken.length = totalPositions;
        availablePositions.length = totalPositions;

        for(i = 0; i < totalPositions; i++) {
            positionToToken[i] = null;
            availablePositions[i] = i;
        }
    }

    /**
     * Populate the positions with the tokens. This method must be override
     * and super not called.
     */
    protected function populateBoard():void {
        throw new Error("subclass must override");
    }

    public function getState():int {
        return state;
    }

    [Inline]
    final public function getTotalPositions():int {
        return totalPositions;
    }

    [Inline]
    final public function getTokenCount():int {
        return tokens.length;
    }

    [Inline]
    final public function getToken(position:int):String {
        return position < tokens.length ? tokens[position] : null;
    }

    [Inline]
    final public function setTokenOnBoard(index:int, name:String):void {
        positionToToken[index] = name;
    }

    [Inline]
    final public function getTokenAtPosition(position:int):String {
        return positionToToken[position];
    }
}
}
