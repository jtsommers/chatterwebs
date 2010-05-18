package com.chatterwebs
{
	import flash.net.NetConnection;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.effects.*;

	public class StreamingVideoViewer extends UIComponent
	{
		private var username:String;
		private var player:StreamingVideoPlayer;
		private var userLabel:Label;
		private var nc:NetConnection;
		private var canvas:Canvas;
		
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
		
		private function canvasSetup():void
		{
			canvas = new Canvas();
			canvas.styleName = "UserFeedCanvas";
			canvas.setStyle("borderColor", "#757677");
			canvas.setStyle("borderStyle", "solid");
			canvas.setStyle("backgroundColor", "#7F8886");
			canvas.setStyle("backgroundAlpha", ".4");
			canvas.move(0, 0);
			canvas.setActualSize(170, 150);
			this.addChild(canvas);
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
				//auto calculate height from width and standard ratio plus height of label
				h = 3*w/4 + 20;
			}
			this.setActualSize(w, h);
			player.changeVideoSize(w, h - 20);	//set video size to new size of the container minus label area 
			userLabel.setActualSize(w, 20);
			userLabel.move(0, h-20);
		}
		
		public function animatedResize(w:uint, h:uint = 0):void
		{
			if(h == 0)
			{
				//auto calculate height from width and standard ratio 4:3 plus space for label
				h = 3*w/4 + 20;
			}
			this.setActualSize(w, h);
			var videoResize:Resize = new Resize(player);
			videoResize.heightFrom = player.width;
			videoResize.heightFrom = player.height;
			videoResize.widthTo = w;
			videoResize.heightTo = (h - 20);
			var labelResize:Resize = new Resize(userLabel);
			labelResize.heightFrom = userLabel.width;
			labelResize.heightFrom = userLabel.height;
			labelResize.widthTo = w;
			labelResize.heightTo = userLabel.height;
			var labelMove:Move = new Move(userLabel);
			labelMove.yFrom = userLabel.y;
			labelMove.yTo = (h - 20);
			videoResize.play();
			labelResize.play();
			labelMove.play();
		}
		
		public function animatedMove(x:uint, y:uint):void
		{
			var m:Move = new Move(this);
    		m.xFrom = this.x;
    		m.xTo = x;
    		m.yFrom = this.y;
    		m.yTo = y;
    		m.play();
		}
		
	}
}