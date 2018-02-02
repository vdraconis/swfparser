package swfparser.tags;


import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagRemoveObject;
import swfdata.SpriteData;
import swfparser.SwfParserContext;

class TagProcessorRemoveObject extends TagProcessorBase
{
    
    public function new(context:SwfParserContext)
    {
        super(context);
    }
    
    override public function processTag(tag:SwfPackerTag):Void
    {
        super.processTag(tag);
        
        var tagRemoveObject:SwfPackerTagRemoveObject = cast tag;
        //var currentDisplayObject:SpriteData = displayObjectContext.currentDisplayObject;
		
		context.placeObjectsMap.remove(tagRemoveObject.depth);

    }
}
