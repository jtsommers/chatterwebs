Configure ChatterWebs to run off your local Wowza Media Server

# Introduction #

First, download and install Wowza Media Server for your environment from: http://www.wowzamedia.com/store.html

From the same location you can also get a developer license that will allow you to run the server with a limit of 10 concurrent connections.

**DEFAULT INSTALL DIRECTORIES**
```
Windows Install Directory: C:\Program Files\Wowza Media Systems\Wowza Media Server 2\
Mac Install Directory: HD/Library/Wowza Media Server 2.0/
```
-Both of the above will be referred to as [InstallLocation](InstallLocation.md) for the duration of this document

-[setup](setup.md) is the "[Repository/ChatterWebs/Wowza Local Setup](http://code.google.com/p/chatterwebs/source/browse/#hg/ChatterWebs/Wowza%20Local%20Setup)" path in the mercurial repository




# Details #

1) Copy the wms-plugin-textchat.jar from [setup](setup.md)/lib/ to [InstallLocation](InstallLocation.md)/lib/

2) Copy the chatterwebs folder from [setup](setup.md)/conf/ to [InstallLocation](InstallLocation.md)/conf/

3) Copy the chatterWebs folder from [setup](setup.md)/applications to [InstallLocation](InstallLocation.md)/applications/


Once configured, to startup the server run startup.bat in the [InstallLocation](InstallLocation.md)/bin/ directory (shutdown.bat is also located here).  Startup and shutdown shortcuts are also placed in the start menu or searchable "Wowza Startup" and "Wowza Shutdown."

To setup the client to stream from your Wowza Media server you must edit either the html-template or the html file itself and change the flashvars "saddress" (server address) parameter to "rtmp://[YourIP](YourIP.md)/chatterWebs"  (line 90 of ChatterWebs/html-template/index.template.html or ChatterWebs/bin-debug/main.html)

To stream accross the web, you need to forward ports 1395 and 8086 to your computer's local ip and use the ip address of your router.  (see http://www.portforward.com)