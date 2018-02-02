package swfparser.tags;

import flash.errors.Error;

import flash.geom.Matrix;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagPlaceObject;
import swfdata.DisplayObjectData;
import swfdata.MovieClipData;
import swfdata.SpriteData;
import swfparser.SwfParserContext;

/**
	 * Обрабатывает установку дисплей обжекта в форейм для текущего спрайта
	 * Тут может быть объявлены такие важные вещи как
	 *  - placeMatrix - важно т.к это фактический трансформ и положеине объекта в данном кадре
	 *  - hasMoved - важно т.к если объект не двигался то нужно выставить ему трансформ с последнего зарегестрированого положения этого объекта на таймлайне
	 *  - colorTransform - это просто нужно хранить для корректной визуализации
	 *  - clipping - по клиппингу тут мы определяем какие слои маски, а какие маскируются
	 *  - ratio - рейт морфинга для морф шейпов
	 * 	И другие свойства объектов на таймлайне
	 * 
	 *  Суть в том что теги идут в таком виде
	 * 
	 *  define shape/define sprite     - дефайнятся спрайты и шейпы сначала шейпы которые используются в последующих спрайтах
	 *  define shape/define sprite
	 *  ..........................     - так идет пока не задефайнит все шейпы и спрайты
	 * 	define sprite                  - для объявленого спрайта далее опреедляется его контент, таймлайн, шейпы и т.д
	 *  {
	 *  	define sprite timeline     - далее опередялется таймлайн спрайта идут place/remove обжект теги и show frame. Те объекты что идут один за другим без изменения трансформа или айди должны быть одинаковы. Те что имеют разный трансформ должны быть клонирвоаны
	 *      place object               - ложим объекты текущего кадра
	 *      ......................
	 *      place object
	 *      show frame                 - переходи мна следующий кадр
	 *      ......................
	 *      end    sprite timeline
	 *  }
	 * 
	 *  define class symbol            - в самом конце идут симбол класс метки именно эти объекты нужно будет пост обработать
	 * 
	 *  Суть в том что нужно использовать взеде где можно клоны объектов, а это всгеда когда в кжадом кадре один за другим идут одинаковы объекты с одинаковым контентом
	 */
class TagProcessorPlaceObject extends TagProcessorBase
{
    
    public function new(context:SwfParserContext)
    {
        super(context);
    }
    
    private function getObject(id:Int, tag:SwfPackerTagPlaceObject, preveousTransform:Matrix):DisplayObjectData
    {
        /**
			 * Если в этом кадре ложатся несколько объектов с одинаковым айди но на разные глубины
			 * то нужно для них соотвественно смотреть где есть похожие объекты на таких же глубинах
			 * в предидущих кадрах, и нужно ли их клонировать.
			 */
        
        var isNeedClone:Bool = tag.hasMatrix || tag.hasColorTransform;
        var placedDO:DisplayObjectData;
        var depth:Int = tag.depth;
        
        var placedStorage:Map<Int, DisplayObjectData> = context.placedObjectsById[id];
        
        if (placedStorage == null) 
        {
            placedStorage = new Map<Int, DisplayObjectData>();
			context.placedObjectsById[id] = placedStorage;
        }
        
        if (isNeedClone) 
        {
            placedDO = context.library.getDisplayObject(id).clone();
        }
        else 
        {
            placedDO = placedStorage[depth];
            
            if (placedDO == null) 
            {
                placedDO = context.library.getDisplayObject(id).clone();
            }
            
            if (placedDO.transform != preveousTransform) 
                placedDO = placedDO.clone();
        }
        
        placedStorage[depth] = placedDO;
        
        if (placedDO == null) 
        {
            trace("Дисплей объект не определен в библиотеке символов " + id);
        }
        
        return placedDO;
    }
    
    private function getObjectFromLibrary(id:Int, hasMatrix:Bool):DisplayObjectData
    {
        var placedDO:DisplayObjectData = null;
        var prototype:DisplayObjectData;
        
        prototype = context.library.getDisplayObject(id);
        
        if (hasMatrix) 
        {
            if (prototype != null) 
            {
                placedDO = prototype.clone();
            }
            else 
            {
                
                trace("Дисплей объект не определен в библиотеке символов " + id);
            }
        }
        else 
        {
            placedDO = prototype;
        }
        
        return placedDO;
    }
    
    inline public function fillFromTag(currentDisplayObject:DisplayObjectData, tag:SwfPackerTagPlaceObject)
    {
        currentDisplayObject.depth = tag.depth;
        
        var isHaveTransform:Bool = currentDisplayObject.transform != null;
        
        if (tag.hasMatrix) 
        {
            if (isHaveTransform) 
                trace("##### HAVE MATRIX ALREADY");
            
            currentDisplayObject.setTransformMatrix(new Matrix(tag.a, tag.b, tag.c, tag.d, tag.tx, tag.ty));
        }
        else 
        {
            var preveousFrameDO:DisplayObjectData = context.placeObjectsMap[tag.depth];
            currentDisplayObject.setTransformMatrix(preveousFrameDO.transform);
        }
        
        if (tag.hasColorTransform) 
        {
            currentDisplayObject.colorTransform = tag.getColorTransformMatrix();
        }
        
        if (tag.hasName) 
            currentDisplayObject.name = tag.instanceName;
        
        currentDisplayObject.hasMoved = tag.hasMove;
    }
    
