package swfparser.tags;

import swfdata.datatags.SwfPackerTag;
import swfparser.DisplayObjectContext;
import swfparser.SwfParserContext;

class TagProcessorBase
{
	private var currentTag : SwfPackerTag;
	private var context : SwfParserContext;
	private var displayObjectContext : DisplayObjectContext;

	public function new(context : SwfParserContext)
	{
		this.context = context;
		displayObjectContext = context.displayObjectContext;
	}

	public function processTag(tag : SwfPackerTag) : Void
	{
		currentTag = tag;
	}
}
