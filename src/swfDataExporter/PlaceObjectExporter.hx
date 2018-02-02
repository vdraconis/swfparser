package swfdataexporter;

import flash.errors.Error;
import swfdataexporter.SwfPackerTagExporter;
import utils.ByteUtils;

import flash.geom.Matrix;
import flash.utils.ByteArray;

import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagPlaceObject;
import swfdataexporter.ExporerTypes;
import utils.BitMask;

class PlaceObjectExporter extends SwfPackerTagExporter
{
    private static var bitMask:BitMask = new BitMask();
    
    public function new()
    {
        super(ExporerTypes.PLACE_OBJECT);
    }
    
	inline public function readMATRIX(input:ByteArray, tagAsPlaceObject:SwfPackerTagPlaceObject)
    {
        var scaleX:Float = 1;
        var scaleY:Float = 1;
        
        //if (input.readBits(1) == 1)
        if (input.readUnsignedByte() == 1) 
        {
            //var scaleBits:uint = input.readBits(5);
            //scaleX = input.readFixedBits(scaleBits);
            //scaleY = input.readFixedBits(scaleBits);
            
            scaleX = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
            scaleY = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        }
        
        var rotateSkew0:Float = 0;
        var rotateSkew1:Float = 0;
        
        //if (input.readBits(1) == 1)
        if (input.readUnsignedByte() == 1) 
        {
            //var rotateBits:uint = input.readBits(5);
            //rotateSkew0 = input.readFixedBits(rotateBits);
            //rotateSkew1 = input.readFixedBits(rotateBits);
            
            rotateSkew0 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
            rotateSkew1 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        }  
		
		//var translateY:Number = input.readBits(translateBits);   
		//var translateX:Number = input.readBits(translateBits);  
		//var translateBits:uint = input.readBits(5);  
        
        var translateX:Float = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        var translateY:Float = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        
        tagAsPlaceObject.setMatrix(scaleX, rotateSkew0, rotateSkew1, scaleY, translateX, translateY);
    }
    
    inline public function writeMATRIX(output:ByteArray, value:SwfPackerTagPlaceObject):Void
    {
        var scaleX:Float = value.a;
        var scaleY:Float = value.d;
        var rotateSkew0:Float = value.b;
        var rotateSkew1:Float = value.c;
        var translateX:Int = Std.int(value.tx * ByteUtils.FIXED_PRECISSION_VALUE);
        var translateY:Int = Std.int(value.ty * ByteUtils.FIXED_PRECISSION_VALUE);
        
        var hasScale:Bool = (scaleX != 1) || (scaleY != 1);
        var hasRotate:Bool = (rotateSkew0 != 0) || (rotateSkew1 != 0);
        
        //output.writeBits(hasScale ? 1:0, 1);
        output[output.position++] = ((hasScale) ? 1:0);
        
        if (hasScale) 
        {
            //var scaleBits:uint;
            //if (scaleX == 0 && scaleY == 0)
            //{
            //	scaleBits = 1;
            //}
            //else
            //{
            //	scaleBits = ByteArrayUtils.calculateMaxFixedBits(true, scaleX, scaleY);
            //}
            
            //output.writeBits(scaleBits, 5);
            //output.writeFixedBits(scaleX, scaleBits);
            //output.writeFixedBits(scaleY, scaleBits);
            
            output.writeInt(Std.int(scaleX * ByteUtils.FIXED_PRECISSION_VALUE));
            output.writeInt(Std.int(scaleY * ByteUtils.FIXED_PRECISSION_VALUE));
        }  //output.writeBits(hasRotate ? 1:0, 1);  
        
        
        
        output[output.position++] = ((hasRotate) ? 1:0);
        
        if (hasRotate) 
        {
            //var rotateBits:uint = ByteArrayUtils.calculateMaxFixedBits(true, rotateSkew0, rotateSkew1);
            
            //output.writeBits(rotateBits, 5);
            //output.writeFixedBits(rotateSkew0, rotateBits);
            //output.writeFixedBits(rotateSkew1, rotateBits);
            
            output.writeInt(Std.int(rotateSkew0 * ByteUtils.FIXED_PRECISSION_VALUE));
            output.writeInt(Std.int(rotateSkew1 * ByteUtils.FIXED_PRECISSION_VALUE));
        }  
		//output.end(false);    
		//output.writeBits(translateY, translateBits);  
		//output.writeBits(translateX, translateBits);   
		//output.writeBits(translateBits, 5);  
		//var translateBits:uint = ByteArrayUtils.calculateMaxBits(true, translateX, translateY);  
        
        output.writeInt(translateX);
        output.writeInt(translateY);
    }
    
    inline public function readColorMatrix(tag:SwfPackerTagPlaceObject, input:ByteArray):Void
    {
        tag.redColor0 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.redColor1 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.redColor2 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.redColor3 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.redColorOffset = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        
        tag.greenColor0 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.greenColor1 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.greenColor2 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.greenColor3 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.greenColorOffset = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        
        tag.blueColor0 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.blueColor1 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.blueColor2 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.blueColor3 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.blueColorOffset = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        
        tag.alpha0 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.alpha1 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.alpha2 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.alpha3 = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
        tag.alphaOffset = input.readInt() / ByteUtils.FIXED_PRECISSION_VALUE;
    }
    
