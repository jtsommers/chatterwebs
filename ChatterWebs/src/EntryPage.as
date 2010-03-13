// ActionScript file
import mx.collections.ArrayCollection; 
import flash.net.*;
import flash.events.*;
import flash.utils.*;
import mx.controls.*;
import mx.core.UIComponent;
	
/** 
* enter is called whenever the buttonEnter is pressed
*/
private function enter():void
{
	//navigateToURL(new URLRequest("file:///C:/Users/Sandi/Documents/Flex Builder 3/FlexChat/bin-debug/main.html?#userName="+user_txt.text+"&seatNumber="+seatNumber), "_blank");
	navigateToURL(new URLRequest("main.html?#userName="+username.text), "_top");
}
