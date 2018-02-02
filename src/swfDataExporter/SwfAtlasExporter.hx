package swfdataexporter;


import lime.graphics.PixelFormat;
import openfl.display3D.Context3DTextureFormat;
import swfdata.atlas.BitmapSubTexture;
import swfdata.atlas.GLTextureAtlas;
import utils.ByteUtils;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import swfdata.ShapeData;
import swfdata.ShapeLibrary;
import swfdata.atlas.BitmapTextureAtlas;

#if genome
import swfdata.atlas.GenomeSubTexture;
import swfdata.atlas.GenomeTextureAtlas;
#end 

import swfdata.atlas.TextureTransform;

@:access(openfl.display)
class SwfAtlasExporter
{
    private var bitmapBytes:ByteArray = new ByteArray();
    
    public function new()
    {
        
        
    }
    
    public static function roundPixels20(pixels:Float):Float{
        return Math.round(pixels * 100) / 100;
    }
    
    public function readRectangle(input:ByteArray):Rectangle
    {
        //var bits:uint = input.readBits(5);
        
        
        var rect:Rectangle = new Rectangle();
        
        //rect.x = (input.readBits(bits));
        //rect.width = (input.readBits(bits));
        //rect.y = (input.readBits(bits));
        //rect.height = (input.readBits(bits));
        
        
        rect.x = roundPixels20(input.readInt() / 20);
        rect.width = roundPixels20(input.readInt() / 20);
        rect.y = roundPixels20(input.readInt() / 20);
        rect.height = roundPixels20(input.readInt() / 20);
        
        //trace('read rect', rect);
        
        //trace('read rectangle', rect);
        
        return rect;
    }
    
    public function writeRectangle(rectangle:Rectangle, output:ByteArray):Void
    {
        var xmin:Int = Std.int(rectangle.x * 20);
        var xmax:Int = Std.int(rectangle.width * 20);
        var ymin:Int = Std.int(rectangle.y * 20);
        var ymax:Int = Std.int(rectangle.height * 20);
        
        //if (xmin < 0 || ymin < 0 || xmax < 0 || ymax < 0)
        //throw new Error("value range error: " + xmin + ", " + ymin + ", " + xmax + ", " + ymax);
        
        var numBits:Int = ByteUtils.calculateMaxBits4(true, xmin, xmax, ymin, ymax);
        
        //output.writeBits(numBits, 5);
        //output.writeBits(xmin, numBits);
        //output.writeBits(xmax, numBits);
        //output.writeBits(ymin, numBits);
        //output.writeBits(ymax, numBits);
        
        output.writeInt(xmin);
        output.writeInt(xmax);
        output.writeInt(ymin);
        output.writeInt(ymax);
    }
    
    public function readTextureTransform(input:ByteArray):TextureTransform
    {
        var scaleX:Float = 1;
        var scaleY:Float = 1;
        
        /*	if (input.readBits(1) == 1) 
			{
				var scaleBits:uint = input.readBits(5);
				scaleX = input.readFixedBits(scaleBits);
				scaleY = input.readFixedBits(scaleBits);
			}*/
        
        if (input.readUnsignedByte() == 1) 
        {
            scaleX = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
            scaleY = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        }  //var translateY:Number = input.readBits(translateBits);    //var translateX:Number = input.readBits(translateBits);    //var translateBits:uint = input.readBits(5);    //input.bitsReader.clear();  

        var translateX:Float = input.readInt();
        var translateY:Float = input.readInt();
        
        //trace('read transform', scaleX, scaleY, translateX / 2000, translateY / 2000);
        
        return new TextureTransform(scaleX, scaleY, translateX / 2000, translateY / 2000);
    }
    
