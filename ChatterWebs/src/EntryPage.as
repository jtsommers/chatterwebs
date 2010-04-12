// ActionScript file
import com.chatterwebs.ConnectionManager;

import flash.events.*;
import flash.net.*;
import flash.utils.*;

private var connection:ConnectionManager;
private var sessionURL:String = 'http://chatterwebs.appspot.com';


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
private function connect():void
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
private function updateGroupInfo():void
{
	var group_id = category.selectedItem.@id
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
private function enter():void
{
	//navigateToURL(new URLRequest("file:///C:/Users/Sandi/Documents/Flex Builder 3/FlexChat/bin-debug/main.html?#userName="+user_txt.text+"&seatNumber="+seatNumber), "_blank");
	navigateToURL(new URLRequest("main.html?#userName="+username.text+"&guest_id="+connection.guest_id+"&group_id="+connection.group_id), "_top");
}