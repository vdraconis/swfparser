package swfparser;


import swfdata.datatags.SwfPackerTag;
import swfdata.ShapeLibrary;
import swfdata.SymbolsLibrary;
import swfparser.tags.TagProcessorBase;
import swfparser.tags.TagProcessorDefineSprite;
import swfparser.tags.TagProcessorEnd;
import swfparser.tags.TagProcessorPlaceObject;
import swfparser.tags.TagProcessorRemoveObject;
import swfparser.tags.TagProcessorShowFrame;
import swfparser.tags.TagProcessorSymbolClassLight;

class SwfParserLight implements ISWFDataParser
{
    public var context(get, set) : SwfParserContext;

    private var _context : SwfParserContext;
    private var tagsProcessors : Dynamic;
    private var isUseEndTag : Bool;
    
    public function new(isUseEndTag : Bool = false)
    {
        this.isUseEndTag = isUseEndTag;
        initialize();
    }
    
    private function initialize() : Void
    {
        context = new SwfParserContext();
        clear();
        
        makeTagProcessorsMap();
    }
    
    public function clear(callDestroy : Bool = true) : Void
    {
        if (context.library == null) 
            context.library = new SymbolsLibrary()
        else 
        context.library.clear(callDestroy);
        
        if (context.shapeLibrary == null) 
            context.shapeLibrary = new ShapeLibrary()
        else 
        context.shapeLibrary.clear(callDestroy);
    }
    
    private function makeTagProcessorsMap() : Void
    {
        tagsProcessors = { };
        
        tagsProcessors[39] = new TagProcessorDefineSprite(context, this);
        
        if (isUseEndTag) 
            tagsProcessors[0] = new TagProcessorEnd(context);
        
        var tagProcessorRemoveObject:TagProcessorRemoveObject = new TagProcessorRemoveObject(context);
        tagsProcessors[5] = tagProcessorRemoveObject;
        
        var tagProcessorPlaceObject : TagProcessorPlaceObject = new TagProcessorPlaceObject(context);
        tagsProcessors[4] = tagProcessorPlaceObject;
        
        tagsProcessors[1] = new TagProcessorShowFrame(context);
        
        tagsProcessors[76] = new TagProcessorSymbolClassLight(context);
    }
    
    public function processDisplayObject(tags : Array<SwfPackerTag>) : Void
    {
        for (i in 0...tags.length)
		{
            var currentTag:SwfPackerTag = tags[i];
			
            var tagProcessor:TagProcessorBase = tagsProcessors[currentTag.type];
            
            if (tagProcessor != null) 
                tagProcessor.processTag(currentTag)
            else 
				trace("no processor for", currentTag);
        }
    }
    
    private function get_context() : SwfParserContext
    {
        return _context;
    }
    
    private function set_context(value : SwfParserContext) : SwfParserContext
    {
        _context = value;
        return value;
    }
}

