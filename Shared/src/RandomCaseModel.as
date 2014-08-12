package {

public class RandomCaseModel extends BoardModel {

    private var original:Vector.<String>;

    public static function createBoardModelForLetters(
            rows:int, columns:int, letters:String):BoardModel
    {
        var names:Vector.<String> = new Vector.<String>();
        for(var i:int = 0; i < letters.length; i++) {
            names.push(letters.charAt(i));
        }

        return new RandomCaseModel(rows, columns, names);
    }

    public function RandomCaseModel(rows:int, columns:int, original:Vector.<String>) {
        this.original = original;
        var tokens:Vector.<String> = randomizeCase();
        super(rows, columns, tokens);
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

    override public function reset():void {
        super.reset();
        // Allow superclass to reset first before changing the tokens
        randomizeCase(tokens);
    }
}
}
