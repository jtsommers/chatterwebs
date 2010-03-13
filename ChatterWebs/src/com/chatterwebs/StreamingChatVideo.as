package
{
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.core.UIComponent;

	public class StreamingChatVideo extends UIComponent
	{
		private var nsPlay:NetStream = null;
		private var videoRemote:Video;
		
		
		
		public function StreamingChatVideo()
		{
			super();
			videoRemote = new Video(160,120);
			this.addChild(videoRemote);
		}
		
		
		// change the video size by passing in a new width and height for the video
		public function changeVideoSize(width:uint, height:uint):void
		{
			this.removeChild(videoRemote);
			videoRemote = new Video(width, height);
			this.addChild(videoRemote);
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
			else
			{
				// net connection not established properly, add error message to component window
				//TODO: add error message
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
		public function destruct():void
		{
			this.unsubscribe();
			videoRemote.clear();
		}
		
	}
}