package com.chatterwebs{
	// ActionScript file
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.controls.*;
	import mx.core.Application;
	import mx.events.FlexEvent;
	public class EntryPage extends Application{
		//UI objects
		public var category:ComboBox;
		public var username:TextInput;
		public var memberList:List;
		public var startSessionBtn:Button;
		public var buttonEnter:Button;
		
		private var connection:ConnectionManager;
		private var sessionURL:String = 'http://chatterwebs.appspot.com';
		
		public function EntryPage()
		{
			addEventListener(FlexEvent.APPLICATION_COMPLETE,mainInit);
		} 
		
		private function mainInit(event:FlexEvent):void
		{
			loadGroupList();
		}
		
		// == BEGIN Populate Groups drop-down ComboBox =========================================================
		private function loadGroupList():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, groupListLoaded);
			loader.load(new URLRequest(sessionURL+'/group/?mimetype=xml')); // Load xml file of available groups
		}
		private function groupListLoaded(e:Event):void{
		    var xmlObj:XML = new XML(e.target.data);
			category.dataProvider = xmlObj.Group;                           // Insert groups in COmboBox
			category.labelField = "@name";	                                // @ name attribute
		}
		// == END Populate Groups drop-down ComboBox ===========================================================
		
		
		// == BEGIN Session Manager ============================================================================
		public function connect():void
		{
			var group_id:String = category.selectedItem.@id;
			connection = new ConnectionManager(username.text,group_id, null); 	// start connection
			
			var updateTimer:Timer = new Timer(1000, 1000);
			updateTimer.addEventListener(TimerEvent.TIMER, updateInfo);
			updateTimer.start();
			
			startSessionBtn.enabled = false; 								  	// No multiple sessions
		}
		//---- Group Info Update ----
		private function updateInfo(e:TimerEvent):void
		{
			updateGroupInfo();
		}
		public function updateGroupInfo():void
		{
			var group_id:String = category.selectedItem.@id;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, setGroupInfo);
			loader.load(new URLRequest(sessionURL+'/group/'+ group_id +'/?mimetype=xml'));
		}
		private function setGroupInfo(e:Event):void
		{
		    var group:XML = new XML(e.target.data);
			memberList.dataProvider = group.Guest;
			memberList.labelField = "@name";
			
		}
		// == END Session Manager ==============================================================================
		
		
		//---- END Group Info Update ----
		/** 
		* enter is called whenever the buttonEnter is pressed
		*/
		public function enter():void
		{
			//navigateToURL(new URLRequest("file:///C:/Users/Sandi/Documents/Flex Builder 3/FlexChat/bin-debug/main.html?#userName="+user_txt.text+"&seatNumber="+seatNumber), "_blank");
			navigateToURL(new URLRequest("main.html?#userName="+username.text+"&guest_id="+connection.guest_id+"&group_id="+connection.group_id), "_top");
		}
	}
}