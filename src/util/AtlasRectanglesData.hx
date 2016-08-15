package util;

import util.PackerRectangle;

class AtlasRectanglesData
{
    public var atlasIndex : Int;
    public var rectangles : Array<PackerRectangle> = new Array<PackerRectangle>();
    
    public var width : Float = 1;
    public var height : Float = 1;
    
    public function new(atlasIndex : Int)
    {
        this.atlasIndex = atlasIndex;
    }
    
    public function clear() : Void
    {
        
        width = 1;
        height = 1;
        atlasIndex = 0;
        
        clearRects();
    }
    
    public function clearRects() : Void
    {
        //for (var i:int = 0; i < rectangles.length; i++)
        //{
        //	rectangles[i].dispose();
        //}
        
        rectangles = null;
    }
}
