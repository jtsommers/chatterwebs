package com.chatterwebs
{
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class StreamingVideoPlayer extends Video
	{
		private var nsPlay:NetStream = null;
		private var videoRemote:Video;
		private var mute:Boolean = false;
		
		
		public function StreamingVideoPlayer()
		{
			super();
			this.width = 160;
			this.height = 120;
		}
		
		public function move(xpos:uint, ypos:uint):void
		{
			this.x = xpos;
			this.y = ypos
		}
		
		// change the video size by passing in a new width and height for the video
		public function changeVideoSize(newWidth:uint, newHeight:uint):void
		{
			this.width = newWidth;
			this.height = newHeight;
		}
		
		// Mute/Unmute the volume of an incoming stream
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
				this.attachNetStream(nsPlay);
			}
			else
			{
				// net connection not established properly, add error message to component window
				//TODO: add error message
			}
		}
		
		//stop playing a video stream (with the stop button)
		public function unsubscribe():void
		{
			this.attachNetStream(null);
			nsPlay.play(null);
			nsPlay.close();
		}
		
		//destroy a video stream (by disconnecting from the media server)
		public function killStream():void
		{
			this.unsubscribe();
			this.clear();
		}
		
	}
}