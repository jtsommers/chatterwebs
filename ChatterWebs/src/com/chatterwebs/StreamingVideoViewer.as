package com.chatterwebs
{
	import flash.net.NetConnection;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.effects.Resize;

	public class StreamingVideoViewer extends UIComponent
	{
		private var username:String;
		private var player:StreamingVideoPlayer;
		private var userLabel:Label;
		private var nc:NetConnection;
		
		private var defaultWidth:uint = 160;
		
		public function StreamingVideoViewer()
		{
			super();
			player = new StreamingVideoPlayer();
			player.move(0,0);
			userLabel = new Label();
			userLabel.setStyle("textAlign", "center");
			resize(defaultWidth);
			this.addChild(player);
			this.addChild(userLabel);
		}
		
		public function subscribe(u:String, netC:NetConnection):void
		{
			nc = netC;
			setUser(u);
		}
		
		public function killStream():void
		{
			if(username != null)
			{
				player.killStream();
				setUser(null);
			}
		}
		
		public function get nickname():String
		{
			return username;
		}
		
		public function setUser(u:String):void
		{
			username = u;
			userLabel.text = username;
			player.subscribe(u, nc);
		}
		
		//dummy resize function does basic resizing of components
		public function resize(w:uint, h:uint = 0):void
		{
			if(h == 0)
			{
				//auto calculate height from width and standard ratio
				//TODO: proportions fix? currently does 4:3 video plus extra space for the username label.
				h = 3*w/4 + 20;
			}
			this.setActualSize(w, h);
			player.changeVideoSize(w, h - 20);	//set video size to new size of the container minus space for the 
			userLabel.setActualSize(w, 20);
			userLabel.move(0, h-20);
		}
		
		public function animatedResize(w:uint, h:uint = 0):void
		{
			var vResize:Resize = new Resize(player);
			
		}
		
	}
}