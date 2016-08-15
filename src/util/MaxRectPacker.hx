////////////////////////////////////////////////////////////////////////////////
//
//  © 2014 CrazyPanda LLC
//
////////////////////////////////////////////////////////////////////////////////
package util;

import util.PackerRectangle;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
	 * @author                    Obi
	 * @langversion                3.0
	 * @date                    27.11.2014
	 */
class MaxRectPacker
{
    //--------------------------------------------------------------------------
    //
    //  Class variables
    //
    //--------------------------------------------------------------------------
    
    public static var BOTTOM_LEFT : Int = 0;
    
    public static var SHORT_SIDE_FIT : Int = 1;
    
    public static var LONG_SIDE_FIT : Int = 2;
    
    public static var AREA_FIT : Int = 3;
    
    public static var SORT_NONE : Int = 0;
    
    public static var SORT_ASCENDING : Int = 1;
    
    public static var SORT_DESCENDING : Int = 2;
    
    public static var nonValidTextureSizePrecision : Int = 5;
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    public function new(maxWidth : Int = 2048, maxHeight : Int = 2048, autoExpand : Bool = true, heuristics : Int = 0)
    {
        this._maxWidth = maxWidth;
        this._maxHeight = maxHeight;
        this._autoExpand = autoExpand;
        //this.clear(atlasDatas[0]);
        this._newBoundingArea = PackerRectangle.get(0, 0, 0, 0);
        this._heuristics = heuristics;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
		 * @private
		 */
    private var _heuristics : Int = 0;
    
    /**
		 * @private
		 */
    private var _firstAvailableArea : PackerRectangle;
    
    /**
		 * @private
		 */
    private var _lastAvailableArea : PackerRectangle;
    
    /**
		 * @private
		 */
    private var _firstNewArea : PackerRectangle;
    
    /**
		 * @private
		 */
    private var _lastNewArea : PackerRectangle;
    
    /**
		 * @private
		 */
    private var _newBoundingArea : PackerRectangle;
    
    /**
		 * @private
		 */
    private var _negativeArea : PackerRectangle;
    
    /**
		 * @private
		 */
    private var _maxWidth : Int;
    
    /**
		 * @private
		 */
    private var _maxHeight : Int;
    
    /**
		 * @private
		 */
    private var _autoExpand : Bool = false;
    
    /**
		 * @private
		 */
    private var _sortOnExpand : Int = 2;
    
    /**
		 * @private
		 */
    private var _forceValidTextureSizeOnExpand : Bool = true;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    /**
		 * @private
		 */
    
    private var totalPacketRectangles : Int = 0;
    public var atlasUsed : Int = 0;
    public var atlasDatas : Array<AtlasRectanglesData>;  //atlas buffer  
    
    
    public function clearData() : Void
    {
        totalPacketRectangles = 0;
        atlasUsed = 0;
        alreadyPackedMap = { };
        
        //if (_negativeArea)
        //	_negativeArea.dispose();
        
        _negativeArea = null;
        
        //if (_newBoundingArea)
        //	_newBoundingArea.dispose();
        
        _newBoundingArea = PackerRectangle.get(0, 0, 0, 0, 0);
        
        //if (_lastNewArea)
        //	_lastNewArea.dispose();
        
        _lastNewArea = null;
        
        //if (_firstNewArea)
        //	_firstNewArea.dispose();
        
        _firstNewArea = null;
        
        //if (_lastAvailableArea)
        //	_lastAvailableArea.dispose();
        
        _lastAvailableArea = null;
        
        //if (_firstAvailableArea)
        //	_firstAvailableArea.dispose();
        
        _firstAvailableArea = null;
        
        if (atlasDatas != null) 
        {
            for (i in 0...atlasDatas.length){atlasDatas[i].clear();
            }
        }  //else  
        
        atlasDatas = [new AtlasRectanglesData(0)];
    }
    //--------------------------------------------------------------------------
    //
    //  Public methods
    //
    //--------------------------------------------------------------------------
    
    //public function packRectangle(rect:PackerRectangle, padding:int = 0, forceValidTextureSize:Boolean = true):Boolean {
    //	var success:Boolean = this.addRectangle(rect, padding);
    //	if (!success && this._autoExpand) {
    //		var storedRectangles:Vector.<PackerRectangle> = this.rectangles;
    //		storedRectangles.push(rect);
    //		this.clear();
    //		trace('pack');
    //		trace("packed#", this.packRectangles(storedRectangles, padding, this._sortOnExpand));
    //		success = true;
    ///	}
    //	return success;
    //}
    
    private var alreadyPackedMap : Dynamic;
    
    public function packRectangles(rectangles : Array<PackerRectangle>, padding : Int = 0, sort : Int = 2) : Bool
    {
        
        if (sort != 0) 
            rectangles.sort((((sort == 1)) ? this.sortOnHeightAscending : this.sortOnHeightDescending));
        
        totalPacketRectangles = 0;
        atlasUsed = 0;
        
        while (rectangles.length > totalPacketRectangles)
        {
            var count : Int = rectangles.length;
            var success : Bool = true;
            
            var failedRectangles : Array<PackerRectangle> = new Array<PackerRectangle>();
            
            var currentAtlasData : AtlasRectanglesData = atlasDatas[atlasUsed];
            atlasUsed++;
            
            var _g : Int = 0;
            while (_g < count)
            {
                var i : Int = _g++;
                var rect : PackerRectangle = rectangles[i];
                
                if (alreadyPackedMap[rect.id] != null) 
                    continue;
                
                var s : Bool = this.addRectangle(rect, padding, currentAtlasData);
                
                if (!s && this._autoExpand) 
                    failedRectangles.push(rectangles[i]);
                
                success = success && s;
            }
            
            if (!success && this._autoExpand) 
            {
                var storedRectangles : Array<PackerRectangle> = currentAtlasData.rectangles.substring(0);
                storedRectangles = storedRectangles.concat(failedRectangles);
                
                if (this._sortOnExpand != 0) 
                    storedRectangles.sort((((this._sortOnExpand == 1)) ? this.sortOnHeightAscending : this.sortOnHeightDescending));
                
                var minimalArea : Int = this.getRectanglesArea(storedRectangles);
                
                //смотрит площадь minimalArea и если она меньше уже заданной _width, _height расширает ее вплоть до maxWidth, maxHeight
                do
                {
                    if ((currentAtlasData.width <= currentAtlasData.height || currentAtlasData.height == this._maxHeight) && currentAtlasData.width < this._maxWidth) 
                    {
                        if (this._forceValidTextureSizeOnExpand) 
                            currentAtlasData.width = currentAtlasData.width * 2
                        else 
                        currentAtlasData.width = currentAtlasData.width + 1;
                    }
                    else 
                    {
                        if (this._forceValidTextureSizeOnExpand) 
                            currentAtlasData.height = currentAtlasData.height * 2
                        else 
                        currentAtlasData.height = currentAtlasData.height + 1;
                    }
                }                while ((currentAtlasData.width * currentAtlasData.height < minimalArea && (currentAtlasData.width < this._maxWidth || currentAtlasData.height < this._maxHeight)));
                
                
                this.clear(currentAtlasData);
                success = this.addRectangles(storedRectangles, currentAtlasData, padding);
                
                //trace(_rectangles.length, storedRectangles.length);
                
                //если изначальная оценка оказалось не вреной и не смогли добавится все субтекстуры но еще есть место то расширяем атлас и добавляем еще
                while (!success && (currentAtlasData.width < this._maxWidth || currentAtlasData.height < this._maxHeight))
                {
                    if ((currentAtlasData.width <= currentAtlasData.height || currentAtlasData.height == this._maxHeight) && currentAtlasData.width < this._maxWidth) 
                    {
                        if (this._forceValidTextureSizeOnExpand) 
                            currentAtlasData.width = currentAtlasData.width * 2
                        else 
                        currentAtlasData.width = currentAtlasData.width + MaxRectPacker.nonValidTextureSizePrecision;
                    }
                    else 
                    {
                        if (this._forceValidTextureSizeOnExpand) 
                            currentAtlasData.height = currentAtlasData.height * 2
                        else 
                        currentAtlasData.height = currentAtlasData.height + MaxRectPacker.nonValidTextureSizePrecision;
                    }
                    
                    this.clear(currentAtlasData);
                    success = this.addRectangles(storedRectangles, currentAtlasData, padding);
                }
                
                success = currentAtlasData.width <= this._maxWidth && currentAtlasData.height <= this._maxHeight;
            }
            
            var length : Int = currentAtlasData.rectangles.length;
            for (k in 0...length){
                alreadyPackedMap[currentAtlasData.rectangles[k].id] = true;
            }
        }
        
        return success;
    }
    
    public function clear(atlasData : AtlasRectanglesData) : Void
    {
        var rects : Int = atlasData.rectangles.length;
        
        atlasData.rectangles.length = 0;
        
        while (this._firstAvailableArea != null)
        {
            var area : PackerRectangle = this._firstAvailableArea;
            this._firstAvailableArea = area.next;
            area.dispose();
        }
        
        this._firstAvailableArea = this._lastAvailableArea = PackerRectangle.get(0, 0, atlasData.width, atlasData.height);
        this._negativeArea = PackerRectangle.get(atlasData.width + 1, atlasData.height + 1, atlasData.width + 1, atlasData.height + 1);
    }
    
    public function drawAtlas(atlasIndex : Int) : BitmapData
    {
        var currentAtlasData : AtlasRectanglesData = atlasDatas[atlasIndex];
        
        var w : Float = currentAtlasData.width;
        var h : Float = currentAtlasData.height;
        
        var atlasBitmap : BitmapData = new BitmapData(w, h, true, 0x0);
        
        draw(atlasBitmap, currentAtlasData);
        
        return atlasBitmap;
    }
    
    private static var DRWAING_RECT : Rectangle = new Rectangle();
    private static var DRAWING_POINT : Point = new Point();
    
    private function draw(bitmapData : BitmapData, atlasData : AtlasRectanglesData) : Void
    {
        var rectangles : Array<PackerRectangle> = atlasData.rectangles;
        
        var _g1 : Int = 0;
        var _g : Int = rectangles.length;
        
        while (_g1 < _g)
        {
            var i : Int = _g1++;
            var rect : PackerRectangle = rectangles[i];
            
            DRWAING_RECT.setTo(rect.originX, rect.originY, rect.width, rect.height);
            DRAWING_POINT.setTo(rect.x, rect.y);
            
            bitmapData.copyPixels(rect.bitmapData, DRWAING_RECT, DRAWING_POINT);
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Protected methods
    //
    //--------------------------------------------------------------------------
    
    /**
		 * @private
		 */
    private function getRectanglesArea(rectangles : Array<PackerRectangle>) : Int{
        var area : Int = 0;
        var i : Int = rectangles.length - 1;
        while (i >= 0){
            area += rectangles[i].width * rectangles[i].height;
            i--;
        }
        return area;
    }
    
    /**
		 * @private
		 */
    private function addRectangles(rectangles : Array<PackerRectangle>, atlasData : AtlasRectanglesData, padding : Int = 0, force : Bool = true) : Bool
    {
        var count : Int = rectangles.length;
        var success : Bool = true;
        
        var _g : Int = 0;
        while (_g < count)
        {
            var i : Int = _g++;
            var rect : PackerRectangle = rectangles[i];
            success = success && this.addRectangle(rect, padding, atlasData);
            
            if (!success && !force) 
                return false;
        }
        
        return success;
    }
    
    /**
		 * @private
		 */
    private function addRectangle(rect : PackerRectangle, padding : Int, atlasData : AtlasRectanglesData) : Bool
    {
        var area : PackerRectangle = this.getAvailableArea(rect.width + (padding - rect.padding) * 2, rect.height + (padding - rect.padding) * 2, atlasData);
        
        if (area != null) 
        {
            rect.set(area.x, area.y, rect.width + (padding - rect.padding) * 2, rect.height + (padding - rect.padding) * 2);
            rect.padding = padding;
            this.splitAvailableAreas(rect);
            this.pushNewAreas();
            if (padding != 0)                 rect.setPadding(0);
            
            atlasData.rectangles.push(rect);
            totalPacketRectangles++;
        }
        
        return area != null;
    }
    
    /**
		 * @private
		 */
    private function createNewArea(x : Int, y : Int, width : Int, height : Int) : PackerRectangle
    {
        var valid : Bool = true;
        var area : PackerRectangle = this._firstNewArea;
        
        while (area != null)
        {
            var next : PackerRectangle = area.next;
            
            if (!(area.x > x || area.y > y || area.right < x + width || area.bottom < y + height)) 
            {
                valid = false;
                break;
            }
            else if (!(area.x < x || area.y < y || area.right > x + width || area.bottom > y + height)) 
            {
                if (area.next != null) 
                    area.next.previous = area.previous
                else 
                this._lastNewArea = area.previous;
                
                if (area.previous != null) 
                    area.previous.next = area.next
                else 
                this._firstNewArea = area.next;
                
                area.dispose();
            }
            
            area = next;
        }
        
        if (valid) 
        {
            area = PackerRectangle.get(x, y, width, height);
            if (this._newBoundingArea.x < x)                 this._newBoundingArea.x = x;
            if (this._newBoundingArea.right > area.right)                 this._newBoundingArea.right = area.right;
            if (this._newBoundingArea.y < y)                 this._newBoundingArea.y = y;
            if (this._newBoundingArea.bottom < area.bottom)                 this._newBoundingArea.bottom = area.bottom;
            if (this._lastNewArea != null) {
                area.previous = this._lastNewArea;
                this._lastNewArea.next = area;
                this._lastNewArea = area;
            }
            else {
                this._lastNewArea = area;
                this._firstNewArea = area;
            }
        }
        else area = null;
        return area;
    }
    
    /**
		 * @private
		 */
    private function splitAvailableAreas(splitter : PackerRectangle) : Void{
        var sx : Int = splitter.x;
        var sy : Int = splitter.y;
        var sright : Int = splitter.right;
        var sbottom : Int = splitter.bottom;
        var area : PackerRectangle = this._firstAvailableArea;
        while (area != null){
            var next : PackerRectangle = area.next;
            if (!(sx >= area.right || sright <= area.x || sy >= area.bottom || sbottom <= area.y)) {
                if (sx > area.x)                     this.createNewArea(area.x, area.y, sx - area.x, area.height);
                if (sright < area.right)                     this.createNewArea(sright, area.y, area.right - sright, area.height);
                if (sy > area.y)                     this.createNewArea(area.x, area.y, area.width, sy - area.y);
                if (sbottom < area.bottom)                     this.createNewArea(area.x, sbottom, area.width, area.bottom - sbottom);
                if (area.next != null)                     area.next.previous = area.previous
                else this._lastAvailableArea = area.previous;
                if (area.previous != null)                     area.previous.next = area.next
                else this._firstAvailableArea = area.next;
                area.dispose();
            }
            
            area = next;
        }
    }
    
    /**
		 * @private
		 */
    private function pushNewAreas() : Void{
        while (this._firstNewArea != null){
            var area : PackerRectangle = this._firstNewArea;
            if (area.next != null) {
                this._firstNewArea = area.next;
                this._firstNewArea.previous = null;
            }
            else this._firstNewArea = null;
            area.previous = null;
            area.next = null;
            if (this._lastAvailableArea != null) {
                area.previous = this._lastAvailableArea;
                this._lastAvailableArea.next = area;
                this._lastAvailableArea = area;
            }
            else {
                this._lastAvailableArea = area;
                this._firstAvailableArea = area;
            }
        }
        
        this._lastNewArea = null;
        this._newBoundingArea.set(0, 0, 0, 0);
    }
    
    /**
		 * @private
		 */
    private function getAvailableArea(width : Int, height : Int, atlasData : AtlasRectanglesData) : PackerRectangle{
        var available : PackerRectangle = this._negativeArea;
        var index : Int = -1;
        var area : PackerRectangle;
        var w : Int;
        var h : Int;
        var m1 : Int;
        var m2 : Int;
        if (this._heuristics == 0) {
            area = this._firstAvailableArea;
            while (area != null){
                if (area.width >= width && area.height >= height) {
                    if (area.y < available.y || area.y == available.y && area.x < available.x)                         available = area;
                }
                
                area = area.next;
            }
        }
        else if (this._heuristics == 1) {
            available.width = atlasData.width + 1;
            area = this._firstAvailableArea;
            while (area != null){
                if (area.width >= width && area.height >= height) {
                    w = area.width - width;
                    h = area.height - height;
                    if (w < h)                         m1 = w
                    else m1 = h;
                    w = available.width - width;
                    h = available.height - height;
                    if (w < h)                         m2 = w
                    else m2 = h;
                    if (m1 < m2)                         available = area;
                }
                
                area = area.next;
            }
        }
        else if (this._heuristics == 2) {
            available.width = atlasData.width + 1;
            area = this._firstAvailableArea;
            while (area != null){
                if (area.width >= width && area.height >= height) {
                    w = area.width - width;
                    h = area.height - height;
                    if (w > h)                         m1 = w
                    else m1 = h;
                    w = available.width - width;
                    h = available.height - height;
                    if (w > h)                         m2 = w
                    else m2 = h;
                    if (m1 < m2)                         available = area;
                }
                
                area = area.next;
            }
        }
        else if (this._heuristics == 3) {
            available.width = atlasData.width + 1;
            area = this._firstAvailableArea;
            while (area != null){
                if (area.width >= width && area.height >= height) {
                    var a1 : Int = area.width * area.height;
                    var a2 : Int = available.width * available.height;
                    if (a1 < a2 || a1 == a2 && area.width < available.width)                         available = area;
                }
                area = area.next;
            }
        }
        if (available != this._negativeArea)             return available
        else return null;
    }
    
    /**
		 * @private
		 */
    private function sortOnAreaAscending(a : PackerRectangle, b : PackerRectangle) : Int{
        var aa : Int = a.width * a.height;
        var ba : Int = b.width * b.height;
        if (aa < ba)             return -1
        else if (aa > ba)             return 1;
        return 1;
    }
    
    /**
		 * @private
		 */
    private function sortOnAreaDescending(a : PackerRectangle, b : PackerRectangle) : Int{
        var aa : Int = a.width * a.height;
        var ba : Int = b.width * b.height;
        if (aa > ba)             return -1
        else if (aa < ba)             return 1;
        
        return 1;
    }
    
    /**
		 * @private
		 */
    private function sortOnHeightAscending(a : PackerRectangle, b : PackerRectangle) : Int{
        if (a.height < b.height)             return -1
        else if (a.height > b.height)             return 1;
        
        return 1;
    }
    
    /**
		 * @private
		 */
    private function sortOnHeightDescending(a : PackerRectangle, b : PackerRectangle) : Int{
        if (a.height > b.height)             return -1
        else if (a.height < b.height)             return 1;
        return 1;
    }
}