    public function writeTextureTransform(transform:TextureTransform, output:ByteArray):Void
    {
        var translateX:Int = Std.int(transform.tx * 2000);
        var translateY:Int = Std.int(transform.ty * 2000);
        
        var scaleX:Float = transform.scaleX;
        var scaleY:Float = transform.scaleY;
        
        var hasScale:Bool = (scaleX != 1) || (scaleY != 1);
        
        //output.writeBits(hasScale ? 1:0, 1);
        output.writeUnsignedInt((hasScale) ? 1:0);
        if (hasScale) 
        {
            /*var scaleBits:uint;
				if (scaleX == 0 && scaleY == 0) 
				{
					scaleBits = 1;
				} 
				else 
				{
					scaleBits = ByteArrayUtils.calculateMaxBits(true, scaleX * Constants.FIXED_PRECISSION_VALUEE, scaleY * Constants.FIXED_PRECISSION_VALUEE);
				}
				
				if (scaleX < 0 || scaleY < 0)
					throw new Error("value range error: " + scaleX + ", " + scaleY);
				
				output.writeBits(scaleBits, 5);
				output.writeFixedBits(scaleX, scaleBits);
				output.writeFixedBits(scaleY, scaleBits);*/
            
            output.writeInt(Std.int(scaleX * ByteUtils.FIXED_PRECISSION_VALUE));
            output.writeInt(Std.int(scaleY * ByteUtils.FIXED_PRECISSION_VALUE));
        }  //output.writeBits(translateY, translateBits);    //output.writeBits(translateX, translateBits);    //output.writeBits(translateBits, 5);    //var translateBits:uint = ByteArrayUtils.calculateMaxBits(true, translateX, translateY);    //output.end(false);  
        
        output.writeInt(translateX);
        output.writeInt(translateY);
    }
    
    public function exportAtlas(atlas:BitmapTextureAtlas, shapesList:ShapeLibrary, output:ByteArray):Void
    {
        var bitmap:BitmapData = atlas.atlasData;
        var bitmapBytes:ByteArray = bitmap.getPixels(bitmap.rect);
        
        if (bitmap.width < 2 || bitmap.height < 2) 
            Internal_trace.trace("Error: somethink wrong with atlas data");
        
        output[output.position++] = atlas.padding;
        output.writeInt(bitmapBytes.length);
        output.writeShort(bitmap.width);
        output.writeShort(bitmap.height);
        
        output.writeBytes(bitmapBytes, 0, bitmapBytes.length);
        
        output.writeShort(atlas.texturesCount);
        
        //trace('pre write', output.position);
        
        for (texture/* AS3HX WARNING could not determine type for var: texture exp: EField(EIdent(atlas),subTextures) type: null */ in atlas.subTextures)
        {
            output.writeShort(texture.id);
            
            writeTextureTransform(texture.transform, output);
            writeRectangle(texture.bounds, output);
            
            writeRectangle(shapesList.getShape(texture.id).shapeData.shapeBounds, output);
        }  //output.end(false);  
    }
		
	public function impotGLAtlas(name:String, input:ByteArray, shapesList:ShapeLibrary):GLTextureAtlas
	{
		var textureAtlas:GLTextureAtlas;
		
		input.position = 0;
		
		var padding:Int = input.readUnsignedByte();
		var bitmapSize:Int = input.readInt();
		var width:Int = input.readShort();
		var height:Int = input.readShort();
		
		bitmapBytes.length = 0;
		
		input.readBytes(bitmapBytes, 0, bitmapSize);
		
		if (width < 2 || height < 2) 
			trace("Error: somethink wrong with atlas data");
			
		var atlasData:BitmapData = new BitmapData(width, height, true, 0x0);
		
		atlasData.image.setPixels (@:privateAccess atlasData.rect.__toLimeRectangle(), bitmapBytes, PixelFormat.BGRA32, bitmapBytes.endian);
		
		textureAtlas = new GLTextureAtlas(name, atlasData, Context3DTextureFormat.BGRA, padding);
		
		var texturesCount:Int = input.readShort();
		
		var r:Rectangle = new Rectangle();
		for (i in 0...texturesCount)
		{
			var id:Int = input.readShort();
			
			var textureTransform:TextureTransform = readTextureTransform(input);
			var textureRegion:Rectangle = readRectangle(input);
			var shapeBounds:Rectangle = readRectangle(input);
			
			//if (textureTransform.scaleX != 1 || textureTransform.scaleY != 1)
			/*
				r.setTo(textureRegion.x + padding, textureRegion.y + padding, textureRegion.width - padding * 2, 1);
				atlasData.fillRect(r, 0xFF00FF00);
				
				
				r.setTo(textureRegion.x + padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
				atlasData.fillRect(r, 0xFF00FF00);
				
				
				r.setTo(textureRegion.x + textureRegion.width - padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
				atlasData.fillRect(r, 0xFF00FF00);
				
				
				r.setTo(textureRegion.x + padding, textureRegion.y + textureRegion.height - padding, textureRegion.width - padding * 2, 1);
				atlasData.fillRect(r, 0xFF00FF00);
			*/	
			
			shapesList.addShape(/*null,*/ new ShapeData(id, shapeBounds));
			
			textureAtlas.createSubTexture(id, textureRegion, textureTransform.scaleX, textureTransform.scaleY);
		}
		
		textureAtlas.uploadToGpu();
		
		return textureAtlas;
	}
	
