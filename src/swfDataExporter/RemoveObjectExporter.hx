package swfdataexporter;

import flash.errors.Error;
import swfdataexporter.SwfPackerTagExporter;


import flash.utils.ByteArray;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagRemoveObject;
import swfdataexporter.ExporerTypes;

class RemoveObjectExporter extends SwfPackerTagExporter
{
    
    public function new()
    {
        super(ExporerTypes.REMOVE_OBJECT);
    }
    
    override public function exportTag(tag : SwfPackerTag, output : ByteArray) : Void
    {
        super.exportTag(tag, output);
        
        var tagAsRemoveObject : SwfPackerTagRemoveObject = try cast(tag, SwfPackerTagRemoveObject) catch(e:Dynamic) null;
        
        if (tagAsRemoveObject.depth > 32767 || tagAsRemoveObject.depth < 0) 
            throw new Error("out of range");
        
        output.writeShort(tagAsRemoveObject.depth);
        output.writeShort(tagAsRemoveObject.characterId);
    }
    
    override public function importTag(tag : SwfPackerTag, input : ByteArray) : Void
    {
        super.importTag(tag, input);
        
        var tagAsRemoveObject : SwfPackerTagRemoveObject = try cast(tag, SwfPackerTagRemoveObject) catch(e:Dynamic) null;
        
        tagAsRemoveObject.depth = input.readShort();
        tagAsRemoveObject.characterId = input.readShort();
    }
}

