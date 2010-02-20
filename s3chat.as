﻿// Sandi's test comment

var nc:NetConnection = null;
var nc2:NetConnection = null;
var nc3:NetConnection = null;
var camera:Camera;
var microphone:Microphone;
var nsPublish:NetStream = null;                      
var nsPlay:NetStream = null;
var nsPlay2:NetStream = null; 
var nsPlay3:NetStream = null; 

function startCamera()
{	
	// get the default Flash camera and microphone
	camera = Camera.getCamera();
	microphone = Microphone.getMicrophone();

	// here are all the quality and performance settings that we suggest
	camera.setMode(238, 132, 12, false);
	camera.setQuality(0, 75);
	camera.setKeyFrameInterval(24);
	microphone.rate = 11;
	microphone.setSilenceLevel(0);
	
	subscribeName.text = "Sandi";
	subscribeName2.text = "eric";
	subscribeName3.text = "jordan";
	publishName.text = "sean";
		
	connect.connectStr.text = "rtmp://localhost/videochat";
	connect.connectButton.addEventListener(MouseEvent.CLICK, doConnect);
	doPublish.addEventListener(MouseEvent.CLICK, publish);
	doSubscribe.addEventListener(MouseEvent.CLICK, subscribe);
	doSubscribe2.addEventListener(MouseEvent.CLICK, subscribe2);
	doSubscribe3.addEventListener(MouseEvent.CLICK, subscribe3);

	enablePlayControls(false);
}

function ncOnStatus(infoObject:NetStatusEvent)
{
	trace("nc: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetConnection.Connect.Failed")
		prompt.text = "Connection failed: Try rtmp://[server-ip-address]/s3";
	else if (infoObject.info.code == "NetConnection.Connect.Rejected")
		prompt.text = infoObject.info.description;
}

function ncOnStatus2(infoObject:NetStatusEvent)
{
	trace("nc2: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetConnection.Connect.Failed")
		prompt.text = "Connection failed: Try rtmp://[server-ip-address]/s3";
	else if (infoObject.info.code == "NetConnection.Connect.Rejected")
		prompt.text = infoObject.info.description;
}

function ncOnStatus3(infoObject:NetStatusEvent)
{
	trace("nc3: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetConnection.Connect.Failed")
		prompt.text = "Connection failed: Try rtmp://[server-ip-address]/s3";
	else if (infoObject.info.code == "NetConnection.Connect.Rejected")
		prompt.text = infoObject.info.description;
}

function doConnect(event:MouseEvent)
{
	// connect to the Wowza Media Server
	if (nc == null)
	{
		// create a connection to the wowza media server
		nc = new NetConnection();
		nc.connect(connect.connectStr.text);
		
		// get status information from the NetConnection object
		nc.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus);
		
		connect.connectButton.label = "Stop";
		
		// uncomment this to monitor frame rate and buffer length
		//setInterval(updateStreamValues, 500);
		
		myLCD.videoCamera.clear();
		myLCD.videoCamera.attachCamera(camera);
		
		enablePlayControls(true);
	}
	else
	{
		nsPublish = null;
		nsPlay = null;

		myLCD.videoCamera.attachCamera(null);
		myLCD.videoCamera.clear();
		
		lcd1.videoRemote.attachNetStream(null);
		lcd1.videoRemote.clear();
		
		nc.close();
		nc = null;
		
		enablePlayControls(false);

		doSubscribe.label = 'Play';
		doPublish.label = 'Publish';
		
		connect.connectButton.label = "Connect";
		prompt.text = "";
	}
	if (nc2 == null)
	{
		// create a connection to the wowza media server
		nc2 = new NetConnection();
		nc2.connect(connect.connectStr.text);
		
		// get status information from the NetConnection object
		nc2.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus2);
		
		connect.connectButton.label = "Stop";
		
		// uncomment this to monitor frame rate and buffer length
		//setInterval(updateStreamValues, 500);
		
		myLCD.videoCamera.clear();
		myLCD.videoCamera.attachCamera(camera);
		
		enablePlayControls(true);
	}
	else
	{
		nsPublish = null;
		nsPlay2 = null;

		myLCD.videoCamera.attachCamera(null);
		myLCD.videoCamera.clear();
		
		lcd2.videoRemote.attachNetStream(null);
		lcd2.videoRemote.clear();
		
		nc2.close();
		nc2 = null;
		
		enablePlayControls(false);

		doSubscribe2.label = 'Play';
		doPublish.label = 'Publish';
		
		connect.connectButton.label = "Connect";
		prompt.text = "";
	}
	if (nc3 == null)
	{
		// create a connection to the wowza media server
		nc3 = new NetConnection();
		nc3.connect(connect.connectStr.text);
		
		// get status information from the NetConnection object
		nc3.addEventListener(NetStatusEvent.NET_STATUS, ncOnStatus3);
		
		connect.connectButton.label = "Stop";
		
		// uncomment this to monitor frame rate and buffer length
		//setInterval(updateStreamValues, 500);
		
		myLCD.videoCamera.clear();
		myLCD.videoCamera.attachCamera(camera);
		
		enablePlayControls(true);
	}
	else
	{
		nsPublish = null;
		nsPlay3 = null;

		myLCD.videoCamera.attachCamera(null);
		myLCD.videoCamera.clear();
		
		lcd3.videoRemote.attachNetStream(null);
		lcd3.videoRemote.clear();
		
		nc3.close();
		nc3 = null;
		
		enablePlayControls(false);

		doSubscribe3.label = 'Play';
		doPublish.label = 'Publish';
		
		connect.connectButton.label = "Connect";
		prompt.text = "";
	}
}

