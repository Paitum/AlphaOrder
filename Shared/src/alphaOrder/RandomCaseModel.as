package alphaOrder {

public class RandomCaseModel extends AlphaOrderBoardModel {

    private var original:Vector.<String>;

    public static function createBoardModelForLetters(letters:String, totalPositions:int):AlphaOrderBoardModel
    {
        var names:Vector.<String> = new Vector.<String>();
        for(var i:int = 0; i < letters.length; i++) {
            names.push(letters.charAt(i));
        }

        return new RandomCaseModel(names, totalPositions);
    }

    public function RandomCaseModel(original:Vector.<String>, totalPositions:int) {
        this.original = original;
        var tokens:Vector.<String> = randomizeCase();
        super(tokens, totalPositions);
    }

    private function randomizeCase(result:Vector.<String> = null):Vector.<String> {
        var length:int = original.length;
        if(result == null) result = new Vector.<String>(length);
        for(var i:int = 0; i < length; i++) {
            result[i] = Math.random() > 0.5 ?
                    original[i].toUpperCase() :
                    original[i].toLowerCase();
        }

        return result;
    }

    override protected function clear():void {
        super.clear();
        // Allow superclass to reset first before changing the tokens
        randomizeCase(tokens);
    }
}
}
