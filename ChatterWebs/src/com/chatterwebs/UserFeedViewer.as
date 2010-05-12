package com.chatterwebs
{
	import flash.events.*;
	import flash.net.NetConnection;
	
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Label;
	import mx.core.UIComponent;

	public class UserFeedViewer extends UIComponent
	{
		private var username:String;
		private var mirror:UserFeed;
		private var yourCamera:Label;
		private var nc:NetConnection;
		private var canvas:Canvas;
		private var minimize:Button;
		private var maximize:Button;
		private var mute:Button;
		
		public function UserFeedViewer()
		{
			super();
			//maximize/minimize button setup
			showAndHideButtonSetup();
			//container setup
			canvasSetup();
			//setup user's outgoing feed
			mirrorSetup();
			//setup display label
			labelSetup();
			//setup mute button
			muteButtonSetup();
		}
		
		public function publish(u:String, netC:NetConnection):void
		{
			username = u;
			nc = netC;
			mirror.startCamera();
			mirror.displayCamera();
			mirror.publish(username, nc);
			mute.enabled = true;
		}
		
		public function isVisible():Boolean
		{
			return canvas.visible;
		}
		
		public function kill():void
		{
			mirror.killFeed();
			mirror.killMirror();
		}
		
		private function showAndHideButtonSetup():void
		{
			minimize = new Button();
			minimize.styleName = "Minimize";
			minimize.label = "-";
			minimize.toolTip = "";
			minimize.move(134, 0);
			minimize.setActualSize(36, 18);
			minimize.addEventListener(MouseEvent.CLICK, minimizeClicked);
			this.addChild(minimize);
			maximize = new Button();
			maximize.styleName = "Maximize";
			maximize.label = "Show Your Camera";
			maximize.move(0, 155);
			maximize.setActualSize(180, 22);
			maximize.visible = false;
			maximize.addEventListener(MouseEvent.CLICK, maximizeClicked);
			this.addChild(maximize);
		}
		
		private function canvasSetup():void
		{
			canvas = new Canvas();
			canvas.styleName = "UserFeedCanvas";
			canvas.setStyle("borderColor", "#757677");
			canvas.setStyle("borderStyle", "solid");
			canvas.setStyle("backgroundColor", "#7F8886");
			canvas.setStyle("backgroundAlpha", ".4");
			canvas.move(0, 17);
			canvas.setActualSize(180, 160);
			this.addChild(canvas);
		}
		
		private function mirrorSetup():void
		{
			mirror = new UserFeed();
			mirror.move(10,10);
			mirror.setActualSize(160, 120);
			canvas.addChild(mirror);
		}
		
		private function labelSetup():void
		{
			yourCamera = new Label();
			yourCamera.width = 160;
			yourCamera.height = 20;
			yourCamera.text = "Your Camera";
			yourCamera.styleName = "UserFeedLabel";
			canvas.addChild(yourCamera);
			yourCamera.move(0, 130);
		}
		
		private function muteButtonSetup():void
		{
			mute = new Button();
			mute.styleName = "Mute";
			mute.toggle = true;
			mute.width = 35;
			mute.height = 35;
			mute.move(136, 10);
			mute.label = "";
			mute.toolTip = "Mute";
			mute.enabled = false;
			mute.addEventListener(MouseEvent.CLICK, toggleMute);
			canvas.addChild(mute);
		}
		
		private function minimizeClicked(e:Event):void
		{
			minimize.visible = false;
			canvas.visible = false;
			maximize.visible = true;
		}
		
		private function maximizeClicked(e:Event = null):void
		{
			maximize.visible = false;
			canvas.visible = true;
			minimize.visible = true;
		}
		
		private function toggleMute(e:Event = null):void
		{
			if(mute.selected)
			{
				mute.toolTip = "Unmute";
			}
			else
			{
				mute.toolTip = "Mute";
			}
			mirror.toggleMute();
		}
	}
}