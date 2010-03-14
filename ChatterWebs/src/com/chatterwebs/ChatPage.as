package com.chatterwebs
{
	import mx.containers.Canvas;
	import mx.core.Application;
	import mx.events.FlexEvent;
	
	public class ChatPage extends Application
	{
		import mx.collections.ArrayCollection; 
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
        private var userName:String;
       
        public var textChat:Canvas;
        public var userNameMsg:Label;
        public var user1:Label;
        public var usersList:List;
        public var connectButton:Button;
        public var messageArea:TextArea;
        public var sendMessageInput:TextInput;
        public var sendButton:Button;
        public var traceArea:TextArea;
        public var serverTime:TextInput;
		
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

            /* The following code will parse a URL that passes userName as
               query string parameters after the "#" sign; for example:
               http://www.mydomain.com/MyApp.html#firstName=Nick&lastName=Danger */
            var o:Object = URLUtil.stringToObject(bm.fragment, "&");                
            
        	userName = o.userName;
        	userNameMsg.text = "Welcome, "+userName;
        	user1.text = userName;
		}
		
		/** 
		* videoChat is called whenever the cutton is pressed
		* and decides what to do based on the current label of the button.
		* NOTE: the rtmp address is in this function. Change it if you need to.
		*/
		public function videoChat():void
		{
   			navigateToURL(new URLRequest("http://s3anl4d2.site.nfoservers.com/chatterWeb/client/videoChatClient.html"), "_blank");
		}
		
       	/** 
         * connect is called whenever the connectButton is pressed
         * and decides what to do based on the current label of the button.
         * NOTE: the rtmp address is in this function. Change it if you need to.
         */
        public function connect():void
        {
        	switch(connectButton.label){
        		case "Connect":
        			connectButton.label = "Wait";
        			connectButton.enabled = false;
        			//nc.connect("rtmp://kurosawa.wpcareyonline.com/chat_test", userName.text);
        			nc.connect("rtmp://207.71.215.101/chatterWebs", userName);
        			nc.client = this;
        		break;
        		case "Disconnect":
        			connectButton.label = "Connect";
        			connectButton.enabled = true;
        			nc.close();
        		break;
        	}
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
					connectButton.label = "Disconnect";
            		connectButton.enabled = true;
            		sendButton.enabled = true; 
            		
            		writeln("Connecting non-persistent Remote SharedObject...\n");
					ro = SharedObject.getRemote("ChatUsers", nc.uri);
					if(ro){
						ro.addEventListener(SyncEvent.SYNC, OnSync);
						ro.connect(nc);
						ro.client = this; // refers to the scope of application and public funtions
					}
					getServerTime(); // get local time
				   break;
				case "NetConnection.Connect.Closed" :
					connectButton.label = "Connect";
            		connectButton.enabled = true;
            		sendButton.enabled = false;  
				   break;
				case "NetConnection.Connect.Failed" :
				   break;
				case "NetConnection.Connect.Rejected" :
				   break;
				default :
				   //statements
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
        
		/** sendMessage is called when the sendButton is pressed to test ns.send */
		public function sendMessage():void{
			// call our remote function and send the message to all connected clients
			nc.call("msgFromClient", null, sendMessageInput.text);
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

	}
}