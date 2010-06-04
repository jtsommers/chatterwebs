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
		private var guest_list:Array = [];
		
		private var rootURL:String = 'http://chatterwebs.appspot.com';
		private var updateURL:String = rootURL + '/update/guest/group.xml?'; 
		private var guestURL:String = rootURL + '/new/guest/guest.xml?'; 
		
		public var eDispatcher : EventDispatcher = new EventDispatcher(); 
		public static const GROUP_CHANGED:String = "Group List Changed";
		public static const SESSION_STARTED:String = "Session Started";
		public static const MILLISECOND_UPDATE:uint = 2000;
		
		private var timeOut:Timer;
		
		public function ConnectionManager(nickname:String, group_id:String, guest_id:String)
		{
			timeOut = new Timer(2*MILLISECOND_UPDATE);
			timeOut.addEventListener(TimerEvent.TIMER, sessionTimeOut);
			this.group_id = group_id;
			this.guest_id = guest_id;
			this.nickname = nickname;
			if(guest_id == null)
				startNewSession();
			else
				resumeSession();
		}
		
		//---- Main Session Handler ----
		private function resumeSession():void
		{
			var guestTimer:Timer = new Timer(MILLISECOND_UPDATE, 1000000);
			guestTimer.addEventListener(TimerEvent.TIMER, keepAlive);
			guestTimer.start();
		}
		private function keepAlive(e:TimerEvent):void
		{
			guest_list = null;			//clears the guest list if loader fails to respond
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, refreshSessionData);
			loader.load(new URLRequest(updateURL + 'guest_id=' + guest_id + '&group_id=' + group_id));
		}
		//---- END Main Session Handler ----
		
		
		//---- Get new Guest ID, then call Main Session Handler ----
		private function startNewSession():void
		{	
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, newSessionStarted);
			loader.load(new URLRequest(guestURL+'nickname='+nickname+'&group_id='+group_id));
		}
		private function newSessionStarted(e:Event):void
		{
		    var guest:XML = new XML(e.target.data);
		    guest_id = guest.@id;	
		    nickname = guest.@nickname;
		    resumeSession();
		    eDispatcher.dispatchEvent(new Event(SESSION_STARTED));
		}
		//---- END Get new Guest ID ----
		
		// Update group List !!!! - Do something if connection has been lost !!!!!!!!!!!!!!!!! Do THIS
		private function refreshSessionData(e:Event):void
		{
			var group:XML = new XML(e.target.data);
			var sn:String = group.@serialnumber;
			var guests:XMLList = group.seats.guest;
			var temp_guest_list:Array = new Array();
			for each(var guest:XML in guests)
			{
				temp_guest_list.push(guest.@nickname)
			}
			guest_list = temp_guest_list;
			eDispatcher.dispatchEvent(new Event(GROUP_CHANGED));
			timeOut.reset();
			timeOut.start();
		}
		
		private function sessionTimeOut(e:Event):void
		{
			guest_list = null;
			eDispatcher.dispatchEvent(new Event(GROUP_CHANGED));
		}
		
		public function get groupID():String
		{
			return group_id;
		}
		
		public function get guestID():String
		{
			return guest_id;
		}
		
		public function get nickName():String
		{
			return nickname;
		}
		
		public function get guestList():Array
		{
			return guest_list;
		}
	}
}