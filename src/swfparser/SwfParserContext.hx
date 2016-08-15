package swfparser;


import swfdata.atlas.AtlasDrawer;
import swfdata.DisplayObjectData;
import swfdata.IDisplayObjectContainer;
import swfdata.ShapeLibrary;
import swfdata.SymbolsLibrary;
import swfdata.SpriteData;

class SwfParserContext
{
    public var atlasDrawer : AtlasDrawer;
    public var library : SymbolsLibrary;
    public var shapeLibrary : ShapeLibrary;
    
    public var placeObjectsMap : Map<Int, DisplayObjectData> = new Map<Int, DisplayObjectData>();
    public var placedObjectsById : Map<Int, Map<Int, DisplayObjectData>> = new Map<Int, Map<Int, DisplayObjectData>>();
    
    //public var placeObjectsList:Vector.<DisplayObjectData> = new Vector.<DisplayObjectData>();
    
    public var displayObjectContext : DisplayObjectContext = new DisplayObjectContext();
    
    public var onlyTagReport : Bool = false;
    
    public function new()
    {
        
        
    }
    
    public function clear() : Void
    {
        if (displayObjectContext != null) 
            displayObjectContext.clear();
        
        for (dObject in placeObjectsMap)
			dObject.destroy();
        
        placeObjectsMap = new Map<Int, DisplayObjectData>();
        placedObjectsById = new Map<Int, Map<Int, DisplayObjectData>>();
    }
}
