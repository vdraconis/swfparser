package swfdataexporter;



import openfl.utils.ByteArray;
import swfdata.datatags.SwfPackerTag;
import swfdataexporter.ExporerTypes;

class SwfPackerTagExporter
{
    public var type:Int;
    
    public function new(type:Int = ExporerTypes.BASE_TYPE)
    {
        this.type = type;
    }
    
    public function exportTag(tag:SwfPackerTag, output:ByteArray):Void
    {
        
        output[output.position++] = (type);
    }
    
    public function importTag(tag:SwfPackerTag, input:ByteArray):Void
    {
        
        
    }
}
