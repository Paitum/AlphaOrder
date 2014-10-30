package alphaOrder {

public interface IBoardModel {
    /**
     * Resets the model to starting state
     */
    function reset():void;

    function getState():int;

    /**
     * Get the total number of tokens
     *
     * @return  the token count
     * @see getToken
     */
    function getTokenCount():int;

    /**
     * Get a token from the list of tokens (not from the board)
     *
     * @param tokenIndex    the token index
     * @return  the token
     * @see getTokenCount
     */
    function getToken(tokenIndex:int):String;

    function getTokenAtPosition(position:int):String;

    function getTotalPositions():int;
}
}
