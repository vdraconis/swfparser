package swfparser.tags;


import flash.geom.Matrix;
import swfdata.datatags.SwfPackerTag;
import swfparser.SwfParserContext;

class TagProcessorEnd extends TagProcessorBase
{
    
    
    public function new(context:SwfParserContext)
    {
        super(context);
    }
    
    override public function processTag(tag:SwfPackerTag):Void
    {
        super.processTag(tag);
        
        if (displayObjectContext.currentDisplayObject == null) 
            return;
        
        if (displayObjectContext.currentDisplayObject.transform == null) 
            displayObjectContext.currentDisplayObject.setTransformMatrix(new Matrix());  //because that object not on time line  ;
        
        displayObjectContext.setCurrentDisplayObject(null);
    }
}
