/*////////////////////////////////////////////

GFGAETWeet

Autor	YAMAGUCHI EIKICHI
(@glasses_factory)
Date	2011/04/08

Copyright 2010 glasses factory
http://glasses-factory.net

/*////////////////////////////////////////////

package
{
	import de.aggro.utils.CookieUtil;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import net.alumican.as3.ui.justputplay.scrollbars.JPPScrollbar;
	import net.glassesfactory.display.InviteAuth;
	import net.glassesfactory.display.Pondelion;
	import net.glassesfactory.display.TweetView;
	import net.glassesfactory.events.GFAMFClientEvent;
	import net.glassesfactory.net.GFAMFClient;
	
	[SWF(width="465", height="465")]
	public class GFGAETWeet extends Sprite
	{
		/*/////////////////////////////////
		* public variables
		/*/////////////////////////////////
		
		
		/*/////////////////////////////////
		* public methods
		/*/////////////////////////////////
		
		//Constractor
		public function GFGAETWeet()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			//js に  swf ID を渡しておく
			ExternalInterface.call('setSwfName', ExternalInterface.objectID );
			
			//デバッグとリリースビルドで切り替え
			var gateway:String = "http://gf-gaetweet.appspot.com/gateway";
			CONFIG::debug
			{
				gateway = "http://127.0.0.1:8080/gateway";
			}
			
			_amf = new GFAMFClient( gateway );
			CONFIG::debug{ _amf.debug = true; }
			
			//サービスを登録
			_amf.registerService( 'load', 'tweetutil.load' );
			_amf.registerService( 'update', 'tweetutil.update' );
			_amf.registerService( 'isAuth', 'tweetutil.isAuth' );
			
			//エラーハンドリング
			_amf.addEventListener( IOErrorEvent.IO_ERROR, _ioErrorHandler );
			_amf.addEventListener( SecurityErrorEvent.SECURITY_ERROR, _securityErrorHandler );
			_amf.addEventListener( AsyncErrorEvent.ASYNC_ERROR, _asyncErrorHandler );
			
			//認証済みかチェック
			_sid = CookieUtil.getCookie('KAY_SESSION').toString();
			_amf.addEventListener( GFAMFClientEvent.COMPLETE, _initHandler );
			_amf.isAuth( _sid );
			
		}
		
		/*/////////////////////////////////
		* private methods
		/*/////////////////////////////////
		
		/**
		 * 認証済みかどうかがチェックできたら初期化
		 * @param e GFAMFClientEvent
		 */		
		private function _initHandler( e:GFAMFClientEvent ):void
		{
			_amf.removeEventListener(GFAMFClientEvent.COMPLETE, _initHandler );
			
			_isAuth = e.result as Boolean;
			
			if( _isAuth )
			{
				//認証済みなら view の構築に入りつつ、tweet の読み込み
				_createStaticView();
				_loadTweet();
			}
			else
			{
				//未認証なら認証を促す
				_inviteAuth();
			}
		}
		
		/**
		 * 認証を促す。 
		 * Login ボタンを表示
		 */		
		private function _inviteAuth():void
		{
			//OAuth のコールバック後に呼ばれるメソッドを登録
			ExternalInterface.addCallback( "callback", _callBackOAuth );
			_authBtn = new InviteAuth();
			_authBtn.x = 465 * .5 - _authBtn.width * .5;
			_authBtn.y = 465 * .5 - _authBtn.height * .5;
			addChild( _authBtn );
		}
		
		
		/**
		 * スクロールバーとか入力エリアとか
		 * Win での調整はしてないです。 
		 */		
		private function _createStaticView():void
		{
			//--- main container ---
			_container = new Sprite();
			_mask = new Sprite();
			_mask.graphics.beginFill( 0 );
			_mask.graphics.drawRect( 0, 0, 440, 400 );
			_mask.graphics.endFill();
			
			_container.mask = _mask;
			
			//--- text input area ---
			_textAreaBG = new Shape();
			_textAreaBG.graphics.lineStyle( 1, 0x333333 );
			_textAreaBG.graphics.drawRect( 0, 0, 385, 75 );
			_textAreaBG.graphics.endFill();
			_textAreaBG.x = 5;
			_textAreaBG.y = 405;
			
			_textArea = new TextField();
			_textArea.type = TextFieldType.INPUT;
			_textArea.multiline = true;
			_textArea.wordWrap = true;
			_textArea.width = 385;
			_textArea.height = 75;
			_textArea.x = 5;
			_textArea.y = 405;
			
			addChild( _textAreaBG );
			addChild( _textArea );
			
			_tweetBtn = new DoTweet();
			_tweetBtn.x = 395;
			_tweetBtn.y = 405;
			_tweetBtn.buttonMode = true;
			_tweetBtn.addEventListener(MouseEvent.MOUSE_OVER, function( e:MouseEvent ):void{ _tweetBtn.alpha = 0.7; });
			_tweetBtn.addEventListener(MouseEvent.MOUSE_OUT, function( e:MouseEvent ):void{ _tweetBtn.alpha = 1; });
			_tweetBtn.addEventListener(MouseEvent.CLICK, function( e:MouseEvent ):void
			{
				if( _isLoading ){ return; }
				if( _textArea.text != null )
				{
					//入力エリアのテキストをツイート
					_amf.addEventListener(GFAMFClientEvent.COMPLETE, _tweetCompleteHandler );
					_amf.update( _sid, _textArea.text );
					_textArea.text = "";
				}
			});
			addChild( _tweetBtn );
			
			
			//--- scrollbar ---
			_scrollBar = new JPPScrollbar( stage );
			_scrollBox = new Sprite();
			
			_base = new Sprite();
			_base.graphics.beginFill( 0, 0 );
			_base.graphics.drawRect( 0, 0, 20, 400 );
			_base.graphics.endFill();
			
			_slider = new Sprite();
			_slider.graphics.beginFill( 0xff0000 );
			_slider.graphics.drawRect( 0, 0, 20, 100 );
			_slider.graphics.endFill();
			
			_slideInner = new Shape();
			_slideInner.graphics.beginFill( 0xffffff );
			_slideInner.graphics.drawRect( 0, 0, 18, 98 );
			_slideInner.graphics.endFill();
			_slideInner.x = 1;
			_slideInner.y = 1;
			_slider.addChild( _slideInner );
			
			_scrollBox.addChild( _base );
			_scrollBox.addChild( _slider );
			_scrollBox.x = 445;
			
			_scrollBar.base = _base;
			_scrollBar.slider = _slider;
			_scrollBar.useFlexibleSlider = true;
			_scrollBar.useOvershoot = true;
			_scrollBar.minSliderHeight = 80;
			addChild( _scrollBox );
		}
		
		
		/**
		 * 認証後、js から呼ばれる 
		 */		
		private function _callBackOAuth():void
		{
			_sid = CookieUtil.getCookie('KAY_SESSION').toString();
			removeChild( _authBtn );
			_createStaticView();
			_loadTweet();
		}
		
		
		/**
		 * tweet を読み込み 
		 * 
		 */		
		private function _loadTweet():void
		{
			_isLoading = true;
			_ponde = new Pondelion();
			_ponde.x = 465 * .5
			_ponde.y = 200;
			addChild( _ponde );
			
			if( _container.numChildren > 0 )
			{
				while( _container.numChildren ){ _container.removeChildAt(0);}
			}
			_amf.addEventListener(GFAMFClientEvent.COMPLETE, _loadedTweetHandler );
			_amf.load(_sid);
		}
		
		/**
		 * tweet 読み込み完了 
		 * @param e
		 */		
		private function _loadedTweetHandler( e:GFAMFClientEvent ):void
		{
			_amf.removeEventListener(GFAMFClientEvent.COMPLETE, _loadedTweetHandler );
			
			var models:Array = e.result as Array;
			var yPos:Number = 5;
			var isOdd:Boolean = false;
			for( var i:int = 0;  i < models.length; i++ )
			{
				if( i % 2 != 0 ){ isOdd = true; }
				else{ isOdd = false; }
				var tweets:TweetView = new TweetView( models[i].username, models[i].status, models[i].icon, isOdd );
				tweets.x = 5;
				tweets.y = yPos;
				//計算無理やりでごめんなさい
				yPos = tweets.y + tweets.bottom + 6;
				_container.addChild( tweets );
			}
			addChild( _container );
			addChild( _mask );
			removeChild( _ponde );
			
			_scrollBar.setup(
				_container, 'y', _container.height, _mask.height, _container.y, _container.y - ( _container.height - _mask.height - 50 )
			);
			_isLoading = false;
		}
		
		
		/**
		 * tweet を post 後もう一度読み込んで更新 
		 * @param e
		 * 
		 */		
		private function _tweetCompleteHandler( e:GFAMFClientEvent ):void
		{
			_amf.removeEventListener(GFAMFClientEvent.COMPLETE, _tweetCompleteHandler );
			_loadTweet();
		}
		
		
		/*====================================
		* Error Handlers
		=====================================*/
		
		/**
		 * 本当はちゃんと処理しなきゃだめなんだぜ！ 
		 * @param e
		 */		
		
		private function _ioErrorHandler( e:IOErrorEvent ):void
		{
			//io error
		}
		
		private function _securityErrorHandler( e:SecurityErrorEvent ):void
		{
			//security error
		}
		
		private function _asyncErrorHandler( e:AsyncErrorEvent ):void
		{
			//asyncerror
		}
		
		
		/*/////////////////////////////////
		* private variables
		/*/////////////////////////////////
		
		private var _amf:GFAMFClient;
		private var _sid:String;
		private var _isAuth:Boolean;
		private var _isLoading:Boolean;
		
		//--- UI ---
		private var _authBtn:InviteAuth;
		private var _container:Sprite;
		private var _mask:Sprite;
		private var _ponde:Pondelion;
		private var _scrollBar:JPPScrollbar;
		private var _scrollBox:Sprite;
		private var _base:Sprite;
		private var _slider:Sprite;
		private var _slideInner:Shape;
		
		private var _textArea:TextField;
		private var _textAreaBG:Shape;
		private var _tweetBtn:DoTweet = new DoTweet();
	}
}