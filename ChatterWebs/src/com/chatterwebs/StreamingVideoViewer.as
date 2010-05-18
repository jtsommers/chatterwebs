package com.chatterwebs
{
	import flash.geom.Rectangle;
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
		private var labelCanvas:Canvas = new Canvas();
		
		private var defaultWidth:uint = 172;
		
		public function StreamingVideoViewer()
		{
			super();
			this.visible = false;
			player = new StreamingVideoPlayer();
			player.move(0,0);
			userLabel = new Label();
			userLabel.styleName = "UserFeedLabel";
			userLabel.setStyle("textAlign", "center");
			resize(defaultWidth);
			this.addChild(player);
			this.addChild(labelCanvas);
			labelCanvas.styleName = "StreamLabelCanvas";
			labelCanvas.setStyle("borderColor", "#757677");
			labelCanvas.setStyle("borderStyle", "solid");
			labelCanvas.setStyle("backgroundColor", "#7F8886");
			labelCanvas.setStyle("backgroundAlpha", ".2");
			labelCanvas.addChild(userLabel);
		}
		
		public function subscribe(u:String, netC:NetConnection):void
		{
			nc = netC;
			this.visible = true;
			setUser(u);
		}
		
		public function killStream():void
		{
			if(username != null)
			{
				player.killStream();
				setUser(null);
				this.visible = false;
			}
		}
		
		public function get nickname():String
		{
			return username;
		}
		
		public function setUser(u:String):void
		{
			if(u == null)
			{
				this.visible = false;
			}
			username = u;
			userLabel.text = username;
			player.subscribe(u, nc);
		}
		
		public static function calculateDimensions(numStreams:uint, containerDimensions:Rectangle):Rectangle
		{
			var containerWidth:uint = containerDimensions.width;
			var containerHeight:uint = containerDimensions.height;
			var usableWidth:uint = containerWidth;
			var usableHeight:uint = containerHeight;
			var numRows:uint = 1;
			if(numStreams <= 3)
			{
				numRows = 1;
				usableWidth -= numStreams*5+5;
				usableWidth /= numStreams;
				if(usableWidth > 320)
				{
					usableWidth = 320;			//set a maximum practical width
				}
				usableHeight = 3*usableWidth/4;
			}else if (numStreams <= 6)
			{
				numRows = 2;
				usableHeight -= numRows*5+5;
				usableHeight /= numRows;
				if(usableHeight > 240)
				{
					usableHeight = 240;
				}
				usableWidth = 4*usableHeight/3;
			}else if (numStreams <= 8)
			{
				var firstRowVids:uint = 4;
				numRows = 2;
				usableWidth -= firstRowVids*5+5;
				usableWidth /= firstRowVids;
				usableHeight = 3*usableWidth/4;
			}else
			{
				usableWidth = 160;
				usableHeight = 120;
			}
			return new Rectangle(0, 0, usableWidth, usableHeight);
		}
		
		//dummy resize function does basic resizing of components
		public function resize(w:uint, h:uint = 0):void
		{
			if(h == 0)
			{
				//auto calculate height from width and standard ratio plus height of label
				h = 3*w/4;
			}
			this.setActualSize(w, h);
			player.changeVideoSize(w, h);	//set video size to new size of the container minus label area 
			userLabel.setActualSize(w, 20);
			labelCanvas.setActualSize(w, 20);
			labelCanvas.move(0, h-20);
			userLabel.move(5, 0);
			userLabel.width = labelCanvas.width-10;
		}
		
		//resize function (animates to new size)
		public function animatedResize(w:uint, h:uint = 0):void
		{
			if(h == 0)
			{
				//auto calculate height from width and standard ratio 4:3 plus space for label
				h = 3*w/4;
			}
			this.setActualSize(w, h);
			var videoResize:Resize = new Resize(player);
			videoResize.heightFrom = player.width;
			videoResize.heightFrom = player.height;
			videoResize.widthTo = w;
			videoResize.heightTo = (h);
			var labelCanvasResize:Resize = new Resize(labelCanvas);
			labelCanvasResize.heightFrom = labelCanvas.width;
			labelCanvasResize.heightFrom = labelCanvas.height;
			labelCanvasResize.widthTo = w;
			labelCanvasResize.heightTo = userLabel.height;
			var labelResize:Resize = new Resize(userLabel);
			labelResize.heightFrom = userLabel.width;
			labelResize.heightFrom = userLabel.height;
			labelResize.widthTo = w-10;
			labelResize.heightTo = userLabel.height;
			var labelMove:Move = new Move(labelCanvas);
			labelMove.yFrom = labelCanvas.y;
			labelMove.yTo = (h-20);
			videoResize.play();
			labelCanvasResize.play();
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