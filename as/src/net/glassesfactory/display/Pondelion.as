/*////////////////////////////////////////////

TwitterXDomainSample

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2010/09/05

Copyright 2010 glasses factory
http://glasses-factory.net

/*////////////////////////////////////////////

package net.glassesfactory.display
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	
	public class Pondelion extends MovieClip
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		
		/*/////////////////////////////////
		* getter
		/*/////////////////////////////////
		
		
		/*/////////////////////////////////
		* setter
		/*/////////////////////////////////
		
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function Pondelion()
		{
			super();
			_circles = [];
			for( var i:int = 0; i < 8; i++ )
			{
				var sp:Shape = new Shape();
				sp.graphics.beginFill( 0x666666 );
				sp.graphics.drawCircle( 0, 0, 2 );
				sp.graphics.endFill();
				var angle:Number = i / 8 * Math.PI * 2; 
				sp.x = Math.cos( angle ) * 10;
				sp.y = Math.sin( angle ) * 10;
				sp.alpha = 0.5;
				addChild( sp );
				_circles.push( sp );
			}
			_circles[0].alpha = 1;
			var timer:Timer = new Timer(  80 );
			timer.addEventListener( TimerEvent.TIMER, _enterFrameHandler );
			timer.start();
		}
		
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		private function _enterFrameHandler( e:TimerEvent ):void
		{
			this.rotation += 45;
		}
		
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private var _circles:Array;
	}
}