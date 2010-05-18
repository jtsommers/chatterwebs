package com.chatterwebs
{
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;

	public class StreamingVideoPlayer extends UIComponent
	{
		private var nsPlay:NetStream = null;
		private var videoRemote:Video;
		private var mute:Boolean = false;
		
		
		public function StreamingVideoPlayer()
		{
			super();
			videoRemote = new Video(160,120);
			this.addChild(videoRemote);
			this.addEventListener(ResizeEvent.RESIZE, resizeVideo);
		}
		
		
		// change the video size by passing in a new width and height for the video
		public function changeVideoSize(newWidth:uint, newHeight:uint):void
		{
			this.width = newWidth;
			this.height = newHeight;
			this.removeChild(videoRemote);
			videoRemote = new Video(newWidth, newHeight);
			this.addChild(videoRemote);
		}
		
		private function resizeVideo(e:ResizeEvent):void
		{
			videoRemote.width = this.width;
			videoRemote.height = this.height;
		}
		
		// Mute the volume of an incoming stream
		private function toggleMute():Boolean
		{
			mute = !mute;
			var transform:SoundTransform = new SoundTransform();
			if(mute)
			{
				transform.volume = 0;
				nsPlay.soundTransform = transform;
			}else
			{
				nsPlay.soundTransform = transform;
			}
			
			return mute;
		}
		
		// function to start a video stream from a string stream name.
		// use the NetConnection reference from the main application window
		public function subscribe(streamIdentifier:String, nc:NetConnection):void
		{
			if(nc != null)
			{
				// connection is valid, create the video stream
				nsPlay = new NetStream(nc);	
		
				// set the buffer time to zero since it is chat
				nsPlay.bufferTime = 0;
				
				// subscribe to the named stream
				nsPlay.play(streamIdentifier);
				
				// attach to the stream
				videoRemote.attachNetStream(nsPlay);
			}
		}
		
		
		//stop playing a video stream (with the stop button)
		public function unsubscribe():void
		{
			videoRemote.attachNetStream(null);
			nsPlay.play(null);
			nsPlay.close();
		}
		
		//destroy a video stream (by disconnecting from the media server)
		public function killStream():void
		{
			this.unsubscribe();
			videoRemote.clear();
		}
		
	}
}