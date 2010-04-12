package com.chatterwebs
{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.controls.*;
	import mx.rpc.http.*;
	
	public class ConnectionManager
	{
		public var guest_id:String;
		public var group_id:String;
		public var nickname:String;
		private var rootURL:String = 'http://chatterwebs.appspot.com/';
		
		public function ConnectionManager(nickname:String, group_id:String, guest_id:String)
		{
			this.group_id = group_id;
			this.guest_id = guest_id;
			this.nickname = nickname;
			if(guest_id == null)
				getGuestID();
			else
				startSession();
		}
		
		//---- Session Handler ----
		private function startSession():void
		{
			var guestTimer:Timer = new Timer(10000, 1000);
			guestTimer.addEventListener(TimerEvent.TIMER, keepAlive);
			guestTimer.start();
		}
		private function keepAlive(e:TimerEvent):void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, getSessionStatus);
			loader.load(new URLRequest(rootURL+'/status/guest/'+ guest_id +'/?mimetype=xml&nickname='+nickname));
		}
		//---- END Session Handler ----
		
		//---- Guest ID Handler ----
		private function getGuestID():void
		{	
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, setGuestID);
			loader.load(new URLRequest(rootURL+'/guest/'+ group_id +'/?mimetype=xml&nickname='+nickname));
		}
		private function setGuestID(e:Event):void
		{
		    var guest:XML = new XML(e.target.data);
		    guest_id = guest.@id;	
		    startSession();
		}
		//---- END Guest ID Handler ----
	
		private function getSessionStatus(e:Event):void
		{
		   
		}

	}
}