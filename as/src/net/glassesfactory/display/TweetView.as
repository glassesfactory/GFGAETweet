/*////////////////////////////////////////////

GFGAETWeet

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/04/08

Copyright 2010 glasses factory
http://glasses-factory.net

/*////////////////////////////////////////////

package net.glassesfactory.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	
	public class TweetView extends Sprite
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		public var bottom:Number = 0;
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function TweetView( username:String, text:String, icon:ByteArray, isOdd:Boolean = false )
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _iconLoadedHandler );
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _ioErrorHandler );
			_loader.loadBytes(icon);
			
			_username = new TextField();
			_username.text = username;
			_text = new TextField();
			_text.autoSize = TextFieldAutoSize.LEFT;
			_text.multiline = true;
			_text.wordWrap = true;
			_text.width = 370;
			_text.text = text;
			
			var bmd:BitmapData = new BitmapData( 445, 1, false, 0xffffff );
			bmd.lock();
			for( var i:int = 0; i < 445; i += 2)
			{
				bmd.setPixel( i, 0, 0xdadada );
			}
			bmd.unlock();
			_bottomLine = new Bitmap( bmd );
			
			_username.x = 55;
			_text.x = 55;
			_text.y = 18;
			//計算無理矢理でごめんなさい
			_bottomLine.y = bottom = (( _text.y + _text.height ) > 45 ) ? _text.y + _text.height + 7 : 53;
			
			addChild( _username );
			addChild( _text );
			addChild( _bottomLine );
			
			var col:uint = isOdd ? 0xffffff : 0xf2f2f2;
			_bg = new Shape();
			_bg.graphics.beginFill( col );
			_bg.graphics.drawRect( -5, -5, 450, _bottomLine.y + 5 );
			_bg.graphics.endFill();
			addChildAt( _bg, 0 );
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		private function _ioErrorHandler( e:IOErrorEvent ):void
		{
			e.target.removeEventListener( IOErrorEvent.IO_ERROR, _ioErrorHandler );
			trace( "error");
		}
		
		private function _iconLoadedHandler( e:Event ):void
		{
			e.target.removeEventListener( Event.COMPLETE, _iconLoadedHandler );
			_icon = new Bitmap( Bitmap( _loader.content).bitmapData );
			addChild( _icon );
		}
		
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private var _loader:Loader;
		private var _icon:Bitmap;
		private var _username:TextField;
		private var _text:TextField;
		private var _bottomLine:Bitmap;
		private var _bg:Shape;
	}
}