function enablePlayControls(isEnable:Boolean)
{
	doPublish.enabled = isEnable;
	doSubscribe.enabled = isEnable;
	publishName.enabled = isEnable;
	subscribeName.enabled = isEnable;
	subscribeName2.enabled = isEnable;
	subscribeName3.enabled = isEnable;
}

// function to monitor the frame rate and buffer length
function updateStreamValues()
{
	if (nsPlay != null)
	{
		fpsText.text = (Math.round(nsPlay.currentFPS*1000)/1000)+" fps";
		bufferLenText.text = (Math.round(nsPlay.bufferLength*1000)/1000)+" secs";
	}
	else
	{
		fpsText.text = "";
		bufferLenText.text = "";
	}
	
	if (nsPlay2 != null)
	{
		fpsText.text = (Math.round(nsPlay2.currentFPS*1000)/1000)+" fps";
		bufferLenText.text = (Math.round(nsPlay2.bufferLength*1000)/1000)+" secs";
	}
	else
	{
		fpsText.text = "";
		bufferLenText.text = "";
	}
	
	if (nsPlay3 != null)
	{
		fpsText.text = (Math.round(nsPlay3.currentFPS*1000)/1000)+" fps";
		bufferLenText.text = (Math.round(nsPlay3.bufferLength*1000)/1000)+" secs";
	}
	else
	{
		fpsText.text = "";
		bufferLenText.text = "";
	}
}

function nsPlayOnStatus(infoObject:NetStatusEvent)
{
	trace("nsPlay: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed")
		prompt.text = infoObject.info.description;
}


function nsPlayOnStatus2(infoObject:NetStatusEvent)
{
	trace("nsPlay2: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed")
		prompt.text = infoObject.info.description;
}


function nsPlayOnStatus3(infoObject:NetStatusEvent)
{
	trace("nsPlay3: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed")
		prompt.text = infoObject.info.description;
}

function subscribe(event:MouseEvent)
{
	if (doSubscribe.label == 'Play')
	{
		// create a new NetStream object for video playback
		nsPlay = new NetStream(nc);
		
		// trace the NetStream status information
		nsPlay.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus);
		
		var nsPlayClientObj:Object = new Object();
		nsPlay.client = nsPlayClientObj;
		nsPlayClientObj.onMetaData = function(infoObject:Object) 
		{
			trace("onMetaData");
			
			// print debug information about the metaData
			for (var propName:String in infoObject)
			{
				trace("  "+propName + " = " + infoObject[propName]);
			}
		};		

		// set the buffer time to zero since it is chat
		nsPlay.bufferTime = 0;
		
		// subscribe to the named stream
		nsPlay.play(subscribeName.text);
		
		// attach to the stream
		lcd1.videoRemote.attachNetStream(nsPlay);
		
		doSubscribe.label = 'Stop';
	}
	else
	{		
		// here we are shutting down the connection to the server
		lcd1.videoRemote.attachNetStream(null);
		nsPlay.play(null);
		nsPlay.close();

		doSubscribe.label = 'Play';
	}
}

