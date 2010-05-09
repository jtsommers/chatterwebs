package com.chatterwebs
{
	import flash.events.*;
	import flash.net.*;
	
	import mx.controls.*;
	import mx.core.UIComponent;
	
	
	public class TextChat extends UIComponent
	{
		
		public var chatSharedObjectName:String;
		public var chatText:String = "";
		public var textchat_so:SharedObject = null;
		public var lastChatId:Number = 0;
		
		public function TextChat(soName:String, nc:NetConnection, messageArea:TextArea)
		{
			// formats the text message
			// TODO : Fix time to server time.
			// TODO : make not nested
			function formatMessage(chatData:Object):String
			{
			var msg:String;
			var currTime:Date = chatData.time;
			
			var hour24:Number = currTime.getHours();
			var ampm:String = (hour24<12) ? "AM" : "PM";
			var hourNum:Number = hour24%12;
			if (hourNum == 0)
				hourNum = 12;
		
			var hourStr:String = hourNum+"";
			var minuteStr:String = (currTime.getMinutes())+"";
			if (minuteStr.length < 2)
				minuteStr = "0"+minuteStr;
			var secondStr:String = (currTime.getSeconds())+"";
			if (secondStr.length < 2)
				secondStr = "0"+secondStr;
		
			msg = "<u>"+hourStr+":"+minuteStr+":"+secondStr+ampm+"</u> - <b>"+chatData.user+"</b>: "+chatData.message;
			return msg;
			}
			
			// initialize the shared object server side
			nc.call("initSharedObject", new Responder(connectTextObjectRes), soName);
			
			function connectTextObjectRes(soName:String):void
			{
				chatSharedObjectName = soName;
				connectTextObject(soName);
			}
			
			function connectTextObject(soName:String):void
			{
			
				textchat_so = SharedObject.getRemote(soName, nc.uri);
				
				// add new message to the chat box as they come in
				textchat_so.addEventListener(SyncEvent.SYNC, textEventHandler);
			
				textchat_so.connect(nc);	
			}
			
			function textEventHandler(ev:SyncEvent):void
			{
				var infoObj:Object = ev.changeList;
				
				// if first time only show last 4 messages in the list
				if (lastChatId == 0)
				{
					lastChatId = Number(textchat_so.data["lastChatId"]) - 4;
					if (lastChatId < 0)
						lastChatId = 0;
				}
				
				// show new messasges
				var currChatId:Number = Number(textchat_so.data["lastChatId"]);
				
				// if there are new messages to display
				if (currChatId > 0)
				{
					var i:Number;
					for(i=(lastChatId+1);i<=currChatId;i++)
					{
						if (textchat_so.data["chatData"+i] != undefined)
						{
							var chatMessage:Object = textchat_so.data["chatData"+i];
							
							var msg:String = formatMessage(chatMessage);
							chatText += "<p>" + msg + "</p>";
							messageArea.htmlText = chatText;
						}
					}
					
					if (messageArea.length > 0)
						messageArea.verticalScrollPosition = messageArea.maxVerticalScrollPosition;
					lastChatId = currChatId;
				}
			}
		}
	}
}