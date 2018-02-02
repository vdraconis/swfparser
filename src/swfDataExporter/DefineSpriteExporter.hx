package swfdataexporter;

import swfdataexporter.SwfPackerTagExporter;


import flash.utils.ByteArray;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagDefineSprite;
import swfdata.FrameData;
import swfdataexporter.ExporerTypes;
import swfdataexporter.SwfTagExporter;

class DefineSpriteExporter extends SwfPackerTagExporter
{
    /**
		 * 1nt16 - tagHeader
		 * int16 - char id
		 * int8  - frames count
		 * int8  - tags count
		 * array of frame data
		 * [int8 - isHaveLabel, utfBytes - frameLabel]
		 * array of tags data
		 */
    
    private var swfTagExporter:SwfTagExporter;
    
    public function new(swfTagExporter:SwfTagExporter)
    {
        super(ExporerTypes.DEFINE_SPRITE);
        
        this.swfTagExporter = swfTagExporter;
    }
    
    override public function exportTag(tag:SwfPackerTag, output:ByteArray):Void
    {
        super.exportTag(tag, output);
        
        var tagAsSpriteDefine:SwfPackerTagDefineSprite = try cast(tag, SwfPackerTagDefineSprite) catch(e:Dynamic) null;
        
        var tagsCount:Int = tagAsSpriteDefine.tags.length;
        var frameCount:Int = tagAsSpriteDefine.frameCount;
        
        output.writeShort(tagAsSpriteDefine.characterId);
        output.writeShort(frameCount);
        output.writeShort(tagsCount);
        
        var i:Int;
        
        for (i in 0...frameCount)
		{
            var currentFrameData:FrameData = tagAsSpriteDefine.frames[i];
            
            output.writeShort(currentFrameData.numChildren);
            
            if (currentFrameData.frameLabel != null) 
            {
                output[output.position++] = 1;
                output.writeUTF(currentFrameData.frameLabel);
            }
            else 
            {
                output[output.position++] = 0;
            }
        }  //trace('export sub tags', tagAsSpriteDefine.tags.length);  
        
        
        
        swfTagExporter.exportTags(tagAsSpriteDefine.tags, output);
    }
    
    override public function importTag(tag:SwfPackerTag, input:ByteArray):Void
    {
        super.importTag(tag, input);
        
        var tagAsSpriteDefine:SwfPackerTagDefineSprite = try cast(tag, SwfPackerTagDefineSprite) catch(e:Dynamic) null;
        
        var characterId:Int = input.readShort();
        var frameCount:Int = input.readShort();
        var tagsCount:Int = input.readShort();
        
        tagAsSpriteDefine.characterId = characterId;
        tagAsSpriteDefine.frameCount = frameCount;
        
        if (frameCount > 0) 
            tagAsSpriteDefine.frames = new Array<FrameData>();
        
        var i:Int;
        
        for (i in 0...frameCount){
            var numChildren:Int = input.readShort();
            var currentFrameData:FrameData = new FrameData(i, null, numChildren);
            
            var isHaveLabel:Bool = input.readUnsignedByte() == 1;
            
            if (isHaveLabel) 
                currentFrameData.frameLabel = input.readUTF();
            
            tagAsSpriteDefine.frames[i] = currentFrameData;
        }
        
        if (tagsCount > 0) 
        {
            tagAsSpriteDefine.tags = new Array<SwfPackerTag>();
            
            for (i in 0...tagsCount){
                //try
                //{
                tagAsSpriteDefine.tags[i] = swfTagExporter.importSingleTag(input);
            }
        }
    }
}
