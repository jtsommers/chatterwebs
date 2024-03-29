package com.chatterwebs
{
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.controls.Alert;
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
        public var streamArea:Canvas;
        public var feedArea:UIComponent;
        public var userNameMsg:Label;
        public var usersList:List;
        public var messageArea:TextArea;
        public var sendMessageInput:TextInput;
        public var buttonVideo:Button;			//start video chat button
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
        		timeOut();
        	}
        	userNameMsg.text = "Welcome, " + nickname;
        	//server connect occurs here
        	resumeSession();
        	
        	var xpos:uint = 5;
        	var ypos:uint = 5;
        	for (var i:uint = 0; i <8; i++)
        	{
        		var newStream:StreamingVideoViewer = new StreamingVideoViewer();
        		streamArea.addChild(newStream);
        		newStream.move(xpos, ypos);
        		xpos += newStream.width + 5;
        		if(i == 3){
        			ypos = 160;
        			xpos = 5;
        		}
        		userStreams.push(newStream);
        	}
        	guestList = connection.guestList;
		}
		
		
		// == BEGIN Session Management ============================================================================
		private function resumeSession():void{								  // Resume session from entry page 
			var o:Object = URLUtil.stringToObject(bm.fragment, "&");          // get URL   
			group_id = o.group_id;											  // get group_id
			guest_id = o.guest_id;											  // get guest_id
			if(group_id && guest_id)
			{
				connection = new ConnectionManager(nickname, group_id, guest_id); // set connection to session manager
				connection.eDispatcher.addEventListener(ConnectionManager.GROUP_CHANGED, groupListUpdated);
				//TODO: move connect logic until after first name check
				connectOn = true;
            	connect();
			}else
			{	//entry did not occur through valid entry page
				timeOut();
			}
		}
		private function groupListUpdated(e:Event):void
		{
			guestList = connection.guestList;
			validateCurrentUser();
			updateStreams();
			dynamicResizeStreams();
			textChatUserList = new Array();
			for(var i:uint; i < guestList.length; i++)
			{
				textChatUserList.push({label: guestList[i], value:"user"+i});
			}
			this.usersList.dataProvider = textChatUserList;
		}
		// == END Session Management ===============================================================================
		
		private function validateCurrentUser():void
		{
			if(guestList)
			{
				for(var i:uint=0; i < guestList.length; i++)
				{
					if(nickname == guestList[i])
					{
						//User is allowed to be in room, do not boot out to entry page
						return;
					}
				}
			}else
			{
				timeOut();
			}
		}
		
		private function timeOut():void
		{
			//Current user was not found in valid guest list.
			//Immediately disconnect, display a message that user will be redirected in 10 seconds
			//along with a button to immediately redirect to the entry page to allow user to reconnect.
			killAllStreams();
			nc.close();
			connection = null;
			Alert.show("Connection Timed Out, Press OK to return to login page",
				"Connection Error", Alert.OK, this, redirectListener);
			//TODO: potentially add automatic redirect timer
		}
		
		private function redirectListener(e:Event):void
		{
			if(this.ip)
			{
				navigateToURL(new URLRequest("EntryPage.html?#nickname="+this.nickname+"&ip="+this.ip), "_top");
			}else
			{
				navigateToURL(new URLRequest("EntryPage.html?#nickname="+this.nickname), "_top");
			}
		}
		
		/** 
		* videoChat is called whenever the button is pressed
		* and decides what to do based on the current label of the button.
		*/
		public function videoChat():void
		{
			if(buttonVideo.label == "Start Video Chat")
			{
				selfFeed.publish(nickname, nc);
				groupListUpdated(new Event(Event.COMPLETE));
				updateStreams();
				buttonVideo.label = "Stop Video Chat";
			}else
			{
				selfFeed.kill();
				updateStreams();
				buttonVideo.label = "Start Video Chat";
			}
		}
		
		public function updateStreams():void
		{
			var selfFound:Boolean = false;
			for(var i:uint = 0; i < userStreams.length; i++)
			{
				var curStream:StreamingVideoViewer = (userStreams[i] as StreamingVideoViewer);
				var nick:String = curStream.nickname;
				var currentGuest:String;
				if (guestList[i] == this.nickname)
				{
					selfFound = true;
				}
				if (selfFound)
				{
					currentGuest = guestList[i+1];
				}else
				{
					currentGuest = guestList[i];
				}
				if(nick != currentGuest)
				{
					curStream.killStream();
					curStream.subscribe(currentGuest, nc);
				}
			}
		}
		
		public function dynamicResizeStreams():void
		{
			var numStreams:uint = guestList.length - 1;		//set current number of streams to guest list size (minus your feed)
			var streamSize:Rectangle = StreamingVideoViewer.calculateDimensions(numStreams, streamArea.getBounds(this));
			var horizontalPadding:uint = streamArea.width;
			var verticalPadding:uint = streamArea.height;
			var firstRow:uint = numStreams;					//number of streams in the first row
			var numRows:uint = 1;
			for(var ndx:uint = numStreams; ndx>0; ndx--)
			{
				if((horizontalPadding - streamSize.width) > 0)
				{
					horizontalPadding -= streamSize.width;
				}
				if((verticalPadding - streamSize.height) > 0)
				{
					verticalPadding -= streamSize.height;
				}
			}
			
			if(numStreams <= 3)
			{
				firstRow = numStreams;
				numRows =1;
			}else if(numStreams <=6)
			{
				firstRow = 3;
				numRows = 2;
			}else if(numStreams <=8)
			{
				firstRow = 4;
				numRows = 2;
			}else					//invalid number of streams
			{
				firstRow = 0;
				numRows = 0;
			}
			horizontalPadding /= (firstRow+1);				//divide by number of padding buffers needed
			verticalPadding /= (numRows+1);
			if(horizontalPadding < 5)		
			{
				horizontalPadding = 5;						//set to minimum if padding space is less than necessary
			}
			if(verticalPadding < 5)	
			{
				verticalPadding = 5;						//set to minimum if padding space is less than necessary
			}
			
			if(numStreams == 0)
			{
				horizontalPadding = 5;
				verticalPadding = 5;
			}
			
			var xpos:uint = horizontalPadding;				//initial displacement based on available padding
			var ypos:uint = verticalPadding;
			for(var i:uint = 0; i < userStreams.length; i++)
			{
				(userStreams[i] as StreamingVideoViewer).animatedResize(streamSize.width);
				(userStreams[i] as StreamingVideoViewer).animatedMove(xpos, ypos);
				xpos += streamSize.width+horizontalPadding;
				if((xpos + streamSize.width) > streamArea.width)
				{
					ypos += streamSize.height+verticalPadding;
					xpos = horizontalPadding;
				}
				if((ypos + streamSize.height) > streamArea.height)
				{
					ypos = verticalPadding;
				}
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
					this.buttonVideo.enabled = true;
				   break;
				case "NetConnection.Connect.Closed" :
            		stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
            		this.guestList = null;
            		this.validateCurrentUser();
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
					if(sendMessageInput.text != "")		//don't send empty strings through chat
					{
						sendMessage(); //Enter key
					}
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
	}
}