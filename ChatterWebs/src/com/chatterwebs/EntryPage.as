package com.chatterwebs{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	
	import mx.containers.Canvas;
	import mx.controls.*;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	import mx.managers.BrowserManager;
    import mx.managers.IBrowserManager;
    import mx.utils.URLUtil;
	
	public class EntryPage extends Application{
		//UI objects
		public var category:ComboBox;
		public var container:Canvas;
		public var username:TextInput;
		public var memberList:List;
		public var startSessionBtn:Button;
		public var buttonEnter:Button;
		public var customIP:String;
		
		private var bm:IBrowserManager;
		
		private var connection:ConnectionManager;
		private var rootURL:String = 'http://chatterwebs.appspot.com';
		//private var rootURL:String = 'http://localhost:8082';
		
		public function EntryPage()
		{
			addEventListener(FlexEvent.APPLICATION_COMPLETE,mainInit);
		} 
		
		private function mainInit(event:FlexEvent):void
		{
			loadGroupList();
			username.addEventListener(KeyboardEvent.KEY_UP, userNameEntered);
			username.addEventListener(MouseEvent.CLICK, userNameFocused);
			username.addEventListener(FocusEvent.FOCUS_OUT, userNameUnFocused);
			buttonEnter.addEventListener(MouseEvent.CLICK,connect);
			
			//parse extra URL parameters (ip address and nickname if applicable)
			bm = BrowserManager.getInstance();                
            bm.init("", "Welcome!");
			var o:Object = URLUtil.stringToObject(bm.fragment, "&");
        	customIP = o.ip;
        	if(o.nickname)
        	{
        		//nickname parameter passed in (presumably through connection time out and being booted back to the entry page)
        		username.text = o.nickname;
        		buttonEnter.enabled = true;
        	}
		}
		
		private function userNameEntered(e:Event):void
		{
			if((username.text != "") && (username.text != "Screen Name"))
			{
				buttonEnter.enabled = true;
			}else{
				buttonEnter.enabled = false;
			}
		}
		
		private function userNameFocused(e:Event):void
		{
			
			if(username.text == "Screen Name")
			{
				username.text = "";		
			}
		}
		
		private function userNameUnFocused(e:Event):void
		{
			if(username.text == "")
			{
				username.text = "Screen Name";
				buttonEnter.enabled = false;
			}
			
		}
		
		// == BEGIN Populate Groups drop-down ComboBox =========================================================
		private function loadGroupList():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, groupListLoaded);
			loader.load(new URLRequest(rootURL+'/index.xml')); 		// Load xml file of available groups
		}
		private function groupListLoaded(e:Event):void{
		    var xmlObj:XML = new XML(e.target.data);
			category.dataProvider = xmlObj.group;                       // Insert groups in ComboBox
			category.labelField = "@nickname";	                        // @ nickname attribute
		}
		// == END Populate Groups drop-down ComboBox ===========================================================
		

		// == BEGIN Session Manager ============================================================================
		public function connect(e:Event):void
		{
			buttonEnter.enabled = false;
			var group_id:String = category.selectedItem.@id;
			connection = new ConnectionManager(username.text,group_id, null); 	// start connection
			connection.eDispatcher.addEventListener(ConnectionManager.SESSION_STARTED, enter);
		}
		// == END Session Manager ==============================================================================
		
		
		//---- END Group Info Update ----
		/** 
		* enter is called whenever the buttonEnter is pressed after session manager has validly started
		*/
		public function enter(e:Event):void
		{
			if(customIP)
			{
				navigateToURL(new URLRequest("main.html?#nickname="+username.text+"&guest_id="+connection.guest_id+"&group_id="+connection.group_id+"&ip="+customIP), "_top");
			}else
			{
				navigateToURL(new URLRequest("main.html?#nickname="+username.text+"&guest_id="+connection.guest_id+"&group_id="+connection.group_id), "_top");
			}
		}
	}
}