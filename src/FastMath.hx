

class FastMath
{
    /**
		 * Return base logarifm of value e.g log(512, 2) Log2(512) - 9
		 * @param	value
		 * @param	base
		 * @return
		 */
    @:meta(Inline())

    public static function log(value:Float, base:Float):Float
    {
        return Math.log(value) / Math.log(base);
    }
    
    @:meta(Inline())

    public static function convertToRadian(angle:Float):Float
    {
        return angle * Math.PI / 180;
    }
    
    @:meta(Inline())

    public static function convertToDegree(angle:Float):Float
    {
        return 180 * angle / Math.PI;
    }
    
    @:meta(Inline())

    public static function uintMin(a:UInt, b:UInt):UInt
    {
        return a < b ? a:b;
    }
    
    public static function angle(x1:Float, y1:Float, x2:Float, y2:Float):Float
    {
        x1 = x1 - x2;
        y1 = y1 - y2;
        
        return Math.atan2(x1, y1);
    }

    public function new()
    {
    }
}

