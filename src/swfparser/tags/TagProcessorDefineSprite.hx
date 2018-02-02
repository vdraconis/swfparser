package swfparser.tags;


import flash.geom.Matrix;
import flash.utils.Dictionary;
import swfdata.DisplayObjectData;

import swfdata.DisplayObjectTypes;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagDefineSprite;

import swfdata.FrameData;
import swfdata.MovieClipData;
import swfdata.SpriteData;
import swfparser.ISWFDataParser;
import swfparser.SwfParserContext;

/* 
	* Обрабатывает объявление спрайта
	* Структура спрайта такова что спрайт имеет таймлайн, слои
	* Слои могут быть масками или маскирвоатся другими слоями
	* Таймлайн содержит фрейм-дату которая содержит объекты данного кадра
	* Объекты кадра содержут в себе инофрмацию по пренадлежности к лееру, внутренней структуре если это спрайт
	* или же ссылку на шейп дату или текстуру если это шейп
*/
class TagProcessorDefineSprite extends TagProcessorBase
{
    private var swfDataParser:ISWFDataParser;
    
    public static var spritesDefined:Int = 0;
    
    private static var defaultMatrix:Matrix = new Matrix();
    
    public function new(context:SwfParserContext, swfDataParser:ISWFDataParser)
    {
        super(context);
        this.swfDataParser = swfDataParser;
    }
    
    override public function processTag(tag:SwfPackerTag):Void
    {
        super.processTag(tag);
        
        spritesDefined++;
        
        var tagDefineSprite:SwfPackerTagDefineSprite = cast tag;
        var characterId:Int = tagDefineSprite.characterId;
        var frameCount:Int = tagDefineSprite.frameCount;
        
        context.placeObjectsMap = new Map<Int, DisplayObjectData>();
        context.placedObjectsById = new Map<Int, Map<Int, DisplayObjectData>>();
        
        var currentDisplayObject:SpriteData;
        
        if (frameCount > 1) 
        {
            var currentDisplayObjectAsMovieClip:MovieClipData = new MovieClipData(characterId, frameCount);
            currentDisplayObject = currentDisplayObjectAsMovieClip;
            
            for (i in 0...frameCount)
			{    
                //var frame:RawFrameData = tagDefineSprite.frames[i];
                //var frameData:FrameData = new FrameData(frame.frameIndex, frame.frameLabel, frame.numChildren);//на каждый фрейм создается фрейм дата
                
                var frameData:FrameData = tagDefineSprite.frames[i];
                //trace('define sprite', characterId, i, frameData.displayObjects.length);
                currentDisplayObjectAsMovieClip.addFrame(frameData);
            }
        }
        else 
			currentDisplayObject = new SpriteData(characterId, DisplayObjectTypes.SPRITE_TYPE, true, tagDefineSprite.frames[0].numChildren);
        
        context.library.addDisplayObject(currentDisplayObject);
        displayObjectContext.setCurrentDisplayObject(currentDisplayObject);
        
        //TODO: KAKOITOBAG
        if (tagDefineSprite.tags != null) 
            swfDataParser.processDisplayObject(tagDefineSprite.tags);
        
        if (currentDisplayObject.transform == null) 
            currentDisplayObject.setTransformMatrix(new Matrix());  //because that object not on time line  ;
        
        displayObjectContext.setCurrentDisplayObject(null);
    }
}
