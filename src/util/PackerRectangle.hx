////////////////////////////////////////////////////////////////////////////////
//
//  © 2014 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////
package util;

import flash.errors.Error;

import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
	 * @author                    Obi
	 * @langversion                3.0
	 * @date                    27.11.2014
	 */
class PackerRectangle
{
    
    
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    /**
		 * @private
		 */
    private static var availableInstance:PackerRectangle;
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------
    
    public static function get(x:Int, y:Int, width:Int, height:Int, id:Int = 0, bitmapData:BitmapData = null, originX:Int = 0, originY:Int = 0, pivotX:Float = 0, pivotY:Float = 0):PackerRectangle
    {
        var instance:PackerRectangle = PackerRectangle.availableInstance;
        
        if (instance != null) 
        {
            PackerRectangle.availableInstance = instance.nextInstance;
            instance.nextInstance = null;
            instance.disposed = false;
        }
        else 
        {
            instance = new PackerRectangle();
        }
        
        
        
        instance.x = x;
        instance.y = y;
        instance.width = width;
        instance.height = height;
        instance.right = x + width;
        instance.bottom = y + height;
        instance.id = id;
        instance.bitmapData = bitmapData;
        instance.originX = originX;
        instance.originY = originY;
        instance.pivotX = pivotX;
        instance.pivotY = pivotY;
        
        return instance;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function new()
    {
        super();
    }
    
    public var next:PackerRectangle;
    
    public var previous:PackerRectangle;
    
    public var nextInstance:PackerRectangle;
    
    public var scaleX:Float = 1;
    public var scaleY:Float = 1;
    
    public var x:Int = 0;
    
    public var y:Int = 0;
    
    public var width:Int = 0;
    
    public var height:Int = 0;
    
    public var right:Int = 0;
    
    public var bottom:Int = 0;
    
    public var id:Int;
    
    public var bitmapData:BitmapData;
    
    public var originX:Int;
    
    public var originY:Int;
    
    public var pivotX:Float;
    
    public var pivotY:Float;
    
    public var padding:Int = 0;
    
    private var disposed:Bool = false;
    
    //--------------------------------------------------------------------------
    //
    //  Public methods
    //
    //--------------------------------------------------------------------------
    
    public function set(x:Int, y:Int, width:Int, height:Int):Void{
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.right = x + width;
        this.bottom = y + height;
    }
    
    public function dispose():Void{
        this.next = null;
        this.previous = null;
        this.nextInstance = PackerRectangle.availableInstance;
        PackerRectangle.availableInstance = this;
        this.bitmapData = null;
        
        if (disposed) 
            throw new Error("try to dispose alrady disposed object");
        
        disposed = true;
    }
    
    public function setPadding(p_value:Int):Void{
        this.x -= p_value - this.padding;
        this.y -= p_value - this.padding;
        this.width += (p_value - this.padding) * 2;
        this.height += (p_value - this.padding) * 2;
        this.right += p_value - this.padding;
        this.bottom += p_value - this.padding;
        this.padding = p_value;
    }
    
    public function getRect():Rectangle{
        return new Rectangle(this.x, this.y, this.width, this.height);
    }
}