    override public function processTag(tag:SwfPackerTag)
    {
        super.processTag(tag);
        
        var tagPlaceObject:SwfPackerTagPlaceObject = cast tag;
        var currentDisplayObject:SpriteData = cast displayObjectContext.currentDisplayObject;
        
        //trace('\tplace object', tag['constructor'], tagPlaceObject.placeMode, currentDisplayObject != null);
        
        if (currentDisplayObject == null) 
            return;  //probably main time line  ;
        
        var placedDO:DisplayObjectData = null;
        
        var doAsMovieClip:MovieClipData = null;
		
		if (Std.is(currentDisplayObject, MovieClipData))
			doAsMovieClip = cast currentDisplayObject;
        
        //trace('place object', doAsMovieClip? doAsMovieClip.currentFrame:"noframe", tagPlaceObject.hasMatrix, tagPlaceObject.placeMode, tagPlaceObject.characterId, tagPlaceObject.instanceName, tagPlaceObject.depth);
        
        var hasMatrix:Bool = tagPlaceObject.hasMatrix;
        //trace('place do', tagPlaceObject.placeMode, tagPlaceObject.characterId, hasMatrix);
        
        var preveousFrameDO:DisplayObjectData;
        
        if (tagPlaceObject.placeMode == SwfPackerTagPlaceObject.PLACE_MODE_PLACE) 
        {
            //положили объект в таймлайн в первый раз скорее всего поэтому тут поидеи есть чарактер айди и можно взять его из библиотеки
            placedDO = getObjectFromLibrary(tagPlaceObject.characterId, hasMatrix);
            
            if (placedDO == null)                   //но его там может не быть т.к морфы не парсятся к примеру  
				return;
            
            fillFromTag(placedDO, tagPlaceObject);
            
            if (context.placeObjectsMap[placedDO.depth] != placedDO) 
            {
                context.placeObjectsMap[placedDO.depth] = placedDO;
            }
        }
        else if (tagPlaceObject.placeMode == SwfPackerTagPlaceObject.PLACE_MODE_REPLACE) 
        {
            preveousFrameDO = context.placeObjectsMap[tagPlaceObject.depth];
            
            if (preveousFrameDO == null)   //не положили его в плейсинге т.к не было в библиотеке  
            {
                trace("placing error");
                return;
            }
            
            placedDO = getObject(tagPlaceObject.characterId, tagPlaceObject, preveousFrameDO.transform);
            fillFromTag(placedDO, tagPlaceObject);
            
            if (!hasMatrix) 
            {
                placedDO.setTransformMatrix(preveousFrameDO.transform);
            }
            
            if (context.placeObjectsMap[placedDO.depth] != placedDO) 
            {
                context.placeObjectsMap[placedDO.depth] = placedDO;
            }
        }
        else if (tagPlaceObject.placeMode == SwfPackerTagPlaceObject.PLACE_MODE_MOVE) 
        {
            preveousFrameDO = context.placeObjectsMap[tagPlaceObject.depth];
            
            if (preveousFrameDO == null)   //не положили его в плейсинге т.к не было в библиотеке  
            {
                trace("placing error");
                return;
            }
            
            if (hasMatrix) 
            {
                placedDO = preveousFrameDO.clone();
                fillFromTag(placedDO, tagPlaceObject);
            }
            else 
            {
                placedDO = preveousFrameDO;
            }
            
            if (context.placeObjectsMap[placedDO.depth] != placedDO) 
            {
                context.placeObjectsMap[placedDO.depth] = placedDO;
            }
        }
        else 
			throw new Error("unkwnown place mode");
        
        if (placedDO != null) 
        {
            if (placedDO.transform == null) 
            {
                placedDO.setTransformMatrix(new Matrix());
            }
            
            placedDO.hasPlaced = true;
        }  //currentDisplayObject.depth = tag.clipDepth;    //}    //	currentDisplayObject.addMask(placedDO);    //	placedDO.maskData.maskId = tagPlaceObject.clipDepth;    //	placedDO.maskData.isMask = true;    //{    //if (tagPlaceObject.hasClipDepth)  
        
        if (tagPlaceObject.hasClipDepth) 
        {
            placedDO.isMask = true;
            placedDO.clipDepth = tagPlaceObject.clipDepth;
        }  //currentDisplayObject.getLayerByDepth(tagPlaceObject.depth).setClipAndDepthData(tagPlaceObject.hasClipDepth, tagPlaceObject.clipDepth);    //}    //	placedDO.isMask = tagPlaceObject.hasClipDepth;    //	trace('set do mask status', tagPlaceObject.hasClipDepth);    //{    //if (!placedDO.isMask)  
    }
}
