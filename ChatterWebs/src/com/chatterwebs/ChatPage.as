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
        public var selfid:Label;
        public var usersList:List;
        public var messageArea:TextArea;
        public var sendMessageInput:TextInput;
        public var traceArea:TextArea;
        public var serverTime:TextInput;
        public var selfFeed:UserFeed;
        private var userStreams:Array = new Array();
        private var ip:String;
		private var sessionURL:String = 'http://chatterwebs.appspot.com';
		private var connection:ConnectionManager;
		private var groupXML:XML;
		private var textSharedName:String;
		private var connectOn:Boolean;		
		
		//TODO: remove test vars
		public var guestList:Array = new Array();
		
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
               http://www.mydomain.com/MyApp.html#firstName=Nick&lastName=Danger */
               
            
            var o:Object = URLUtil.stringToObject(bm.fragment, "&");                
            
        	nickname = o.nickname;
        	ip = o.ip;
        	if(!nickname)
        	{
        		nickname = "Default User";
        	}
        	userNameMsg.text = "Welcome, " + nickname;
        	resumeSession();
        	selfid.text = nickname;
        	
        	var xpos:uint = 137;
        	var ypos:uint = 27;
        	for (var i:uint = 0; i <7; i++)
        	{
        		var newStream:StreamingVideoViewer = new StreamingVideoViewer();
        		addChild(newStream);
        		newStream.move(xpos, ypos);
        		xpos += 168;
        		userStreams.push(newStream);
        	}
        	guestList = connection.guestList;
		}
		
		
		// == BEGIN Session Management ============================================================================
		private function resumeSession():void{								  // Resume session from entry page 
			var o:Object = URLUtil.stringToObject(bm.fragment, "&");          // get URL   
			group_id = o.group_id;											  // get group_id
			guest_id = o.guest_id;											  // get guest_id
			connection = new ConnectionManager(nickname ,group_id, guest_id); // set connection to session manager
			connection.eDispatcher.addEventListener(ConnectionManager.GROUP_CHANGED, groupListUpdated);
			
			var updateTimer:Timer = new Timer(10000, 1000);					  // This timer updates the groupXML
			updateTimer.addEventListener(TimerEvent.TIMER, updateInfo);		  // every 10 seconds
			updateTimer.start();											  //
		}
		private function updateInfo(e:TimerEvent):void
		{
			updateGroupInfo();
		}
		private function updateGroupInfo():void
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, setGroupInfo);
			loader.load(new URLRequest(sessionURL+'/group/'+ group_id +'/?mimetype=xml'));
		}
		private function setGroupInfo(e:Event):void
		{
		    var groupXML:XML = new XML(e.target.data);						  // update groupXML
		}
		private function groupListUpdated(e:Event):void
		{
			guestList = connection.guestList;
			resetVideo();
			traceArea.text = connection.guestList.toString();
		}
		// == END Session Management ===============================================================================
		
		
		
		/** 
		* videoChat is called whenever the button is pressed
		* and decides what to do based on the current label of the button.
		* NOTE: the rtmp address is in this function. Change it if you need to.
		*/
		public function videoChat():void
		{
			selfFeed.startCamera();
			selfFeed.displayCamera();
			selfFeed.publish(nickname, nc);
			selfFeed.toggleHide();
			for(var i:uint = 0; i < userStreams.length; i++){
				(userStreams[i] as StreamingVideoViewer).subscribe(guestList[i], nc);
			}
		}
		
		public function resetVideo():void
		{
			for(var i:uint = 0; i < userStreams.length; i++){
				(userStreams[i] as StreamingVideoViewer).killStream();
				(userStreams[i] as StreamingVideoViewer).subscribe(guestList[i], nc);
			}
		}
		
       	/** 
         * connect is called when the the connection is created.
         * and decides what to do based on the current label of the button.
         * NOTE: the rtmp address is in this function. Change it if you need to.
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
        			selfFeed.killFeed();
        			selfFeed.killMirror();
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
        public function connectOnSwitch():void
        {
        	connectOn = false;
        	connect();
        }
        
        public function netSecurityError(event:SecurityErrorEvent):void {
            writeln("netSecurityError: " + event);
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
            writeln("netStatus: " + event);
            var info:Object = event.info;
            for(var p:String in info) {
                writeln(p + " : " + info[p]);
            }
            writeln("");

			switch (info.code) 
			{
				case "NetConnection.Connect.Success" :
            		writeln("Connecting non-persistent Remote SharedObject...\n");
					ro = SharedObject.getRemote("ChatUsers", nc.uri);
					if(ro){
						ro.addEventListener(SyncEvent.SYNC, OnSync);
						ro.connect(nc);
						ro.client = this; // refers to the scope of application and public funtions
					}
					textSharedName = "TextUser";
					var textChatObject:TextChat = new TextChat(textSharedName, nc, messageArea);
					stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed); // Enables Enter Key for message send
					getServerTime(); // get local time
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
				case 13: sendMessage(); //Enter key
						 break;
				default: break;
			}
		}
		
		public function OnSync(event:SyncEvent):void 
		{
			// Show the ChangeList:
			var info:Object;
			var currentIndex:Number;
			var currentNode:Object;
			var changeList:Array = event.changeList;
			var temp:Array = new Array();
			
			writeln("---- Shared Object Data -----");
			for(var p:String in ro.data){ 
				writeln("OnSync> RO: " + p + ": " + ro.data[p]);
				temp.push(ro.data[p]);
			}
			this.usersList.dataProvider = temp; //update list of users

			for (var i:Number=0; i < changeList.length; i++) 
			{
				info =  changeList[i];
				for (var k:String in info){
					writeln("OnSync> changeList[" + i + "]." + k + ": " + info[k]);
				}
			}
		}
	
		/** echoResult is called when the echoResponder gets a result from the nc.call("echoMessage"..) */
        public function echoResult(msg:String):void{
        	writeln("echoResult: " + msg + "\n");
        	this.serverTime.text = msg;
        }
        
        /** echoResult is called when the echoResponder gets a error after a nc.call("echoMessage"..) */
        public function echoStatus(event:Event):void{
        	writeln("echoStatus: " + event);
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

		/** showMessage is the function called by the inStream. See the netStatus function */
		public function showMessage(msg:String):void{
			writeln("showMessage: " + msg + "\n");
		}
		
		public function setUserID(msg:Number):void{
			writeln("showMessage: " + msg + "\n");
		}
		
		public function setHistory(msg:String):void{
			writeln("showHistory: " + msg + "\n");
		}
		
		public function msgFromSrvr(msg:String):void{
			writeMessage(msg);
		}	
				
		/** 
		 * writeln writes text into the traceArea TextArea instead of using trace. 
		 * Note to get scrolling to the bottom of the TextArea to work validateNow()
		 * must be called before scrolling.
		 */		
		public function writeln(msg:String):void{
			traceArea.text += msg + "\n";
			traceArea.validateNow();
			traceArea.verticalScrollPosition = traceArea.maxVerticalScrollPosition;
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