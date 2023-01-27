       ### calculate diff between two dates - yoan tanguy 2017
       
       # expected date format : month/day/year hours:minutes:seconds (ex: mar/14/2017 09:13:54)
       :global date1
       :global date2
       
       
       # date to array format :
       # m a r / 1 4 / 2 0 1 7     0  9  :  1  3  :  5  4
       # 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
       :local date1month [:pick $date1 0 3]
       :local date1day [:pick $date1 4 6]
       :local date1year [:pick $date1 7 11]
       :local date1hours [:pick $date1 12 14]
       :local date1minutes [:pick $date1 15 17]
       :local date1seconds [:pick $date1 18 20]
       
       :local date2month [:pick $date2 0 3]
       :local date2day [:pick $date2 4 6]
       :local date2year [:pick $date2 7 11]
       :local date2hours [:pick $date2 12 14]
       :local date2minutes [:pick $date2 15 17]
       :local date2seconds [:pick $date2 18 20]
       
       
       # month to decimal converter - https://forum.mikrotik.com/viewtopic.php?t=58674
       :local months ("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec");
       :set date1month ([:find $months $date1month -1 ] + 1)
       :set date2month ([:find $months $date2month -1 ] + 1)
       
       
       :global globalDiff 
       :local yearDiff ($date2year - $date1year)
       :local monthDiff ($date2month - $date1month)
       :local dayDiff ($date2day - $date1day) 
       :local hoursDiff ($date2hours - $date1hours)
       :local minutesDiff ($date2minutes - $date1minutes)
       :local secondsDiff ($date2seconds - $date1seconds)
       
       
       # handle diff by converting in seconds, avoid negative hours/minutes/seconds (ex: jan/01/1970 09:00:00, jan/02/1970 08:00:00 must give 0 days 23:00:00 and not 1 days 0-1:00:00)
       # 1 days 23:30:10
       # 1*24*60*60 + 23*60*60 + 30*60 + 10
       # ($dayDiff * 24*60*60) + ($hoursDiff * 60*60) + ($minutesDiff *60) + $secondsDiff
       # ($dayDiff * 86400) + ($hoursDiff * 3600) + ($minutesDiff *60) + $secondsDiff
       :local secondsGlobalDiff
       :set secondsGlobalDiff (($dayDiff * 86400) + ($hoursDiff * 3600) + ($minutesDiff *60) + $secondsDiff)
       :set dayDiff ($secondsGlobalDiff / 86400)
       :set secondsGlobalDiff ($secondsGlobalDiff - ($dayDiff * 86400))
       :set hoursDiff ($secondsGlobalDiff / 3600)
       :set secondsGlobalDiff ($secondsGlobalDiff - ($hoursDiff * 3600))
       :set minutesDiff ($secondsGlobalDiff / 60)
       :set secondsGlobalDiff ($secondsGlobalDiff - ($minutesDiff * 60))
       :set secondsDiff $secondsGlobalDiff
       
       
       # check if date1 is older than date2 to avoid errors in calculation
       if ($yearDiff < 0) do={
           :return "error : date1 should be older that date2 (year check), exiting"
       } else={
           if ($yearDiff = 0) do={
               if ($monthDiff <0) do={
                   :return "error : date1 should be older that date2 (month check), exiting"
               } else={
                   if ($monthDiff = 0) do={
                       if ($dayDiff < 0) do={
                           :return "error : date1 should be older that date2 (day check), exiting"
                       } else={
                           if ($dayDiff = 0) do={
                               if ($hoursDiff < 0) do={
                                   :return "error : date1 should be older that date2 (hours check), exiting"
                               } else={
                                   if ($hoursDiff = 0) do={
                                       if ($minutesDiff < 0) do={
                                           :return "error : date1 should be older that date2 (minutes check), exiting"
                                       } else={
                                           if ($minutesDiff = 0) do={
                                               if ($secondsDiff < 0) do={
                                                   :return "error : date1 should be older that date2 (seconds check), exiting"
                                               }
                                           }
                                       }
                                   }
                               }
                           }
                       }
                   }
               }
           }
       }          
       
       
       # check if leap years - https://wiki.mikrotik.com/wiki/AutomatedBilling/MonthEndScript
       :local isYear1Leap 0
       :local isYear2Leap 0
       if ((($date1year / 4) * 4) = $date1year) do={
           :set isYear1Leap 1
       }
       if ((($date2year / 4) * 4) = $date2year) do={
           :set isYear2Leap 1
       }
       
       
       # find the right amount of days between 2 months
       :local daysInEachMonth ("31","28","31","30","31","30","31","31","30","31","30","31");
       :local daysInEachMonthLeapYear ("31","29","31","30","31","30","31","31","30","31","30","31");
       :local totalDaysBetweenMonths
       
       # same year; yearDiff = 0 so year1 = year2
       if ($yearDiff = 0 and $monthDiff >= 1) do={
           if ($isYear1Leap = 0) do={         
               for month from=($date1month - 1) to=($date2month - 1) step=1 do={
                   :set totalDaysBetweenMonths ($totalDaysBetweenMonths + [:pick $daysInEachMonth $month])
               }
           }
           if ($isYear1Leap = 1) do={
               for month from=($date1month - 1) to=(($date2month - 1) - 1) step=1 do={
                   :set totalDaysBetweenMonths ($totalDaysBetweenMonths + [:pick $daysInEachMonthLeapYear $month])
               }
           }
       }
       
       # different year, make concatenation of daysInEachMonth arrays first
       :local daysInEachMonthConcatenatedYears
       if ($yearDiff >= 1) do={
       
           for year from=$date1year to=$date2year step=1 do={
               # if leap year, concatenate the right daysInEachMonth array
               if ((($year / 4) * 4) = $year) do={
                   :set daysInEachMonthConcatenatedYears ($daysInEachMonthConcatenatedYears, $daysInEachMonthLeapYear)
               } else={
                   :set daysInEachMonthConcatenatedYears ($daysInEachMonthConcatenatedYears, $daysInEachMonth)
               }
           }
           
           # must add years count 
           for month from=($date1month - 1) to=(($date2month - 1)  + (($yearDiff * 12) - 1)) step=1 do={
               :set totalDaysBetweenMonths ($totalDaysBetweenMonths + [:pick $daysInEachMonthConcatenatedYears $month])
           }
       }
       
       :local globalDaysDiff ($totalDaysBetweenMonths + $dayDiff)
       
       
       # add leading zeros if necessary
       :if ($hoursDiff < 10) do={
           :set hoursDiff ("0" . $hoursDiff)
       }
       :if ($minutesDiff < 10) do={
           :set minutesDiff ("0" . $minutesDiff)
       }
       :if ($secondsDiff < 10) do={
           :set secondsDiff ("0" . $secondsDiff)
       } 
       
       :set globalDiff "$globalDaysDiff days $hoursDiff:$minutesDiff:$secondsDiff"
       :put $globalDiff