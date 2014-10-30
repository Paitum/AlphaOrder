package alphaOrder {
import flash.utils.Dictionary;

public class AlphaOrderBoardModel extends BoardModel {
    // [letter:String] -> position:Number
    protected var tokenToPosition:Dictionary;
    // nextSolution is the index in the tokens vector for the next SOLUTION token
    protected var nextSolution:int = 0;

    public static function createBoardModelForLetters(letters:String, totalPositions:int):AlphaOrderBoardModel
    {
        var names:Vector.<String> = new Vector.<String>();
        for(var i:int = 0; i < letters.length; i++) {
            names.push(letters.charAt(i));
        }

        return new AlphaOrderBoardModel(names, totalPositions);
    }

    public function AlphaOrderBoardModel(tokens:Vector.<String>, totalPositions:int) {
        super(tokens, totalPositions);
    }

    public function setTotalPositions(totalPositions:int):void {
        setup(tokens,  totalPositions);
    }

    override protected function clear():void {
        super.clear();

        nextSolution = 0;
        tokenToPosition = new Dictionary();
    }

    override protected function populateBoard():void {
        // Fill the available positions
        while(hasEmptyPosition() && hasNextToken()) {
            var position:int = getNextEmptyPosition();
            var token:String = placeNextToken(position);
        }
    }

    public function getPastTokenCount():int {
        return nextSolution;
    }

    public function getPastToken(offset:uint):String {
        var position:int = nextSolution - offset;
        return position < 0 || position >= tokens.length ? null : tokens[position];
    }

    /**
     * Place the next token at the specified position.
     */
    protected function placeNextToken(index:int):String {
        if(!hasNextToken()) {
            throw new Error("No token available");
        }

        var positionNotFound:Boolean = true;
        // search the available positions for the index
        for(var i:int = 0; i < availablePositions.length; i++) {
            if(availablePositions[i] == index) {
                positionNotFound = false;
                availablePositions.splice(i, 1);
                break;
            }
        }

        if(positionNotFound) {
            throw new Error("Position at index[" + index + "] is unavailable");
        }

        var token:String = getNextToken();

        tokenToPosition[token] = index;
        positionToToken[index] = token;

        return token;
    }

    /**
     * Checks whether the supplied coordinate is the solution or not. The
     * solution token will be returned if correct, null otherwise
     *
     * @param   index   the index to test for solution
     * @return  the solution token if correct, null otherwise
     */
    public function isSolution(index:int):String {
        var token:String = getTokenAtPosition(index);
        var solution:String = getCurrentSolutionToken();
        return token == solution ? solution : null;
    }

    /**
     * Process the coordinate for solution, and increment the solution.
     *
     * @param   index   the index to process solution for
     * @return  if the coordinate contains the solution then return the token,
     *          otherwise return null.
     */
    public function processSolution(index:int):String {
        var solution:String = isSolution(index);

        if(solution != null) {
            nextSolution++;
            availablePositions.push(tokenToPosition[solution]);
            tokenToPosition[solution] = null;

            var nextToken:String = getNextToken();
            positionToToken[index] = nextToken;
            if(nextToken != null) tokenToPosition[nextToken] = index;
        }

        return solution;
    }

    [Inline]
    final public function hasEmptyPosition():Boolean {
        return availablePositions.length > 0;
    }

    public function getNextEmptyPosition():int {
        if(availablePositions.length == 0) {
            return -1;
        }

        var randomIndex:int = Math.random() * availablePositions.length;
        return availablePositions[randomIndex];
    }

    public function hasNextToken():Boolean {
        return nextToken < tokens.length;
    }

    protected function getNextToken():String {
        return nextToken >= tokens.length ? null : tokens[nextToken++];
    }

    public function getCurrentSolutionToken():String {
        return nextSolution >= tokens.length ? null : tokens[nextSolution];
    }

    /**
     * Get the column, row position of a token
     * @param token the token to find
     * @return  the position index of the token
     */
    public function getPosition(token:String):int {
        return tokenToPosition.hasOwnProperty(token) ? tokenToPosition[token] : -1;
    }

    public function isAtStart():Boolean {
        return nextSolution == 0;
    }

    public function get length():Number {
        throw new Error("length is not supported. Use getTokenCount");
    }
}
}
