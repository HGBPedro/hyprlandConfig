#!/bin/bash
    #read the conf file for the needed info
    read a b c lat lon<<< $(tr '\n' ' ' <$HOME/.config/eww/topbar/scripts/weather/wbar.conf)
    #get current weather info from OWM, use jq to strip it down to main temp and the icon id, then strip linebreaks and quotes from it
    read d <<< $(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$b&units=$c" | jq -r '.weather[].icon' | tr '\n' ' ' | sed "s/\"//g")
    #define the icons 
    i="??"
  if [[ $d == 01d ]]; then
    i="󰖙" # clear day (fa-sun)
elif [[ $d == 01n ]]; then
    i="󰖔" # clear night (fa-moon)
elif [[ $d == 02d ]]; then
    i="󰖕" # few clouds day (fa-cloud-sun)
elif [[ $d == 02n ]]; then
    i="󰼱" # few clouds night (fa-cloud-moon)
elif [[ $d == 03* || $d == 04* ]]; then
    i="" # scattered/broken clouds day/night (fa-cloud)
elif [[ $d == 09* ]]; then
    i="󰖖" # shower rain day/night (fa-cloud-showers-heavy)
elif [[ $d == 10d ]]; then
    i="󰼳" # rain day (fa-sun + fa-cloud)
elif [[ $d == 10n ]]; then
    i="󰖖" # rain night (fa-moon + fa-cloud)
elif [[ $d == "10d 11d" ]]; then
    i="󰼲" # thunderstorm day (fa-bolt + fa-sun)
elif [[ $d == "10n 11n" ]]; then
    i="󰙾" # thunderstorm night (fa-bolt + fa-moon)
elif [[ $d == 11* ]]; then
    i="󰙾" # thunderstorm generic (fa-bolt)
elif [[ $d == 13* ]]; then
    i="󰖘" # snow day/night (fa-snowflake)
elif [[ $d == 50* ]]; then
    i="󰖑" # fog day/night (fa-smog)
fi   
echo "$i" #put em together
