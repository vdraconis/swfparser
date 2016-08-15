package swfparser.tags;



import flash.utils.Dictionary;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagShowFrame;
import swfdata.DisplayObjectContainer;
import swfdata.DisplayObjectData;
import swfdata.IDisplayObjectContainer;
import swfdata.MovieClipData;
import swfdata.SpriteData;
import swfdata.SwfdataInner;
import swfparser.DisplayObjectContext;
import swfparser.SwfParserContext;



/**
	 * Определяет показ кадра т.е последующие теги будут уже относится к следующему кадру
	 * тут нужно обработать переход между кадрами т.е если объекты не двигались в этом кадре и 
	 * не были получены их новые плейсы нжуно выставить им последнее значение в трансформ которое было 
	 * зарегестрировано в предидущих кадрах
	 */
class TagProcessorShowFrame extends TagProcessorBase
{
    
    public function new(context : SwfParserContext)
    {
        super(context);
    }
    
	@:access(swfdata)
    override public function processTag(tag : SwfPackerTag) : Void
    {
        var currentDisplayObject : SpriteData = displayObjectContext.currentDisplayObject;
        
        if (currentDisplayObject == null) 
            return;
        
        var tagShowFrame:SwfPackerTagShowFrame = cast tag;
        
        var container : DisplayObjectContainer = displayObjectContext.currentContainer;
        //trace('show frame', context.displayObjectContext.currentDisplayObjectAsMovieClip? context.displayObjectContext.currentDisplayObjectAsMovieClip.currentFrame:"");
        //if (container.displayObjectsCount > 0)
        //{
        var currentDisplayList : Array<DisplayObjectData> = displayObjectContext.currentDisplayList;
        var index:Int = container.displayObjectsPlacedCount;
        
        var placeObjectsMap:Map<Int, DisplayObjectData> = context.placeObjectsMap;
        
        for (objectToPlace in placeObjectsMap)
        {
            currentDisplayList[index++] = objectToPlace;
        }
        
        container.displayObjectsPlacedCount = index;
        
        if (index > 1) 
            currentDisplayList.sort(sortOnDepth);
        
        currentDisplayObject.updateMasks();
        //}
        
        displayObjectContext.nextFrame();
    }
	
    inline public static function sortOnDepth(a : DisplayObjectData, b : DisplayObjectData) : Int
    {
        if (a.depth > b.depth) 
            return 1
        //else if (a.depth < b.depth)
        //	return -1;
        else 
			return -1;
    }
}
