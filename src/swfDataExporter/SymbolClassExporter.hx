package swfdataexporter;

import openfl.utils.ByteArray;
import swfdata.datatags.RawClassSymbol;
import swfdata.datatags.SwfPackerTag;
import swfdata.datatags.SwfPackerTagSymbolClass;
import swfdataexporter.ExporerTypes;
import swfdataexporter.SwfPackerTagExporter;

class SymbolClassExporter extends SwfPackerTagExporter
{
    
    public function new()
    {
        super(ExporerTypes.SYMBOL_CLASS);
    }
    
    override public function exportTag(tag:SwfPackerTag, output:ByteArray):Void
    {
        super.exportTag(tag, output);
        
        var tagAsSymbolClass:SwfPackerTagSymbolClass = try cast(tag, SwfPackerTagSymbolClass) catch(e:Dynamic) null;
        var symbolsCount:Int = tagAsSymbolClass.length;
        
        output.writeShort(symbolsCount);
        
        for (i in 0...symbolsCount){
            
            var currentLinkage:String = tagAsSymbolClass.linkageList[i];
            var currentCharacterId:Int = tagAsSymbolClass.characterIdList[i];
            
            //if (currentSumbol.linkage == null)
            //	continue;
            
            output.writeShort(currentCharacterId);
            output.writeUTF(currentLinkage);
        }
    }
    
    override public function importTag(tag:SwfPackerTag, input:ByteArray):Void
    {
        super.importTag(tag, input);
        
        var tagAsSymbolClass:SwfPackerTagSymbolClass = try cast(tag, SwfPackerTagSymbolClass) catch(e:Dynamic) null;
        
        var symbolsCount:Int = input.readShort();
        
        tagAsSymbolClass.length = symbolsCount;
        tagAsSymbolClass.initializeContent();
        
        var linkagesList:Array<String> = tagAsSymbolClass.linkageList;
        var characterList:Array<Int> = tagAsSymbolClass.characterIdList;
        
        for (i in 0...symbolsCount){
            characterList[i] = input.readShort();
            linkagesList[i] = input.readUTF();
        }
    }
}
