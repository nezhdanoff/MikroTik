##--------------------------------------------##
:global ifstatus
:global date1
:global date2
:global globalDiff
:global UpdateDate1 do={:global date1; :set $date1 "$[/system clock get date] $[/system clock get time]";}
:global UpdateDate2 do={:global date2; :set $date2 "$[/system clock get date] $[/system clock get time]";}

##--------------------------------------------##
:local isLOG false
:local isUP false
:local interfaceState false
:local BotID "874055243:AAEJ0fvbtQHAeUGyJUPf4f6e2y4chOYRnW0"
:local ChanelID "-1001795546103"
:local ChatURL  "https://api.telegram.org/bot$BotID/sendMessage\?chat_id=$ChanelID"
:local Blue "%F0%9F%94%B5"
:local Red "%F0%9F%94%B4"
:local On "Power is ON"
:local Off "Power is OFF"
:local UrlON "$ChatURL&text=$Blue $On ($globalDiff)"
:local UrlOFF "$ChatURL&text=$Red $Off ($globalDiff)"

##------- Check of any local interface from 1 to 4 is UP ----------##
:set $isUP false
:for i from 1 to 4 do={
		:set $InterfaceState [/interface ethernet get number=$i running];  
		:set $isUP {$isUP or $InterfaceState};  
	}

:if ($isLOG) do={:log info "At least one local interface is UP = $isUP"}

:if ($isUP=true) do={
	:if ($ifstatus="down") do={
			:set $date2 "$[/system clock get date] $[/system clock get time]";
			/system script run diffDate;
			/tool fetch url=$UrlON dst-path=Log.txt;
			$UpdateDate1;
		}
		:set $ifstatus "up";
	} else={
		:if ($ifstatus="up") do={
			:set $date2 "$[/system clock get date] $[/system clock get time]";
			/system script run diffDate;
			/tool fetch url=$UrlOFF dst-path=Log.txt;
			$UpdateDate1;
		}
		:set $ifstatus "down";
	}

:if ($isLOG) do={
		$UpdateDate2;
		/system script run diffDate;
		:if ($isUP) do={ 
			:log info  "Link UP. Power is ON ($globalDiff)"
		} else={ 
			:log info  "Link DOWN. Power is OFF ($globalDiff)"
		}
	}