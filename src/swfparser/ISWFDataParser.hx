package swfparser;

import swfparser.SwfParserContext;

import swfdata.datatags.SwfPackerTag;

interface ISWFDataParser
{
    
    
    
    
    var context(get, set) : SwfParserContext;

    
    function processDisplayObject(tags : Array<SwfPackerTag>) : Void;
}

