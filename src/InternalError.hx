
/**
 * Class for internal_error
 */
@:final class ClassForInternalError
{
    
    public function internal_error() : Void
    {
        trace("Error:", args);
        printError.apply(null, args);
    }

    public function new()
    {
    }
}

