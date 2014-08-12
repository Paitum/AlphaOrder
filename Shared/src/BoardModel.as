package {
import flash.geom.Point;
import flash.utils.Dictionary;

public class BoardModel {
    private var columns:int;
    private var rows:int;
    protected var tokens:Vector.<String>;

    protected var nextSolution:int = 0;
    protected var nextToken:int = 0;
    // [letter:String] -> position:Point
    private var letterToPosition:Dictionary;
    // [r:int][c:int] -> letter:String
    private var positionToToken:Vector.<Vector.<String>>;
    private var availablePositions:Vector.<Point>;

    public static function createBoardModelForLetters(
            rows:int, columns:int, letters:String):BoardModel
    {
        var names:Vector.<String> = new Vector.<String>();
        for(var i:int = 0; i < letters.length; i++) {
            names.push(letters.charAt(i));
        }

        return new BoardModel(rows, columns, names);
    }

    public function BoardModel(rows:int, columns:int, tokens:Vector.<String>) {
        this.columns = columns;
        this.rows = rows;
        this.tokens = tokens;

        var r:int, c:int;

        positionToToken = new Vector.<Vector.<String>>();
        for(r = 0; r < rows; r++) {
            positionToToken[r] = new Vector.<String>();
        }

        letterToPosition = new Dictionary();

        availablePositions = new Vector.<Point>();
        for(r = 0; r < rows; r++) {
            for(c = 0; c < columns; c++) {
                availablePositions.push(new Point(c, r));
            }
        }

        reset();
    }

    [Inline]
    final public function getColumns():int {
        return columns;
    }

    [Inline]
    final public function getRows():int {
        return rows;
    }

    public function reset():void {
        nextToken = 0;
        nextSolution = 0;

        for(var r:int = 0; r < rows; r++) {
            positionToToken[r] = new Vector.<String>();
            for(var c:int = 0; c < columns; c++) {
                positionToToken[r][c] = null;
            }
        }

        for(var i:int = 0; i < tokens.length; i++) {
            var point:Point = letterToPosition[tokens[i]];
            if(point != null) {
                availablePositions.push(point);
            }
            letterToPosition[tokens[i]] = null;
        }
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
    final public function setTokenOnBoard(row:int, column:int, name:String):void {
        positionToToken[row][column] = name;
    }

    [Inline]
    final public function getTokenOnBoard(row:int, column:int):String {
        return positionToToken[row][column];
    }

    /**
     * Place the next token at the specified position.
     *
     * @param row       the row of the suspected solution
     * @param column    the column of the suspected solution
     * @return
     */
    public function placeNextToken(row:int, column:int):String {
        if(!hasNextToken()) {
            throw new Error("No token available");
        }

        var position:Point = null;
        for(var i:int = 0; i < availablePositions.length; i++) {
            if(availablePositions[i].x == column && availablePositions[i].y == row) {
                position = availablePositions[i];
                availablePositions.splice(i, 1);
                break;
            }
        }

        if(position == null) {
            throw new Error("Position at column[" + column + "] row[ " + row + "] was unavailable");
        }

        var token:String = tokens[nextToken];
        nextToken++;

        letterToPosition[token] = position;
        positionToToken[position.y][position.x] = token;

        return token;
    }

    /**
     * Checks whether the supplied coordinate is the solution or not. The
     * solution token will be returned if correct, null otherwise
     *
     * @param row       the row of the suspected solution
     * @param column    the column of the suspected solution
     * @return  the solution token if correct, null otherwise
     */
    public function isSolution(row:int, column:int):String {
        var token:String = getTokenOnBoard(row, column);
        var solution:String = getCurrentSolutionToken();
        return token == solution ? solution : null;
    }

    /**
     * Process the coordinate for solution, and increment the solution.
     *
     * @param row       the row of the suspected solution
     * @param column    the column of the suspected solution
     * @return  if the coordinate contains the solution then return the token,
     *          otherwise return null.
     */
    public function processSolution(row:int, column:int):String {
        var solution:String = isSolution(row, column);

        if(solution != null) {
            nextSolution++;
            availablePositions.push(letterToPosition[solution]);
            letterToPosition[solution] = null;
            positionToToken[row][column] = null;
        }

        return solution;
    }

    public function hasEmptyPosition():Boolean {
        return availablePositions.length > 0;
    }

    public function getNextEmptyPosition():Point {
        if(availablePositions.length == 0) {
            return null;
        }

        var randomIndex:int = Math.random() * availablePositions.length;
        return availablePositions[randomIndex];
    }

    public function hasNextToken():Boolean {
        return nextToken < tokens.length;
    }

    public function getNextToken():String {
        return nextToken >= tokens.length ? null : tokens[nextToken++];
    }

    public function getCurrentSolutionToken():String {
        return nextSolution >= tokens.length ? null : tokens[nextSolution];
    }

    public function goToNextSolutionToken():void {
        if(nextSolution < tokens.length) {
            nextSolution++;
        }
    }

    public function getPosition(token:String):Point {
        return letterToPosition[token];
    }
}
}