    inline public function writeColorMatrix(tag:SwfPackerTagPlaceObject, output:ByteArray):Void
    {
        //trace(tag.instanceName, "write color matrix", tag.toColorMatrixString());
        var hasOffset:Bool = tag.redColorOffset != 0 || tag.greenColorOffset != 0 || tag.blueColorOffset != 0 || tag.alphaOffset != 0;
        var hasRed:Bool = tag.redColor0 != 0 || tag.redColor1 != 0 || tag.redColor2 != 0 || tag.redColor3 != 0;
        var hasGreen:Bool = tag.greenColor0 != 0 || tag.greenColor1 != 0 || tag.greenColor2 != 0 || tag.greenColor3 != 0;
        var hasBlue:Bool = tag.blueColor0 != 0 || tag.blueColor1 != 0 || tag.blueColor2 != 0 || tag.blueColor3 != 0;
        
        var componentsMask:Int = 0;
        bitMask.mask = componentsMask;
        
        output.writeInt(Std.int(tag.redColor0 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.redColor1 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.redColor2 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.redColor3 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.redColorOffset * ByteUtils.FIXED_PRECISSION_VALUE));
        
        output.writeInt(Std.int(tag.greenColor0 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.greenColor1 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.greenColor2 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.greenColor3 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.greenColorOffset * ByteUtils.FIXED_PRECISSION_VALUE));
        
        output.writeInt(Std.int(tag.blueColor0 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.blueColor1 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.blueColor2 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.blueColor3 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.blueColorOffset * ByteUtils.FIXED_PRECISSION_VALUE));
        
        output.writeInt(Std.int(tag.alpha0 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.alpha1 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.alpha2 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.alpha3 * ByteUtils.FIXED_PRECISSION_VALUE));
        output.writeInt(Std.int(tag.alphaOffset * ByteUtils.FIXED_PRECISSION_VALUE));
    }
    
    inline override public function exportTag(tag:SwfPackerTag, output:ByteArray):Void
    {
        super.exportTag(tag, output);
        
        var tagAsPlaceObject:SwfPackerTagPlaceObject = try cast(tag, SwfPackerTagPlaceObject) catch(e:Dynamic) null;
        
        
        bitMask.mask = 0;
        
        if (tagAsPlaceObject.hasClipDepth) 
            bitMask.setBit(0);
        
        if (tagAsPlaceObject.hasName) 
            bitMask.setBit(1);  
			
	   //if (tagAsPlaceObject.hasRatio)  ;
	   //	bitMask.setBit(3); 
        
        if (tagAsPlaceObject.hasMatrix) 
            bitMask.setBit(2);
        
        if (tagAsPlaceObject.hasCharacter) 
            bitMask.setBit(3);
        
        if (tagAsPlaceObject.hasColorTransform) 
            bitMask.setBit(4);  //	bitMask.setBit(11);    //if (tagAsPlaceObject.hasFilterList)    //	bitMask.setBit(10);    //if (tagAsPlaceObject.hasBlendMode)    //	bitMask.setBit(9);    //if (tagAsPlaceObject.hasImage)    //	bitMask.setBit(8);    //if (tagAsPlaceObject.hasVisible)    //	bitMask.setBit(7);    //if (tagAsPlaceObject.hasMove)    //  ;   
        
        output[output.position++] = (bitMask.mask);
        
        output[output.position++] = (tagAsPlaceObject.placeMode);
        output.writeShort(tagAsPlaceObject.depth);
        
        if (tagAsPlaceObject.depth > 65535) 
            throw new Error("depth range error " + tagAsPlaceObject.depth);
        
        if (tagAsPlaceObject.hasClipDepth) 
            output[output.position++] = (tagAsPlaceObject.clipDepth);
        
        if (tagAsPlaceObject.hasName) 
            output.writeUTF(tagAsPlaceObject.instanceName);  //	output.writeUnsignedInt(tagAsPlaceObject.ratio);    //if (tagAsPlaceObject.hasRatio)  ;
        
        if (tagAsPlaceObject.hasMatrix) 
            writeMATRIX(output, tagAsPlaceObject);
        
        if (tagAsPlaceObject.hasCharacter) 
            output.writeShort(tagAsPlaceObject.characterId);
        
        if (tagAsPlaceObject.hasColorTransform) 
        {
            //trace('shood write color');
            writeColorMatrix(tagAsPlaceObject, output);
        }  //output.end(false);  
    }
    
    private var totalTime:Float = 0;
    private var totalTime2:Float = 0;
    inline override public function importTag(tag:SwfPackerTag, input:ByteArray):Void
    {
        var tagAsPlaceObject:SwfPackerTagPlaceObject = try cast(tag, SwfPackerTagPlaceObject) catch(e:Dynamic) null;
        
        //var currentTime:Number = getTimer();
        var mask:Int = input.readUnsignedByte();
        bitMask.mask = mask;
        
        var placeMode:Int = input.readUnsignedByte();
        var depth:Int = input.readShort();
        var hasClipDepth:Bool = bitMask.isBitSet(0);
        var hasName:Bool = bitMask.isBitSet(1);
        var hasMatrix:Bool = bitMask.isBitSet(2);
        var hasCharacter:Bool = bitMask.isBitSet(3);
        var hasColorTransform:Bool = bitMask.isBitSet(4);
        
        var instanceName:String = null;
        var clipDepth:Int = 0;
        var characterId:Int = 0;
        //totalTime += getTimer() - currentTime;
        //trace("total time", totalTime);
        if (hasClipDepth) 
        {
            clipDepth = input.readUnsignedByte();
        }
        
        if (hasName) 
        {
            instanceName = input.readUTF();
        }
        
        if (hasMatrix) 
        {
            //currentTime = getTimer()
            readMATRIX(input, tagAsPlaceObject);
        }
        
        if (hasCharacter) 
        {
            characterId = input.readShort();
        }
        
        tagAsPlaceObject.fillData(placeMode, depth, hasClipDepth, hasName, hasMatrix, hasCharacter, instanceName, clipDepth, characterId);
        
        if (hasColorTransform) 
        {
            
            tagAsPlaceObject.hasColorTransform = true;
            readColorMatrix(tagAsPlaceObject, input);
        }
    }
}
