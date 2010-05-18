package com.chatterwebs
{
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;

	public class UserFeed extends UIComponent
	{
		private var camera:Camera;
		private var microphone:Microphone;
		private var nsPublish:NetStream = null; 
		private var videoCamera:Video;
		private var mute:Boolean = false;
		
		
		public function UserFeed()
		{
			super();
			videoCamera = new Video(160,120);
			this.addChild(videoCamera);
		}
		
		public function startCamera():void
		{	
			// get the default Flash camera and microphone
			camera = Camera.getCamera();
			microphone = Microphone.getMicrophone();
		
			// here are all the quality and performance settings that we suggest
			camera.setMode(160, 120, 12, false);
			camera.setQuality(0, 75);
			camera.setKeyFrameInterval(24);
			microphone.rate = 11;
			microphone.setSilenceLevel(0);
		}
		
		public function doubleResolution():void
		{
			camera.setMode(320, 240, 12, false);
		}
		
		public function normalResolution():void
		{
			camera.setMode(160, 120, 12, false);
		}
		
		public function resize(newWidth:uint, newHeight:uint):void
		{
			this.removeChild(videoCamera);
			videoCamera = new Video(newWidth, newHeight);
			this.addChild(videoCamera);
			camera.setMode(newWidth, newHeight, 12, false);
		}
		
		public function toggleHide():void
		{
			videoCamera.visible = !videoCamera.visible;
		}
		
		public function displayCamera():void
		{
			videoCamera.clear();
			videoCamera.attachCamera(camera);
		}
		
		public function publish(streamIdentifier:String, nc:NetConnection):void
		{
			// create a new NetStream object for video publishing
			nsPublish = new NetStream(nc);
			
			// set the buffer time to zero since it is chat
			nsPublish.bufferTime = 0;
		
			// publish the stream by name
			nsPublish.publish(streamIdentifier);
	
			// attach the camera and microphone to the server
			nsPublish.attachCamera(camera);
			nsPublish.attachAudio(microphone);
		}
		
		public function toggleMute():Boolean
		{
			mute = !mute
			if(mute)
			{
				nsPublish.attachAudio(null);
			}else
			{
				nsPublish.attachAudio(microphone);
			}
			return mute;
		}
		
		public function killMirror():void
		{
			videoCamera.attachCamera(null);
			videoCamera.clear();
		}
		
		public function killFeed():void
		{
			nsPublish.attachCamera(null);
			nsPublish.attachAudio(null);
			nsPublish.publish("null");
			nsPublish.close();
		}
		
	}
}