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
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class InviteAuth extends Sprite
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function InviteAuth()
		{
			addChild( _view );
			
			_view.addEventListener(MouseEvent.MOUSE_OVER, _mouseOverHandler );
			_view.addEventListener(MouseEvent.MOUSE_OUT, _mouseOutHandler );
			_view.addEventListener(MouseEvent.CLICK, _mouseClickHandler );
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		
		private function _mouseOverHandler( e:MouseEvent ):void
		{
			_view.alpha = 0.7;
		}
		
		private function _mouseOutHandler( e:MouseEvent ):void
		{
			_view.alpha = 1;
		}
		
		private function _mouseClickHandler( e:MouseEvent ):void
		{
			//別窓立ち上げ。IE のポップアップブロック対策
			ExternalInterface.call('function(url){window.open(url, "oauth_window","width=550,height=450,scrollbars=no,resizable=no,status=no");}', '/oauth');
		}
		
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private var _view:AuthBtn = new AuthBtn();
	}
}