function subscribe2(event:MouseEvent)
{
	if (doSubscribe2.label == 'Play')
	{
		// create a new NetStream object for video playback
		nsPlay2 = new NetStream(nc2);
		
		// trace the NetStream status information
		nsPlay2.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus2);
		
		var nsPlayClientObj2:Object = new Object();
		nsPlay2.client = nsPlayClientObj2;
		nsPlayClientObj2.onMetaData = function(infoObject:Object) 
		{
			trace("onMetaData");
			
			// print debug information about the metaData
			for (var propName:String in infoObject)
			{
				trace("  "+propName + " = " + infoObject[propName]);
			}
		};		

		// set the buffer time to zero since it is chat
		nsPlay2.bufferTime = 0;
		
		// subscribe to the named stream
		nsPlay2.play(subscribeName2.text);
		
		// attach to the stream
		lcd2.videoRemote.attachNetStream(nsPlay2);
		
		doSubscribe2.label = 'Stop';
	}
	else
	{		
		// here we are shutting down the connection to the server
		lcd2.videoRemote.attachNetStream(null);
		nsPlay2.play(null);
		nsPlay2.close();

		doSubscribe2.label = 'Play';
	}
}

function subscribe3(event:MouseEvent)
{
	if (doSubscribe3.label == 'Play')
	{
		// create a new NetStream object for video playback
		nsPlay3 = new NetStream(nc3);
		
		// trace the NetStream status information
		nsPlay3.addEventListener(NetStatusEvent.NET_STATUS, nsPlayOnStatus3);
		
		var nsPlayClientObj3:Object = new Object();
		nsPlay3.client = nsPlayClientObj3;
		nsPlayClientObj3.onMetaData = function(infoObject:Object) 
		{
			trace("onMetaData");
			
			// print debug information about the metaData
			for (var propName:String in infoObject)
			{
				trace("  "+propName + " = " + infoObject[propName]);
			}
		};		

		// set the buffer time to zero since it is chat
		nsPlay3.bufferTime = 0;
		
		// subscribe to the named stream
		nsPlay3.play(subscribeName3.text);
		
		// attach to the stream
		lcd3.videoRemote.attachNetStream(nsPlay3);
		
		doSubscribe3.label = 'Stop';
	}
	else
	{		
		// here we are shutting down the connection to the server
		lcd3.videoRemote.attachNetStream(null);
		nsPlay3.play(null);
		nsPlay3.close();

		doSubscribe3.label = 'Play';
	}
}


function nsPublishOnStatus(infoObject:NetStatusEvent)
{
	trace("nsPublish: "+infoObject.info.code+" ("+infoObject.info.description+")");
	if (infoObject.info.code == "NetStream.Play.StreamNotFound" || infoObject.info.code == "NetStream.Play.Failed")
		prompt.text = infoObject.info.description;
}

function publish(event:MouseEvent)
{
	if (doPublish.label == 'Publish')
	{
		// create a new NetStream object for video publishing
		nsPublish = new NetStream(nc);
		
		nsPublish.addEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
		
		// set the buffer time to zero since it is chat
		nsPublish.bufferTime = 0;
	
		// publish the stream by name
		nsPublish.publish(publishName.text);
		
		// add custom metadata to the stream
		var metaData:Object = new Object();
		metaData["description"] = "Chat using VideoChat example."
		nsPublish.send("@setDataFrame", "onMetaData", metaData);

		// attach the camera and microphone to the server
		nsPublish.attachCamera(camera);
		nsPublish.attachAudio(microphone);
		
		doPublish.label = 'Stop';
	}
	else
	{
		// here we are shutting down the connection to the server
		nsPublish.attachCamera(null);
		nsPublish.attachAudio(null);
		nsPublish.publish("null");
		nsPublish.close();

		doPublish.label = 'Publish';
	}
}

stage.align = "TL";
stage.scaleMode = "noScale";

startCamera();
stop();