################################################
:global ifstatus
:global date1
:global date2
:global globalDiff

##--------------------------------------------##
:local isLOG true
:local isUP false
:local InterfaceState false
:local interfaceState false
:local BotID "874055243:AAEJ0fvbtQHAeUGyJUPf4f6e2y4chOYRnW0"
:local ChanelID "-1001795546103"
:local ChatURL  "https://api.telegram.org/bot$BotID/sendMessage\?chat_id=$ChanelID"
:local Blue "%F0%9F%94%B5"
:local Red "%F0%9F%94%B4"
:local On "Power is ON"
:local Off "Power is OFF"

##------ Block for Debug ----------------------##

:if ($isLOG) do={:log info "Script Test1 started"}

##------- Check of any local interface from 1 to 4 is UP ----------##
:set $isUP false
:for i from 1 to 4 do={
	:set $InterfaceState [/interface ethernet get number=$i running];  
	:set $isUP {$isUP or [/interface ethernet get number=$i running]};  
	:if ($isLOG) do={:log info "InterfaceState ($i) = $InterfaceState "}
	:if ($isLOG) do={:log info "isUP = $isUP "}
}
:if ($isLOG) do={:log info "At least one local interface is UP = $isUP"}


:if ($isUP=true) do={
	:if ($isLOG) do={:log info "Step isUP"};
	:if ($ifstatus="down") do={
		:if ($isLOG) do={:log info "Change status to UP"};
		:set $date2 "$[/system clock get date] $[/system clock get time]";
		/system script run diffDate;
		/tool fetch url="$ChatURL&text=$Blue $On ($globalDiff)" dst-path=Log.txt
		:if ($LOG) do={:log info "Link UP. Power is ON ($globalDiff)"};
		:set $date1 "$[/system clock get date] $[/system clock get time]";
	}
	:set $ifstatus "up";
}  else={
	:if ($isLOG) do={:log info "Step Else"};
	:if ($ifstatus="up") do={
		:if ($isLOG) do={:log info "Change status to Down"};
		:set $date2 "$[/system clock get date] $[/system clock get time]";
		/system script run diffDate;
		/tool fetch url="$ChatURL&text=$Red $Off ($globalDiff)" dst-path=Log.txt;
		:if ($LOG) do={:log info "Link DOWN. Power is OFF ($globalDiff)"};
		:set $date1 "$[/system clock get date] $[/system clock get time]";
	}
	:set $ifstatus "down"
}

:if ($isLOG) do={
	:set $date2 "$[/system clock get date] $[/system clock get time]";
	/system script run diffDate;
	:if ($isUP) do={ 
		:log info  "Link UP. Power is ON ($globalDiff)"
		} else={ 
		:log info  "Link DOWN. Power is OFF ($globalDiff)";
		}
	}

