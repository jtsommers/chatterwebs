package com.chatterwebs
{
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	public class ChatPage extends Application
	{
		import mx.collections.*; 
		import flash.net.*;
		import flash.events.*;
		import flash.utils.*;
		import mx.controls.*;
		import mx.core.UIComponent;
		import mx.effects.*;

        // Current release of FMS only understands AMF0 so tell Flex to 
		// use AMF0 for all NetConnection, NetStream, and SharedObject objects.
		NetConnection.defaultObjectEncoding = flash.net.ObjectEncoding.AMF0;
		//NetStream.defaultObjectEncoding     = flash.net.ObjectEncoding.AMF0;
		SharedObject.defaultObjectEncoding  = flash.net.ObjectEncoding.AMF0;
		
		// echoResponder is used when nc.call("echo", echoResponder ...) is called.
		private var echoResponder:Responder = new Responder(echoResult, echoStatus);
		
		// SharedObject and NetConnection vars
		private var nc:NetConnection;
		public var ro:SharedObject;
        
        import mx.managers.BrowserManager;
        import mx.managers.IBrowserManager;
        import mx.utils.URLUtil;

        private var bm:IBrowserManager;
        private var nickname:String;
        private var guest_id:String;
        private var group_id:String;
       
        public var textChat:Canvas;
        public var feedArea:UIComponent;
        public var userNameMsg:Label;
        public var usersList:List;
        public var messageArea:TextArea;
        public var sendMessageInput:TextInput;
        public var selfFeed:UserFeedViewer;
        [Bindable] private var userStreams:Array = new Array();
        private var ip:String;
		private var sessionURL:String = 'http://chatterwebs.appspot.com';
		private var connection:ConnectionManager;
		private var groupXML:XML;
		private var textSharedName:String;
		private var connectOn:Boolean;
		public var guestList:Array = new Array();
		public var textChatObject:TextChat;
		public var textChatUserList:Array = new Array();
		
		public function ChatPage()
		{
			addEventListener(FlexEvent.APPLICATION_COMPLETE,mainInit);
		}
		
		private function mainInit(event:FlexEvent):void
		{
			// create new connection to FMS and add listeners
        	nc = new NetConnection();            	
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatus);
			nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, netSecurityError);

            bm = BrowserManager.getInstance();                
            bm.init("", "Welcome!");
            
            connectOn = true;
            connect();
            stage.focus = stage; //Set Focus to Messages
            sendMessageInput.addEventListener(FocusEvent.FOCUS_IN, goBlank);
            sendMessageInput.addEventListener(FocusEvent.FOCUS_OUT, fillIn);

            /* The following code will parse a URL that passes userName as
               query string parameters after the "#" sign; for example:
               http://www.chatterwebs.com/main.html?#nickname=Nick&ip=localhost */
               
            
            var o:Object = URLUtil.stringToObject(bm.fragment, "&");                
            
        	nickname = o.nickname;
        	ip = o.ip;
        	if(!nickname)
        	{
        		nickname = "Default User";
        	}
        	userNameMsg.text = "Welcome, " + nickname;
        	resumeSession();
        	
        	var xpos:uint = 10;
        	var ypos:uint = 27;
        	for (var i:uint = 0; i <7; i++)
        	{
        		var newStream:StreamingVideoViewer = new StreamingVideoViewer();
        		addChild(newStream);
        		newStream.move(xpos, ypos);
        		xpos += 168;
        		userStreams.push(newStream);
        	}
        	selfFeed.eDispatcher.addEventListener(UserFeedViewer.MINIMIZED, feedListener);
        	selfFeed.eDispatcher.addEventListener(UserFeedViewer.MAXIMIZED, feedListener);
        	guestList = connection.guestList;
		}
		
		
		// == BEGIN Session Management ============================================================================
		private function resumeSession():void{								  // Resume session from entry page 
			var o:Object = URLUtil.stringToObject(bm.fragment, "&");          // get URL   
			group_id = o.group_id;											  // get group_id
			guest_id = o.guest_id;											  // get guest_id
			connection = new ConnectionManager(nickname, group_id, guest_id); // set connection to session manager
			connection.eDispatcher.addEventListener(ConnectionManager.GROUP_CHANGED, groupListUpdated);										  //
		}
		private function groupListUpdated(e:Event):void
		{
			guestList = connection.guestList;
			updateStreams();
			//TODO: update user list in text chat window
			textChatUserList = new Array();
			for(var i:uint; i < guestList.length; i++)
			{
				textChatUserList.push({label: guestList[i], value:"user"+i});
			}
			this.usersList.dataProvider = textChatUserList;
		}
		// == END Session Management ===============================================================================
		
		
		
		/** 
		* videoChat is called whenever the button is pressed
		* and decides what to do based on the current label of the button.
		* NOTE: the rtmp address is in this function. Change it if you need to.
		*/
		public function videoChat():void
		{
			selfFeed.publish(nickname, nc);
			updateStreams();
		}
		
		public function updateStreams():void
		{
			for(var i:uint = 0; i < userStreams.length; i++)
			{
				var curStream:StreamingVideoViewer = (userStreams[i] as StreamingVideoViewer);
				var nick:String = curStream.nickname;
				if(nick != guestList[i])
				{
					curStream.killStream();
					curStream.subscribe(guestList[i], nc);
				}
			}
		}
		
		public function feedListener(e:Event):void
		{
			switch(e.type)
			{
				case UserFeedViewer.MINIMIZED:
					moveStreams(10);
					break;
				case UserFeedViewer.MAXIMIZED:
					moveStreams();
					break;
				default:
					break;
			}
		}
		
		public function moveStreams(start_x:uint = 200):void
		{
			var xpos:uint = start_x;
        	var ypos:uint = 27;
        	for (var i:uint = 0; i < userStreams.length; i++)
        	{
        		var stream:StreamingVideoViewer = (userStreams[i] as StreamingVideoViewer);
        		stream.animatedMove(xpos, stream.y);
        		xpos += 168;
        	}
		}
		
		public function resetVideo():void
        {
            for(var i:uint = 0; i < userStreams.length; i++)
            {
                    (userStreams[i] as StreamingVideoViewer).killStream();
                    (userStreams[i] as StreamingVideoViewer).subscribe(guestList[i], nc);
            }
        }
		
		public function killAllStreams():void
		{
			for(var i:uint = 0; i < userStreams.length; i++)
			{
				(userStreams[i] as StreamingVideoViewer).killStream();
			}
		}
		
       	/** 
         * connect is called when the the connection is created.
         * and decides what to do based on the current status of the boolean.
         * NOTE: the rtmp address defaults to localhost unless flashVars are present.
         * Both will be overridden if "ip" is present as a URL parameter.
         */
        public function connect():void
        {
        	switch(connectOn){
        		case true:
        			//connect to server using flashvars or if saddress is not present assume local server
        			var serverAddress:String = this.parameters.saddress;
        			serverAddress = (serverAddress) ? serverAddress : "rtmp://localhost/chatterWebs"; 
        			//if a specific IP address was passed in use that over the flashVar saddress
        			if(ip)
        			{
        				serverAddress = "rtmp://"+ip+"/chatterWebs";
        			}
        			nc.connect(serverAddress, nickname);
        			nc.client = this;
        			connectOn = false;
        		break;
        		case false:
        			nc.close();
        			var loadBack:String = "EntryPage.html";
        			var exitChatPage:URLRequest = new URLRequest(loadBack);
        			navigateToURL(exitChatPage, "_self");
        			selfFeed.kill();
        			killAllStreams();
        			break;
        		}
        }
        //============ functions for sendMessageInput====================//
        // Alter the state of the text in the field
        private function goBlank(event:FocusEvent):void
        {
        	sendMessageInput.text = "";
        }
        
        private function fillIn(event:FocusEvent):void
        {
        	sendMessageInput.text = 'Type your message then press "Enter"';
        }
        //===============================================================//
        
        
        // Disconnect user
        public function disconnect():void
        {
        	connectOn = false;
        	addMessage("<b>is disconnecting from ChatterWebs.</b>");
        	connect();
        }
        
        public function netSecurityError(event:SecurityErrorEvent):void {
            //net security error
        }
         
        /** 
		 * This method could be named anything - even onStatus. I've named it
		 * netStatus as in Dave Simmons example. In the docs they use the
		 * name netStatusHandler. Instead of receiving an information object
		 * it is passed an event that contains the information object.
		 */
		public function netStatus(event:NetStatusEvent):void 
		{
			// Write out information about connection events:
            var info:Object = event.info;
			switch (info.code) 
			{
				case "NetConnection.Connect.Success" :
					ro = SharedObject.getRemote("ChatUsers", nc.uri);
					if(ro){
						ro.addEventListener(SyncEvent.SYNC, OnSync);
						ro.connect(nc);
						ro.client = this; // refers to the scope of application and public funtions
					}
					textSharedName = "TextUser";
					textChatObject = new TextChat(textSharedName, nc, messageArea);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed); // Enables Enter Key for message send
					addMessage("<b>has connected to ChatterWebs</b>");
				   break;
				case "NetConnection.Connect.Closed" :
            		stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
				   break;
				case "NetConnection.Connect.Failed" :
				   break;
				case "NetConnection.Connect.Rejected" :
				   break;
				default :
				   break;
			}
		}
		
		private function keyPressed(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case 13: 
					sendMessage(); //Enter key
					groupListUpdated(new Event(Event.COMPLETE));
					break;
				default: 
					break;
			}
			
		}
		
		public function OnSync(event:SyncEvent):void 
		{
			// Show the ChangeList:
			var info:Object;
			var currentIndex:Number;
			var currentNode:Object;
			var changeList:Array = event.changeList;
			this.usersList.dataProvider = guestList; //update list of users

			for (var i:Number=0; i < changeList.length; i++) 
			{
				info =  changeList[i];
			}
		}
	
		/** echoResult is called when the echoResponder gets a result from the nc.call("echoMessage"..) */
        public function echoResult(msg:String):void{
        	//
        }
        
        /** echoResult is called when the echoResponder gets a error after a nc.call("echoMessage"..) */
        public function echoStatus(event:Event):void{
        	//
        }
        
		/** sendMessage is called when the Enter Key is pressed */
		public function sendMessage():void{
			addMessage(sendMessageInput.text);
			sendMessageInput.text = "";
		}
		
		/** get server tme  */
		public function getServerTime():void{
			nc.call("getServerTime", echoResponder,  sendMessageInput.text);
		}
		
		public function msgFromSrvr(msg:String):void{
			writeMessage(msg);
		}
		
		/** 
		 * writeMessage writes text into the main chat text area
		 */		
		public function writeMessage(msg:String):void{
			messageArea.text += msg + "\n";
			messageArea.validateNow();
			messageArea.verticalScrollPosition = messageArea.maxVerticalScrollPosition;
		}
		
		public function addMessage(txtMsg:String):void
		{
			var chatMessage:Object = new Object();
			
			chatMessage.message = txtMsg;
			chatMessage.time = new Date();
			chatMessage.user = nickname;
			
			nc.call("addMessage", null, "TextUser", chatMessage);
			
		}
		
		public function debug():void
		{
			for(var i:uint = 0; i < userStreams.length; i++)
			{
				(userStreams[i] as StreamingVideoViewer).animatedResize(320);
			}
		}

	}
}