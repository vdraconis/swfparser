package swfparser.tags;


import flash.geom.Matrix;
import swfdata.datatags.RawClassSymbol;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagSymbolClass;
import swfdata.DisplayObjectData;
import swfdata.FrameData;
import swfdata.MovieClipData;
import swfdata.ShapeData;
import swfdata.SpriteData;
import swfdata.SwfdataInner;
import swfdata.Timeline;
import swfparser.SwfParserContext;


/**
	 * Тут получаем список ликейджев из библиотеки. Они идут парами characterId, linkageId
	 */
class TagProcessorSymbolClassLight extends TagProcessorBase
{
    public function new(context : SwfParserContext)
    {
        super(context);
    }
    
    override public function processTag(tag : SwfPackerTag) : Void
    {
        super.processTag(tag);
        
        var tagSymbolClass : SwfPackerTagSymbolClass = try cast(tag, SwfPackerTagSymbolClass) catch(e:Dynamic) null;
        var symbolsLength : Int = tagSymbolClass.length;
        
        for (i in 0...symbolsLength)
		{
            var currentLinkage : String = tagSymbolClass.linkageList[i];
            var currentCharacter : Int = tagSymbolClass.characterIdList[i];
            
            var displayObject : DisplayObjectData = context.library.getDisplayObject(currentCharacter);
            
            if (displayObject == null) 
            {
                trace("Error: no symbol for linkage(symbol=" + currentCharacter + ", linkage=" + currentLinkage + ")");
				continue;
            }
            
            displayObject.libraryLinkage = currentLinkage;
            context.library.addDisplayObjectByLinkage(cast(displayObject, SpriteData));
        }
    }
}