	public function importBitmapAtlas(name:String, input:ByteArray, shapesList:ShapeLibrary):BitmapTextureAtlas
    {
        var textureAtlas:BitmapTextureAtlas;
        
        var padding:Int = input.readUnsignedByte();
        var bitmapSize:Int = input.readInt();
        var width:Int = input.readShort();
        var height:Int = input.readShort();
        
        bitmapBytes.length = 0;
		
		trace('importing atlas', input.bytesAvailable, padding, width, height, bitmapSize);
        
        input.readBytes(bitmapBytes, 0, bitmapSize);
		
		
        
        if (width < 2 || height < 2) 
            trace("Error: somethink wrong with atlas data");
			
        textureAtlas = new BitmapTextureAtlas(width, height, padding);
		textureAtlas.atlasData.setPixels(textureAtlas.atlasData.rect, bitmapBytes);
        
        var texturesCount:Int = input.readShort();
        
        //trace('pre read', input.position);
        
        var r:Rectangle = new Rectangle();
        for (i in 0...texturesCount){
            var id:Int = input.readShort();
            
            var textureTransform:TextureTransform = readTextureTransform(input);
            var textureRegion:Rectangle = readRectangle(input);
            var shapeBounds:Rectangle = readRectangle(input);
            
            //trace("read", input.position);
            
            /*
				//if (textureTransform.scaleX != 1 || textureTransform.scaleY != 1)
				//{
					r.setTo(textureRegion.x + padding, textureRegion.y + padding, textureRegion.width - padding * 2, 1);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + textureRegion.width - padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + padding, textureRegion.y + textureRegion.height - padding, textureRegion.width - padding * 2, 1);
					bitmapData.fillRect(r, 0xFF00FF00);
				//}	
				*/
            shapesList.addShape(/*null,*/ new ShapeData(id, shapeBounds));
            var texture:BitmapSubTexture = new BitmapSubTexture(id, textureRegion, textureTransform);
            
            textureAtlas.putTexture(texture);
        }  //input.bitsReader.clear();  
        
        return textureAtlas;
    }
    
	#if genome
    public function importAtlasGenome(name:String, input:ByteArray, shapesList:ShapeLibrary, format:String):GenomeTextureAtlas
    {
        var textureAtlas:GenomeTextureAtlas;
        
        var padding:Int = input.readUnsignedByte();
        var bitmapSize:Int = input.readInt();
        var width:Int = input.readShort();
        var height:Int = input.readShort();
        
        bitmapBytes.length = 0;
        
        input.readBytes(bitmapBytes, 0, bitmapSize);
        
        if (width < 2 || height < 2) 
            Internal_trace("Error: somethink wrong with atlas data");
        
        var bitmapData:BitmapData = new BitmapData(width, height, true);
        bitmapData.setPixels(bitmapData.rect, bitmapBytes);
        
        //WindowUtil.openWindowToReview(bitmapData);
        
        textureAtlas = new GenomeTextureAtlas(name, bitmapData, format, padding);
        
        var texturesCount:Int = input.readShort();
        
        //trace('pre read', input.position);
        
        var r:Rectangle = new Rectangle();
        for (i in 0...texturesCount){
            var id:Int = input.readShort();
            
            var textureTransform:TextureTransform = readTextureTransform(input);
            var textureRegion:Rectangle = readRectangle(input);
            var shapeBounds:Rectangle = readRectangle(input);
            
            //trace("read", input.position);
            
            /*
				//if (textureTransform.scaleX != 1 || textureTransform.scaleY != 1)
				//{
					r.setTo(textureRegion.x + padding, textureRegion.y + padding, textureRegion.width - padding * 2, 1);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + textureRegion.width - padding, textureRegion.y + padding, 1, textureRegion.height - padding *2);
					bitmapData.fillRect(r, 0xFF00FF00);
					
					
					r.setTo(textureRegion.x + padding, textureRegion.y + textureRegion.height - padding, textureRegion.width - padding * 2, 1);
					bitmapData.fillRect(r, 0xFF00FF00);
				//}	
				*/
            shapesList.addShape(null, new ShapeData(id, shapeBounds));
            var texture:GenomeSubTexture = new GenomeSubTexture(id, textureRegion, textureTransform, textureAtlas.gTextureAtlas);
            
            textureAtlas.putTexture(texture);
        }  //input.bitsReader.clear();  
        
        
        
        
        textureAtlas.reupload();
        
        return textureAtlas;
    }

	#end
}
