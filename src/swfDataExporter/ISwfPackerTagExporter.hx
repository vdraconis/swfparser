package swfdataexporter;


import flash.utils.ByteArray;
import swfdata.datatags.SwfPackerTag;

/**
	 * ...
	 * @author ...
	 */
interface ISwfPackerTagExporter
{

    
    function exportTag(tag : SwfPackerTag, output : ByteArray) : Void;
    
    function importTag(tag : SwfPackerTag, input : ByteArray) : Void;
}

